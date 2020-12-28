module floprc #(parameter WIDTH = 8)
               (input wire clk, rst, clear,
                input wire [WIDTH -1:0] d,
                output reg [WIDTH -1:0] q);
    
    always @(posedge clk , posedge rst) begin
        if (rst) begin
            q <= 0;
        end else if (clear) begin
            q <= 0;
        end else begin
            q <= d ;
        end
    end

endmodule
