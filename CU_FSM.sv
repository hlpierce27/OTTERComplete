`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Haley Pierce
// Create Date: 10/09/2019 11:15:19 AM
// Module Name: CU_FSM
//////////////////////////////////////////////////////////////////////////////////


module CU_FSM(
    input CLK, INTR, RST,
    input [31:0] DIN,
    output logic PC_WRITE, REG_WRITE, MEM_WRITE, MEM_READ1, MEM_READ2, CSR_WRITE, INT_TAKEN
    );
    
    logic [6:0] CU_OPCODE;
    logic [2:0] FUNC3;
    assign CU_OPCODE = DIN[6:0];
    assign FUNC3 = DIN[14:12];
    
    typedef enum logic [6:0] {
        LUI     = 7'b0110111,
        AUIPC   = 7'b0010111,
        JAL     = 7'b1101111,
        JALR    = 7'b1100111,
        BRANCH  = 7'b1100011,
        LOAD    = 7'b0000011,
        STORE   = 7'b0100011,
        OP_IMM  = 7'b0010011,
        OP      = 7'b0110011,
        SYSTEM  = 7'b1110011
    } opcode_t;
    opcode_t OPCODE;
    
    assign OPCODE = opcode_t'(CU_OPCODE);
    
    parameter [1:0] FETCH = 2'b00,
                    EXECUTE = 2'b01,
                    WRITE_BACK = 2'b10,
                    INTERRUPT = 2'b11;
    
    logic [1:0] NS;
    logic [1:0] PS = FETCH;
    
    always_ff @ (posedge RST, posedge CLK)
        begin
            if (RST) 
                PS <= FETCH;
            else
                PS <= NS;
        end
    
    always_comb 
    begin
    PC_WRITE = 0; REG_WRITE = 0; MEM_WRITE = 0; MEM_READ1 = 0; MEM_READ2 = 0; CSR_WRITE = 0; INT_TAKEN = 0;
    case (PS)
        FETCH:
        begin
        PC_WRITE = 0; REG_WRITE = 0; MEM_WRITE = 0; MEM_READ2 = 0; CSR_WRITE = 0; INT_TAKEN = 0;
            MEM_READ1 = 1;
            NS = EXECUTE;
        end
            
        EXECUTE:
        begin
        CSR_WRITE = 0; INT_TAKEN = 0;
            if(OPCODE == LOAD && !INTR)
            begin
                MEM_READ2 = 1;
                NS = WRITE_BACK;
            end
            else if(OPCODE != LOAD && INTR)
            begin
                PC_WRITE = 1;
                NS = INTERRUPT;
            end
            else if(OPCODE == LUI)
            begin
                PC_WRITE = 1; REG_WRITE = 1;
                NS = FETCH;
            end
            else if(OPCODE == AUIPC)
            begin
                PC_WRITE = 1; REG_WRITE = 1;
                NS = FETCH;
            end
            else if(OPCODE == JAL)
            begin
                PC_WRITE = 1; REG_WRITE = 1;
                NS = FETCH;
            end
            else if(OPCODE == JALR)
            begin
                PC_WRITE = 1; REG_WRITE = 1;
                NS = FETCH;
            end            
            else if(OPCODE == BRANCH)
            begin
                PC_WRITE = 1;
                NS = FETCH;
            end            
            else if(OPCODE == STORE)
            begin
                PC_WRITE = 1; MEM_WRITE = 1;
                NS = FETCH;
            end            
            else if(OPCODE == OP_IMM)
            begin
                PC_WRITE = 1; REG_WRITE = 1;
                NS = FETCH;
            end    
            else if(OPCODE == OP)
            begin
                PC_WRITE = 1; REG_WRITE = 1;
                NS = FETCH;
            end
            else if(OPCODE == SYSTEM)
            begin
                if (FUNC3 == 3'b001)
                begin
                    PC_WRITE = 1; REG_WRITE = 1; MEM_WRITE = 0; MEM_READ1 = 0; MEM_READ2 = 0; CSR_WRITE = 1; INT_TAKEN = 0;
                    NS = FETCH;
                end
                else
                begin
                    PC_WRITE = 1; REG_WRITE = 0; MEM_WRITE = 0; MEM_READ1 = 0; MEM_READ2 = 0; CSR_WRITE = 0; INT_TAKEN = 0;
                    NS = FETCH;
                end
            end
        end
        
        WRITE_BACK:
        begin
            PC_WRITE = 1; REG_WRITE = 1; MEM_WRITE = 0; MEM_READ2 = 0;
            CSR_WRITE = 0; INT_TAKEN = 0;
            if (INTR)
            begin
                NS = INTERRUPT;
            end
            else
            begin
                NS = FETCH;
            end
        end
        
        INTERRUPT:
        begin
            PC_WRITE = 1; REG_WRITE = 0; MEM_WRITE = 0; MEM_READ1 = 0; MEM_READ2 = 0;
            CSR_WRITE = 0; INT_TAKEN = 1;
            NS = FETCH;
        end
        
        default: 
            NS = FETCH;
    endcase
    end
endmodule
