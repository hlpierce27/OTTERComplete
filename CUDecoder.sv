`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Haley Pierce
// Create Date: 10/04/2019 11:31:05 AM
// Module Name: CUDecoder
//////////////////////////////////////////////////////////////////////////////////


module CUDecoder(
    input BR_EQ, BR_LT, BR_LTU, INT_TAKEN,
    input [2:0] FUNC3,
    input [6:0] FUNC7, CU_OPCODE,
    output logic [3:0] ALU_FUN,
    output logic [1:0] ALU_SRCB, RF_WR_SEL,
    output logic [2:0] PC_SOURCE,
    output logic ALU_SRCA
    );
    
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
    
    always_comb
    begin
        case (OPCODE)
            LUI: 
            begin
                ALU_FUN = 9; ALU_SRCA = 1; ALU_SRCB = 0; PC_SOURCE = 0; RF_WR_SEL = 3;
            end
            
            AUIPC:
            begin
                ALU_FUN = 0; ALU_SRCA = 1; ALU_SRCB = 3; PC_SOURCE = 0; RF_WR_SEL = 3;
            end
            
            JAL:
            begin
                ALU_FUN = 0; ALU_SRCA = 0; ALU_SRCB = 0; PC_SOURCE = 3; RF_WR_SEL = 0;
            end
            
            JALR:
            begin
                ALU_FUN = 0; ALU_SRCA = 0; ALU_SRCB = 0; PC_SOURCE = 1; RF_WR_SEL = 0;
            end
            
            BRANCH:
            begin
                ALU_FUN = 0; ALU_SRCA = 0; ALU_SRCB = 0; RF_WR_SEL = 0;
                if (FUNC3 == 3'b000 && BR_EQ)
                    begin
                        PC_SOURCE = 2;
                    end
                else if (FUNC3 == 3'b001 && !BR_EQ)
                    begin
                        PC_SOURCE = 2;
                    end
                else if (FUNC3 == 3'b100 && BR_LT)
                    begin
                        PC_SOURCE = 2;
                    end
                else if (FUNC3 == 3'b101 && !BR_LT)
                    begin
                        PC_SOURCE = 2;
                    end     
                else if (FUNC3 == 3'b110 && BR_LTU)
                    begin
                        PC_SOURCE = 2;
                    end
                else if (FUNC3 == 3'b111 && !BR_LTU)
                    begin
                        PC_SOURCE = 2;
                    end  
                else
                    begin
                        PC_SOURCE = 0;
                    end                                                         
            end
            
            LOAD:
            begin
                ALU_FUN = 0; ALU_SRCA = 0; ALU_SRCB = 1; PC_SOURCE = 0; RF_WR_SEL = 2;
            end
            
            STORE:
            begin
                ALU_FUN = 0; ALU_SRCA = 0; ALU_SRCB = 2; PC_SOURCE = 0; RF_WR_SEL = 0;
            end
            
            OP_IMM:
            begin
                ALU_SRCA = 0; ALU_SRCB = 1; PC_SOURCE = 0; RF_WR_SEL = 3;
            
                case (FUNC3)
                    3'b000: ALU_FUN = {1'b0, FUNC3};
                    3'b010: ALU_FUN = {1'b0, FUNC3};
                    3'b011: ALU_FUN = {1'b0, FUNC3};
                    3'b100: ALU_FUN = {1'b0, FUNC3};
                    3'b110: ALU_FUN = {1'b0, FUNC3};
                    3'b111: ALU_FUN = {1'b0, FUNC3};
                    3'b001: ALU_FUN = {1'b0, FUNC3};
                    3'b101: ALU_FUN = {FUNC7[5], FUNC3};
                    default: ALU_FUN = 4'b0000;
                endcase
            end
            
            OP:
            begin
                ALU_SRCA = 0; ALU_SRCB = 0; PC_SOURCE = 0; RF_WR_SEL = 3;
            
                case (FUNC3)
                    3'b000: ALU_FUN = {FUNC7[5], FUNC3};
                    3'b010: ALU_FUN = {FUNC7[5], FUNC3};
                    3'b011: ALU_FUN = {FUNC7[5], FUNC3};
                    3'b100: ALU_FUN = {FUNC7[5], FUNC3};
                    3'b110: ALU_FUN = {FUNC7[5], FUNC3};
                    3'b111: ALU_FUN = {FUNC7[5], FUNC3};
                    3'b001: ALU_FUN = {FUNC7[5], FUNC3};
                    3'b101: ALU_FUN = {FUNC7[5], FUNC3};
                    default: ALU_FUN = 4'b0000;
                endcase
            end
            SYSTEM:
            begin
                ALU_SRCA = 0; ALU_SRCB = 0; ALU_FUN = 9; RF_WR_SEL = 1;
                if (FUNC3 == 3'b000)                                             //double check
                begin
                    PC_SOURCE = 5;
                end
                else
                begin
                    PC_SOURCE = 0;
                end
            end
        endcase
        if (INT_TAKEN)
        begin
            PC_SOURCE = 4;
        end
    end
endmodule
