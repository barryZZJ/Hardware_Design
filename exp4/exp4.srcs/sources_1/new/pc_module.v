`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/31 23:12:12
// Design Name: 
// Module Name: pc_module
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pc_module #(parameter WIDTH = 32)
    (input clk,
     input rst,
     input en,
     input [WIDTH-1:0] d,
     output reg [WIDTH-1:0] q);
    
always @(posedge clk, posedge rst) begin
    if (rst) begin
        q <= 32'hbfc00000;
    end else if (en) begin
        q <= d;
    end
end
endmodule
