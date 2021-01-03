`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/03 00:44:10
// Design Name: 
// Module Name: cpu_data_like
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


module data_sram_like(
    input wire clk,
    input wire rst,
    // input from cpu
    input wire        cpu_data_en   ,
    input wire [3 :0] cpu_data_wen  ,
    input wire [31:0] cpu_data_addr ,
    input wire [31:0] cpu_data_wdata,
    input wire        cpu_longest_stall,
    // output to cpu
    output wire [31:0] cpu_data_rdata,
    output wire        cpu_data_stall,
    // output to bridge
    output wire        data_req    ,
    output wire        data_wr     ,
    output wire [1 :0] data_size   ,
    output wire [31:0] data_addr   ,
    output wire [31:0] data_wdata  ,
    // input from brige
    input wire [31:0] data_rdata   ,
    input wire        data_addr_ok ,
    input wire        data_data_ok
    );
    reg addr_rcv;      // 地址握手成功
    reg do_finish;     // 读写事务结束

    always @(posedge clk) begin
        addr_rcv <= rst          ? 1'b0 :
        // 保证先data_req再addr_rcv；如果addr_ok同时data_ok，则优先data_ok
                    data_req & data_addr_ok & ~data_data_ok ? 1'b1 : 
        // (先处理上一条事务)   
                    data_data_ok ? 1'b0 : addr_rcv;
    end

    always @(posedge clk) begin
        do_finish <= rst          ? 1'b0 :
        // 只判断data_ok
                     data_data_ok ? 1'b1 :
        // cpu 仍在暂停，保证一次流水线暂停只取一次指令，只进行一次内存访问
                     ~cpu_longest_stall ? 1'b0 : do_finish;
    end

    // save rdata
    reg [31:0] data_rdata_save;
    always @(posedge clk) begin
        data_rdata_save <= rst ? 32'b0:
        // data_ok 则更新暂存值
                           data_data_ok ? data_rdata : data_rdata_save;
    end

    // sram like
    assign data_req = cpu_data_en & ~addr_rcv & ~do_finish;
    assign data_wr = cpu_data_en & |cpu_data_wen;
    assign data_size = (cpu_data_wen==4'b0001 || cpu_data_wen==4'b0010 || cpu_data_wen==4'b0100 || cpu_data_wen==4'b1000) ? 2'b00:
                       (cpu_data_wen==4'b0011 || cpu_data_wen==4'b1100 ) ? 2'b01 : 2'b10;
    assign data_addr = cpu_data_addr;
    assign data_wdata = cpu_data_wdata;

    // sram
    assign cpu_data_rdata = data_rdata_save;
    assign data_stall = cpu_data_en & ~do_finish;
    
endmodule
