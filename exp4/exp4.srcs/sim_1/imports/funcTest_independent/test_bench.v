`timescale 1ns / 1ps

module mips_min_tb();

reg clock_50;
reg rst;


wire [31:0] instr, pc;
wire [31:0] writedata,dataadr;
wire memwrite;

top dut(
    clock_50,
    rst,
    instr, 
    pc, 
    writedata, 
    dataadr, 
    memwrite
);

initial begin
    clock_50 = 1'b0;
    forever # 10 clock_50 = ~clock_50;
end

initial begin
    rst = 1;
    #200 rst= 0;
    #50000 $stop;
end

endmodule
