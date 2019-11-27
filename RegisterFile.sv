`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Haley Pierce
// Create Date: 09/25/2019 11:25:14 AM
// Module Name: RegisterFile
// Description: 32x32 RAM
//////////////////////////////////////////////////////////////////////////////////


module RegisterFile(
    input CLK, EN,
    input [31:0] WD,
    input [4:0] ADR1, ADR2, WA,
    output logic [31:0] RS1, RS2
    );
    
    //32x32
    logic [31:0] mem [0:31];
    
    //initialize all memory to 0
    initial
    begin
        for (int i = 0; i < 32; i++)
        begin
            mem[i] = 0;
        end
    end
    
    //synch write
    always_ff @ (posedge CLK)
    begin
        if (EN == 1 && WA != 0)
            mem[WA] <= WD;
    end
    
    //asynch reads (two)
    assign RS1 = mem[ADR1];
    assign RS2 = mem[ADR2];
    
    
endmodule
