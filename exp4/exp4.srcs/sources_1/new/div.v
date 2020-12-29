`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/29 19:59:51
// Design Name: 
// Module Name: div
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
//参考硬综2019PPT1第36页定义
//divident 被除数    divisor 除数    quotient 商     remainder 余数
module div(
    input               clk,
    input               rst,
    input [31:0]        a,
    input [31:0]        b,
    input               start,
    input               sign,
    output wire         stall_div,
    output [63:0]       result
    );

    reg [31:0] a_tmp,b_tmp;
    reg [63:0] SR; //shift register
    reg [32 :0] NEG_DIVISOR;  //divisor 2's complement
    wire [31:0] REMAINER, QUOTIENT;
    assign REMAINER = SR[63:32];
    assign QUOTIENT = SR[31: 0];

    wire [31:0] divident_abs;
    wire [32:0] divisor_abs;
    wire [31:0] remainer, quotient;

    assign divident_abs = (sign & a[31]) ? ~a + 1'b1 : a;
    //余数符号与被除数相同
    assign remainer = (sign & a_tmp[31]) ? ~REMAINER + 1'b1 : REMAINER;
    assign quotient = sign & (a_tmp[31] ^ b_tmp[31]) ? ~QUOTIENT + 1'b1 : QUOTIENT;
    assign result = {remainer,quotient};

    wire CO;
    wire [32:0] sub_result;
    wire [32:0] mux_result;
    
    assign {CO,sub_result} = {1'b0,REMAINER} + NEG_DIVISOR;//sub
    assign mux_result = CO ? sub_result : {1'b0,REMAINER};//mux

    //状态机
    reg [5:0] cnt;
    reg start_cnt;
    always @(posedge clk, posedge rst) begin
        if(rst) begin
            cnt <= 0;
            start_cnt <= 0;
        end
        else if(!start_cnt & start) begin
            cnt <= 1;
            start_cnt <= 1;
            //Register init
            a_tmp<=a;
            b_tmp<=b;
            SR[63:0] <= {31'b0,divident_abs,1'b0}; //左移1bit
            NEG_DIVISOR <= (sign & b[31]) ? {1'b1,b} : ~{1'b0,b} + 1'b1; 
        end
        else if(start_cnt) begin
            if(cnt==32) begin
                cnt <= 0;
                start_cnt <= 0;
                //输出结果
                SR[63:32] <= mux_result[31:0];
                SR[31:0] <= {SR[30:0],CO};
            end
            else begin
                cnt <= cnt + 1;
                SR[63:0] <= {mux_result[30:0],SR[31:0],CO}; // 写，左移
            end
        end
    end
    assign stall_div = |cnt; //只有当cnt=0时不暂停
endmodule