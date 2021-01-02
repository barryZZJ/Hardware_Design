`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/02 18:03:53
// Design Name: 
// Module Name: sram_like
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


module sram_like(
    /////////////////////////////////////////
    // input from cpu
    //////////////// inst ///////////////////
    input   [31:0] inst_addr_cpu    ,   // CPU请求指令地址
    input          inst_wr_cpu      ,   // CPU请求写指令       // no use
    input   [ 1:0] data_size_cpu    ,   // CPU请求指令字节数    // no use
    //////////////// data ///////////////////
    input   [31:0] data_addr_cpu    ,   // CPU请求数据地址
    input          data_wr_cpu      ,   // CPU请求写数据
    input   [ 1:0] data_size_cpu    ,   // CPU请求数据字节数
    /////////////////////////////////////////
    // output to cpu
    //////////////// inst ///////////////////
    output  [31:0] inst_rdata_cpu   ,   // 返回CPU指令
    //////////////// data ///////////////////
    output  [31:0] data_rdata_cpu   ,   // 返回CPU数据
    
    /////////////////////////////////////////
    // output to SRAM - AXI bridge
    //////////////// inst ///////////////////
    output         inst_req_bridge  ,   // 请求
    output         inst_wr_bridge   ,   // 写信号
    output  [1 :0] inst_size_bridge ,   // 传输字节数
    output  [31:0] inst_addr_bridge ,   // 指令地址
    output  [31:0] inst_wdata_bridge,   // 待写指令
    //////////////// data ///////////////////
    output         data_req_bridge  ,   // 请求
    output         data_wr_bridge   ,   // 写信号
    output  [1 :0] data_size_bridge ,   // 传输字节数
    output  [31:0] data_addr_bridge ,   // 数据地址
    output  [31:0] data_wdata_bridge,   // 待写数据
    /////////////////////////////////////////
    // input from SRAM - AXI bridge
    //////////////// inst ///////////////////
    input   [31:0] inst_rdata_bridge  , // 读指令
    input          inst_addr_ok_bridge, // 地址确认
    input          inst_data_ok_bridge, // 指令确认
    //////////////// data ///////////////////
    input   [31:0] data_rdata_bridge  , // 读数据
    input          data_addr_ok_bridge, // 地址确认
    input          data_data_ok_bridge  // 数据确认
    );
    /////////////////////////////////////////////////////////////////////////////////////
    // clk      1       input 时钟
    // req      1       master—>slave 请求信号，为 1 时有读写请求，为 0 时无读写请求
    // wr       1       master—>slave 该次请求是写
    // size     [1:0]   master—>slave 该次请求传输的字节数，0: 1byte；1: 2bytes；2: 4bytes。
    // addr     [31:0]  master—>slave 该次请求的地址
    // wdata    [31:0]  master—>slave 该次请求的写数据
    // addr_ok  1       slave—>master 该次请求的地址传输 OK，读：地址被接收；写：地址和数据被接收
    // data_ok  1       slave—>master 该次请求的数据传输 OK，读：数据返回；写：数据写入完成。
    // rdata    [31:0]  slave—>master 该次请求返回的读数据。
    /////////////////////////////////////////////////////////////////////////////////////

    /////////////////////////////////////////////////////////////////////////////////////
    //
    // 读写数据有效位
    //
    /////////////////////////////////////////////////////////////////////////////////////
    /*
    reg [31:0] data_valid
    always @(*) begin
        case (size)
        2'b00 : begin
            case (addr)
                2'b00: data_valid <= {24'bX, data[ 7: 0]       };
                2'b01: data_valid <= {16'bX, data[15: 8],  8'bX};
                2'b10: data_valid <= {8'bX , data[23:16], 16'bX};
                2'b11: data_valid <= {       data[31:24], 24'bX};
            endcase
        end
        2'b01 : begin
            case (addr)
                2'b00: data_valid <= {16'bX, data[15: 0]};
                2'b10: data_valid <= {data[31:16], 16'bX};
            endcase
        end
        2'b10 :begin
            if(addr == 2'b00): begin
                data_valid <= data[31:0]
            end
        end
        endcase
    end
    */
endmodule
