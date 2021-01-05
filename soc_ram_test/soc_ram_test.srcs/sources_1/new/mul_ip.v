`timescale 1ns / 1ps
`include "defines.vh"
module mul_ip #(STAGES = 9)
              (input clk, rst,
               input signed_i,
               input [31:0] a, b,
               input en,
               input start_i, clear_i,
               output [63:0] result_o,
               output reg ready_o
               );

wire mul_signed_en, mul_unsigned_en;
assign mul_signed_en = en & signed_i;
assign mul_unsigned_en = en & ~signed_i;

// 乘法器ip核定义计算需要9个cycle
reg [3:0] cnt;

wire [63:0] mul_result_signed, mul_result_unsigned;
assign result_o = signed_i ? mul_result_signed : mul_result_unsigned;

//状态
reg [1:0] main_state;

always @(posedge clk) begin
    if (rst | clear_i) begin
        cnt             <= 4'b0;
        main_state      <= 2'b0;
        ready_o         <= 1'b0;
    end else if (start_i) begin
        case(main_state)
        2'b00: begin
            main_state      <= 2'b01;
        end
        2'b01 : begin
            //TODO
            if (cnt == STAGES-1) begin
                ready_o <= 1'b1;
                main_state <= 2'b10;
            end
            cnt = cnt + 1;
        end
        endcase
    end
end

// 使用IP核
// 操作数能自动锁住
mul_signed mul_signed(
    .CLK(clk),
    .A(a),
    .B(b),
    .CE(mul_signed_en), // enable
    .SCLR(clear_i),  // sync clear
    .P(mul_result_signed)
);

mul_unsigned mul_unsigned(
    .CLK(clk),
    .A(a),
    .B(b),
    .CE(mul_unsigned_en),
    .SCLR(clear_i),
    .P(mul_result_unsigned)
);


endmodule
