`timescale 1ns / 1ps

module inst_sram_like(
    input wire clk,
    input wire rst,
    // input from cpu
    input wire        cpu_inst_en   ,
    input wire [3 :0] cpu_inst_wen  ,       // no use
    input wire [31:0] cpu_inst_addr ,
    input wire [31:0] cpu_inst_wdata,       // no use
    input wire        cpu_longest_stall,
    // output to cpu
    output wire [31:0] cpu_inst_rdata,
    output wire        cpu_inst_stall,      
    // output to bridge
    output wire        inst_req    ,
    output wire        inst_wr     ,        // no use
    output wire [1 :0] inst_size   ,        // no use
    output wire [31:0] inst_addr   ,
    output wire [31:0] inst_wdata  ,        // no use
    // input from brige
    input wire [31:0] inst_rdata   ,
    input wire        inst_addr_ok ,
    input wire        inst_data_ok
    );

    reg addr_rcv;           // 地址握手成功
    reg do_finish;          // 读事务结束

    always @(posedge clk) begin
        addr_rcv <= rst          ? 1'b0 :
        // 保证先inst_req再addr_rcv；如果addr_ok同时data_ok，则优先data_ok
                    inst_req & inst_addr_ok & ~inst_data_ok ? 1'b1 :    
                    inst_data_ok ? 1'b0 : addr_rcv;
    end

    always @(posedge clk) begin
        do_finish <= rst          ? 1'b0 :
                     inst_data_ok ? 1'b1 :
                     ~cpu_longest_stall ? 1'b0 : do_finish;
    end

    // save rdata
    reg [31:0] inst_rdata_save;
    always @(posedge clk) begin
        inst_rdata_save <= rst ? 32'b0:
                           inst_data_ok ? inst_rdata : inst_rdata_save;
    end

    // sram like
    assign inst_req = cpu_inst_en & ~addr_rcv & ~do_finish;
    assign inst_wr = 1'b0;
    assign inst_size = 2'b10;
    assign inst_addr = cpu_inst_addr;
    assign inst_wdata = 32'b0;

    // sram
    assign cpu_inst_rdata = inst_rdata_save;
    assign cpu_inst_stall = cpu_inst_en & ~do_finish;
endmodule
