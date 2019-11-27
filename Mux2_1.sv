`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Haley Pierce
// Create Date: 10/06/2019 11:18:31 PM
// Module Name: Mux2_1
//////////////////////////////////////////////////////////////////////////////////


module Mux2_1(
    input [31:0] ZERO, ONE,
    input SEL,
    output logic [31:0] MUXOUT
    );
    
    always_comb
    begin
        case (SEL)
            0: MUXOUT = ZERO;
            1: MUXOUT = ONE;
            default: MUXOUT = ZERO;
        endcase
    end
endmodule
