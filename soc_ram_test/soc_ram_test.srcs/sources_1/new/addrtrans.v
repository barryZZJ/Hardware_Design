`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/01 15:59:12
// Design Name: 
// Module Name: addrtrans
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


module addrtrans(
    input wire [31:0] inst_addr,
    input wire [31:0] data_addr,
    output wire [31:0] inst_sram_addr,
    output wire [31:0] data_sram_addr
    );
    // 
    // wire [31:0] data_sram_addr_temp;
    // 移位为字寻址模式
    assign inst_sram_addr = inst_addr;
    assign data_sram_addr = data_addr;
    // confreg 数据地址转换
    /*assign data_sram_addr = (data_sram_addr_temp[31] == 1'b1) ? 
                            {3'b000,data_sram_addr_temp[28:0]} : data_sram_addr_temp;*/

endmodule
