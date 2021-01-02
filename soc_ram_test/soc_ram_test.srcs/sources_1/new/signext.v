`timescale 1ns / 1ps

module signext (input [15:0] a,
                input [1:0] type,
                output [31:0] y);

// type == 2'b11时，立即数是零扩展
assign y = type == 2'b11 ? {{16{1'b0}}, a} : {{16{a[15]}}, a};

endmodule
