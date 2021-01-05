module mulWrapper(input clk, rst,
                  input clear,
                  input [31:0] a,
                  input [31:0] b,
                  input [ 7:0] op,
                  output [63:0] mul_result,
                  output reg mulstall //乘法发出的stall信号
                  );

    wire mul_ready;
    reg mul_en;
    reg mul_start;
    reg mul_sign;
    reg mul_refresh;
    reg [31:0] mula, mulb; // 存一手，防止下周期被flush

    always @(posedge clk) begin
        if (rst | clear) begin
            mula <= 32'b0;
            mulb <= 32'b0;
        end else begin
            if (!mul_ready) begin
                mula <= a;
                mulb <= b;
            end
        end
    end

    mul_ip mul_ip(
        .clk(clk),
        .rst(rst),
        .signed_i(mul_sign),
        .a(mula),
        .b(mulb),
        .en(mul_en),
        .start_i(mul_start),
        .clear_i(mul_refresh | clear),
        .result_o(mul_result),
        .ready_o(mul_ready)
    );

    always @(*) begin
        if (rst | clear) begin
            mul_sign    <= 1'b0;
            mul_en      <= 1'b0;
            mul_start   <= 1'b0;
            mulstall    <= 1'b0;
            mul_refresh <= 1'b0;
        end else begin
            case (op)
                `EXE_MULT_OP: begin
                    if (!mul_ready) begin
                        mul_sign    <= 1'b1;
                        mul_en      <= 1'b1;
                        mul_start   <= 1'b1;
                        mulstall    <= 1'b1;
                        mul_refresh <= 1'b0;
                    end else if(mul_ready) begin
                        mul_start   <= 1'b0;
                        mulstall    <= 1'b0;
                        mul_refresh <= 1'b1;
                    end
                end
                `EXE_MULTU_OP: begin
                    if (!mul_ready) begin
                        mul_sign    <= 1'b0;
                        mul_en      <= 1'b1;
                        mul_start   <= 1'b1;
                        mulstall    <= 1'b1;
                        mul_refresh <= 1'b0;
                    end else if (mul_ready) begin
                        mul_start   <= 1'b0;
                        mulstall    <= 1'b0;
                        mul_refresh <= 1'b1;
                    end
                end
                default: begin
                    mul_sign    <= 1'b0;
                    mul_en      <= 1'b0;
                    mul_start   <= 1'b0;
                    mulstall    <= 1'b0;
                    mul_refresh <= 1'b0;
                end
            endcase
        end
    end



endmodule



