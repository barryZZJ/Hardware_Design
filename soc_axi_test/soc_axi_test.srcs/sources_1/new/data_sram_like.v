`timescale 1ns / 1ps

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
        // 本次读mem事务是否完成。用来告诉CPU数据准备好了。
        // 如果数据准备好了(data_ok)，就告诉CPU数据准备好了(finish=1)，数据存到save里，等待CPU读。如果CPU忙，mem这边就要一直保持do_finish(为1)，等CPU有空之后来读。
        // CPU有空之后(~longest_stall)，就会读，这时把do_finish归零，准备下一次访存。
        // 如果数据还没准备好，但是CPU已经有空了(~longest_stall)，就让CPU接着等(cpu_data_stall)。
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
    assign data_req = cpu_data_en & ~addr_rcv & ~do_finish; // 给桥
    assign data_wr = cpu_data_en & |cpu_data_wen;
    assign data_size = (cpu_data_wen==4'b0001 || cpu_data_wen==4'b0010 || cpu_data_wen==4'b0100 || cpu_data_wen==4'b1000) ? 2'b00:
                       (cpu_data_wen==4'b0011 || cpu_data_wen==4'b1100 ) ? 2'b01 : 2'b10;
    assign data_addr = cpu_data_addr;
    assign data_wdata = cpu_data_wdata;

    // sram
    assign cpu_data_rdata = data_rdata_save;
    assign cpu_data_stall = cpu_data_en & ~do_finish; // 让CPU等
    
endmodule
