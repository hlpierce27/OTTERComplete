`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Haley Pierce
// Create Date: 09/21/2019 03:28:22 PM
// Module Name: Lab1Top
//////////////////////////////////////////////////////////////////////////////////


module Lab1Top(
    input [31:0] JALR, BRANCH, JUMP,
    input [1:0] PC_SOURCE,
    input PC_WRITE, RESET, CLK, MEM_READ1,
    output logic [31:0] DOUT
    );
    
    logic [31:0] pc_in, pc_out, pc_4;
    assign pc_4 = pc_out + 4;
    
    Mux4_1 PCMux (.ZERO(pc_4), .ONE(JALR), .TWO(BRANCH), .THREE(JUMP),
                  .SEL(PC_SOURCE), .MUXOUT(pc_in));
                  
    PC     MyPC  (.DIN(pc_in), .CLK(CLK), .RESET(RESET), .PC_WRITE(PC_WRITE),
                  .DOUT(pc_out));
                  
    OTTER_mem_byte MyMem (.MEM_CLK(CLK), .MEM_ADDR1(pc_out), .MEM_READ1(MEM_READ1),
                          .MEM_DOUT1(DOUT));
                                             
endmodule
