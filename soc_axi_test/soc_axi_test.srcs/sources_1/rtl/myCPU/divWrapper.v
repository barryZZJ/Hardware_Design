`timescale 1ns / 1ps
`include "defines.vh"
module divWrapper(input clk, rst,
                  input clear,
                  input [31:0] a,
                  input [31:0] b,
                  input [ 7:0] op,
                  output [63:0] div_result,
                  output reg divstall //除法发出的stall信号
                  );
    
    wire div_ready;
    reg  div_start;
    reg  div_sign;
    reg  div_refresh;
    
    div div(
        .clk(clk),
        .rst(rst),
        .Signed_div_i(div_sign),
        .Opdata1_i(a),
        .Opdata2_i(b),
        .start_i(div_start),
        .annul_i(div_refresh | clear),
        .result_o(div_result),
        .ready_o(div_ready)
    );
    
    always@(*) begin
        if (rst) begin
            div_start   <= 1'b0;
            div_sign    <= 1'b0;
            div_refresh <= 1'b0;
            divstall    <= 1'b0;
        end else begin
            if (clear) begin
                div_sign    <= 0;
                div_start   <= 0;
                divstall    <= 0;
                div_refresh <= 0;
            end else begin
                case(op)
                    //有符号除法
                    `EXE_DIV_OP: begin
                        //状态机
                        if (!div_ready) begin
                            div_sign    <= 1;
                            div_start   <= 1;
                            divstall    <= 1;
                            div_refresh <= 0;
                        end else if (div_ready) begin
                            div_sign    <= 0;
                            div_start   <= 0;
                            divstall    <= 0;
                            div_refresh <= 1;
                        end
                    end

                    //无符号除法
                    `EXE_DIVU_OP:begin
                        //状态机
                        if (!div_ready) begin
                            div_sign    <= 0;
                            div_start   <= 1;
                            divstall    <= 1;
                            div_refresh <= 0;
                        end else if (div_ready) begin
                            div_sign    <= 0;
                            div_start   <= 0;
                            divstall    <= 0;
                            div_refresh <= 1;
                        end
                    end

                    default: begin
                        div_start   <= 1'b0;
                        div_sign    <= 1'b0;
                        div_refresh <= 1'b0;
                        divstall    <= 1'b0;
                    end 
                endcase
            end
        end
    end
    
endmodule
