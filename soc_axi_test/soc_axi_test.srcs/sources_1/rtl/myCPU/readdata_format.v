`timescale 1ns / 1ps
`include "defines.vh"
module readdata_format(input [7:0] op,
                       input [1:0] addr,
                       input [31:0] readdata,
                       output reg [31:0] finalreaddata);

// 大端读写，高位在低地址
always @(*) begin
	case(op)
        `EXE_LW_OP: finalreaddata <= readdata;
        `EXE_LH_OP: begin
            case (addr[1:0])
                2'b00 : finalreaddata <= {{16{readdata[15]}}, readdata[15: 0]};
                2'b10 : finalreaddata <= {{16{readdata[31]}}, readdata[31:16]};
                default: finalreaddata <= 32'bx;
            endcase
        end
        `EXE_LHU_OP: begin
            case (addr[1:0])
                2'b00 : finalreaddata <= {16'b0, readdata[15: 0]};
                2'b10 : finalreaddata <= {16'b0, readdata[31:16]};
                default: finalreaddata <= 32'bx;
            endcase
        end
        `EXE_LB_OP: begin
            case (addr[1:0])
                2'b00: finalreaddata <= {{24{readdata[ 7]}}, readdata[ 7: 0]};
                2'b01: finalreaddata <= {{24{readdata[15]}}, readdata[15: 8]};
                2'b10: finalreaddata <= {{24{readdata[23]}}, readdata[23:16]};
                2'b11: finalreaddata <= {{24{readdata[31]}}, readdata[31:24]};
                default: finalreaddata <= 32'bx;
            endcase
        end
        `EXE_LBU_OP: begin
            case (addr[1:0])
                2'b00: finalreaddata <= {24'b0, readdata[ 7: 0]};
                2'b01: finalreaddata <= {24'b0, readdata[15: 8]};
                2'b10: finalreaddata <= {24'b0, readdata[23:16]};
                2'b11: finalreaddata <= {24'b0, readdata[31:24]};
                default: finalreaddata <= 32'bx;
            endcase
        end
        default: finalreaddata <= 32'bx; 
    endcase
end


endmodule
