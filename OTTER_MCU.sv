`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Haley Pierce
// Create Date: 10/06/2019 06:04:35 PM
// Module Name: OTTER_MCU
// Description: Top module
//////////////////////////////////////////////////////////////////////////////////


module OTTER_MCU(
    input CLK, RST, INTR, RX,
    input [31:0] IOBUS_IN,
    output logic [31:0] IOBUS_OUT, IOBUS_ADDR,
    output logic IOBUS_WR, TX
    );
    
    logic [31:0] pc_in, wd, pc_out, pc_4, mema_out, ir, alu_a, alu_b, alu_out, rs1, rs2;
    logic [31:0] rd, mtvec, mepc;
    logic [31:0] I_immed, S_immed, B_immed, U_immed, J_immed;
    logic [31:0] jalr_pc, branch_pc, jump_pc;
    logic [3:0] fun;
    logic [2:0] pc_sel;
    logic [1:0] srcb, rf_wr;
    logic srca, pc_write, reg_write, mem_write, mem_read1, mem_read2, br_eq, br_lt, br_ltu;
    logic int_taken, mie, interrupt, csr_write;
    
    assign pc_4 = pc_out + 4;
    
    assign I_immed = {{21{ir[31]}}, ir[31:20]};
    assign S_immed = {{21{ir[31]}}, ir[31:25], ir[11:7]};
    assign B_immed = {{20{ir[31]}}, ir[7], ir[30:25], ir[11:8], 1'b0};
    assign U_immed = {ir[31:20], ir[19:12], 12'b0};
    assign J_immed = {{12{ir[31]}}, ir[19:12], ir[20], ir[30:25], ir[24:21], 1'b0};
    
    assign jalr_pc = rs1 + I_immed;
    assign branch_pc = pc_out + B_immed;
    assign jump_pc = pc_out + J_immed;
    
    assign br_eq = (rs1 == rs2);
    assign br_lt = ($signed(rs1) < $signed(rs2));
    assign br_ltu = (rs1 < rs2);
    
    assign interrupt = (INTR && mie);
    
    logic [31:0] prog_ram_data, mem_data_after;
    logic [31:0] prog_ram_addr, mem_addr_after;
    logic [1:0] mem_size_after;
    logic prg_we, rst_new, mem_we_after, prog_rst;
    
    assign mem_addr_after = prg_we ? prog_ram_addr: alu_out;
    assign mem_data_after = prg_we ? prog_ram_data : rs2;
    assign mem_size_after = prg_we ? 2'b10 : ir[13:12];
    assign mem_we_after = prg_we | mem_write;
    assign rst_new = prog_rst | RST;

    assign IOBUS_OUT = mem_data_after;
    assign IOBUS_ADDR = mem_addr_after;
    
    OTTER_mem_byte  Mem       (.MEM_ADDR2(mem_addr_after), .MEM_DIN2(mem_data_after), .MEM_WRITE2(mem_we_after), .IO_IN(IOBUS_IN),
                               .IO_WR(IOBUS_WR), .MEM_SIZE(mem_size_after), .MEM_READ2(mem_read2),
                               .MEM_SIGN(ir[14]), .MEM_DOUT2(mema_out), .MEM_CLK(CLK),
                               .MEM_ADDR1(pc_out), .MEM_READ1(mem_read1), .MEM_DOUT1(ir));
                         
    RegisterFile    RegFile   (.CLK(CLK), .EN(reg_write), .WD(wd), .WA(ir[11:7]), .ADR1(ir[19:15]),
                               .ADR2(ir[24:20]), .RS1(rs1), .RS2(rs2));
    
    CUDecoder       CUD1      (.BR_EQ(br_eq), .BR_LT(br_lt), .BR_LTU(br_ltu), .FUNC3(ir[14:12]), .FUNC7(ir[31:25]),
                               .CU_OPCODE(ir[6:0]), .ALU_FUN(fun), .ALU_SRCA(srca), .ALU_SRCB(srcb),
                               .PC_SOURCE(pc_sel), .RF_WR_SEL(rf_wr), .INT_TAKEN(int_taken));
                               
    ALU             ALU1      (.A(alu_a), .B(alu_b), .ALU_FUN(fun), .ALU_OUT(alu_out));
        
    PC              PC1       (.DIN(pc_in), .PC_WRITE(pc_write), .RESET(rst_new), .CLK(CLK), .DOUT(pc_out));
    
    MUX8_1          MuxPC     (.ZERO(pc_4), .ONE(jalr_pc), .TWO(branch_pc), .THREE(jump_pc),
                               .FOUR(mtvec), .FIVE(mepc), .SIX(), .SEVEN(), .SEL(pc_sel), .MUXOUT(pc_in));
    
    Mux4_1          MuxReg    (.ZERO(pc_4), .ONE(rd), .TWO(mema_out), .THREE(alu_out), .SEL(rf_wr), .MUXOUT(wd));
    
    Mux4_1          MuxALU    (.ZERO(rs2), .ONE(I_immed), .TWO(S_immed), .THREE(pc_out), .SEL(srcb), .MUXOUT(alu_b));
    
    Mux2_1          Mux2ALU   (.ZERO(rs1), .ONE(U_immed), .SEL(srca), .MUXOUT(alu_a));
    
    CU_FSM          FSM1      (.CLK(CLK), .INTR(interrupt), .RST(rst_new), .DIN(ir), .PC_WRITE(pc_write), 
                               .REG_WRITE(reg_write), .MEM_WRITE(mem_write), .MEM_READ1(mem_read1),
                               .MEM_READ2(mem_read2), .INT_TAKEN(int_taken), .CSR_WRITE(csr_write));
                               
    CSR             CSR1      (.CLK(CLK), .RST(rst_new), .INT_TAKEN(int_taken), .ADDR(ir[31:20]), .PC(pc_out), .WD(alu_out),
                               .WR_EN(csr_write), .RD(rd), .CSR_MEPC(mepc), .CSR_MTVEC(mtvec), .CSR_MIE(mie)); 
                     
    programmer #(.CLK_RATE(50), .BAUD(115200), .IB_TIMEOUT(200),
                               .WAIT_TIMEOUT(500))
                               programmer(.clk(CLK), .rst(RST), .srx(RX), .stx(TX),
                               .mcu_reset(prog_rst), .ram_addr(prog_ram_addr),
                               .ram_data(prog_ram_data), .ram_we(prg_we));
                               
 
endmodule
