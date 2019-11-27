`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Haley Pierce
// Create Date: 09/21/2019 02:53:50 PM
// Module Name: Mux4_1
// Description: 4 input mux
//////////////////////////////////////////////////////////////////////////////////


module Mux4_1(
    input [31:0] ZERO, ONE, TWO, THREE,
    input [1:0] SEL,
    output logic [31:0] MUXOUT
    );
    
    always_comb
    begin
        case (SEL)
            0: MUXOUT = ZERO;
            1: MUXOUT = ONE;
            2: MUXOUT = TWO;
            3: MUXOUT = THREE;
            default: MUXOUT = ZERO;
        endcase
    end
endmodule
