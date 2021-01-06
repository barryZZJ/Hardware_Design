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
    input wire  [31:0] inst_vaddr,
    output wire [31:0] inst_paddr,
    input wire  [31:0] data_vaddr,
    output wire [31:0] data_paddr,

    output wire no_dcache  // ����confreg��ַ�򲻾���dcache
    );
    wire inst_kseg0, inst_kseg1;
    wire data_kseg0, data_kseg1;

    assign inst_kseg0 = (inst_vaddr[31:29] == 3'b100);
    assign inst_kseg1 = (inst_vaddr[31:29] == 3'b101);
    assign data_kseg0 = (data_vaddr[31:29] == 3'b100);
    assign data_kseg1 = (data_vaddr[31:29] == 3'b101);

    assign inst_paddr = inst_kseg0 | inst_kseg1 ?
           {3'b0, inst_vaddr[28:0]} : inst_vaddr;
    assign data_paddr = data_kseg0 | data_kseg1 ?
           {3'b0, data_vaddr[28:0]} : data_vaddr;
    assign no_dcache = data_kseg1 ? 1'b1 : 1'b0;
endmodule
