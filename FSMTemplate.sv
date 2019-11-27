module FSM_Template(
    input CLK, RST,
    input X1, X2,
    input [3:0] X3,
    output logic Z1,
    output logic [7:0] Z2, Z3 
    );
    
 typedef enum {STA, STB, STC, STD} STATES;
 STATES NS, PS;
       
always_ff @ (posedge CLK)
begin
   if (RST)
       PS <= STA;
   else
       PS <= NS;
end

always_comb 
begin
    //initialize all outputs to zero
    Z1 = 0; Z2 = 0; Z3 = 0;
    case (PS)
        STA: begin
            Z1 = 1;
            Z2 = 138;
            if (X1) begin
                NS = STB;
                Z3 = 44;
            end
            else begin
                NS = STA;
                Z3 = 22;
            end    
        end
        STB: begin
            if (X3 == 7)
                NS = STC;
            else
                NS = STA;
        end
        STC: begin
            NS = STD;
            Z1 = 1;
            if (!X2)
                Z2 = 23;
            else
                Z2 = 94;
        end
        STD:begin
            NS = STA;
            if (X1 && X2) begin            
                Z2 = 89;
                Z3 = 89;
                NS = STA;
            end
            else begin
                Z2 = 44;
                Z3 = 44;
                NS = STD;
            end    
        end
        default:
            NS = STA;           
    endcase
end
            
       
endmodule