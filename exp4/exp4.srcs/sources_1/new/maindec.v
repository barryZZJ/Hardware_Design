`timescale 1ns / 1ps

module main_decoder(input [5:0] op,
                    output reg regdst,
                    output reg regwrite,
                    output reg alusrc,
                    output reg memwrite,
                    output reg memtoreg,
                    output reg branch,
                    output reg jump);
    
    always @(*) begin
        case (op)
           
        endcase
    end
    
endmodule
