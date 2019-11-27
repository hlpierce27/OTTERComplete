`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Haley Pierce
// Create Date: 09/21/2019 03:17:41 PM
// Module Name: PC
// Description: program counter - a register
//////////////////////////////////////////////////////////////////////////////////


module PC(
    input [31:0] DIN,
    input PC_WRITE, RESET, CLK,
    output logic [31:0] DOUT = 0
    );
    
    always_ff @ (posedge CLK)
    begin
        if (RESET)
        begin
            DOUT <= 0;
        end
        else if (PC_WRITE)
        begin
            DOUT <= DIN;
        end
    end
endmodule
