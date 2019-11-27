`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Haley Pierce
// Create Date: 10/21/2019 10:28:36 AM
// Module Name: MUX8_1
//////////////////////////////////////////////////////////////////////////////////


module MUX8_1(
    input [31:0] ZERO, ONE, TWO, THREE, FOUR, FIVE, SIX, SEVEN,
    input [2:0] SEL,
    output logic [31:0] MUXOUT
    );
    
    always_comb
    begin
        case (SEL)
            0: MUXOUT = ZERO;
            1: MUXOUT = ONE;
            2: MUXOUT = TWO;
            3: MUXOUT = THREE;
            4: MUXOUT = FOUR;
            5: MUXOUT = FIVE;
            6: MUXOUT = SIX;
            7: MUXOUT = SEVEN;
            default: MUXOUT = ZERO;
        endcase
    end
endmodule
