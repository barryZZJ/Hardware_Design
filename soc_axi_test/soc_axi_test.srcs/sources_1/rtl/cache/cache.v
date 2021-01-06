module cache (
    input wire clk, rst,

    // inst sram
    // input from cpu
    input wire        cpu_inst_en   ,
    input wire [3 :0] cpu_inst_wen  ,       // no use
    input wire [31:0] cpu_inst_addr ,
    input wire [31:0] cpu_inst_wdata,       // no use
    input wire        cpu_longest_stall,
    // output to cpu
    output wire [31:0] cpu_inst_rdata,
    output wire        cpu_inst_stall,
    
    // data sram
    // input from cpu
    input wire        cpu_data_en   ,
    input wire [3 :0] cpu_data_wen  ,
    input wire [31:0] cpu_data_addr ,
    input wire [31:0] cpu_data_wdata,
    // input wire        cpu_longest_stall,
    // output to cpu
    output wire [31:0] cpu_data_rdata,
    output wire        cpu_data_stall,

    input wire         no_dcache,
    // inst sram-like
    // output to axi bridge
    output wire        cache_inst_req    ,
    output wire        cache_inst_wr     ,        // no use
    output wire [1 :0] cache_inst_size   ,        // no use
    output wire [31:0] cache_inst_addr   ,
    output wire [31:0] cache_inst_wdata  ,        // no use
    // input from axi bridge
    input wire [31:0] cache_inst_rdata   ,
    input wire        cache_inst_addr_ok ,
    input wire        cache_inst_data_ok ,

    // data sram-like
    // output to axi bridge
    output wire        cache_data_req    ,
    output wire        cache_data_wr     ,
    output wire [1 :0] cache_data_size   ,
    output wire [31:0] cache_data_addr   ,
    output wire [31:0] cache_data_wdata  ,
    // data
    input wire [31:0] cache_data_rdata   ,
    input wire        cache_data_addr_ok ,
    input wire        cache_data_data_ok 
);

    inst_cache inst_cache(
        .clk(clk), .rst(rst),
        .cpu_inst_en        (cpu_inst_en      ),
        .cpu_inst_wen       (cpu_inst_wen     ),
        .cpu_inst_addr      (cpu_inst_addr    ),
        .cpu_inst_wdata     (cpu_inst_wdata   ),
        .cpu_longest_stall  (cpu_longest_stall),
        .cpu_inst_rdata     (cpu_inst_rdata   ),
        .cpu_inst_stall     (cpu_inst_stall   ),
        // .cpu_inst_addr_ok (cpu_inst_addr_ok ),
        // .cpu_inst_data_ok (cpu_inst_data_ok ),

        .cache_inst_req     (cache_inst_req     ),
        .cache_inst_wr      (cache_inst_wr      ),
        .cache_inst_size    (cache_inst_size    ),
        .cache_inst_addr    (cache_inst_addr    ),
        .cache_inst_wdata   (cache_inst_wdata   ),
        .cache_inst_rdata   (cache_inst_rdata   ),
        .cache_inst_addr_ok (cache_inst_addr_ok ),
        .cache_inst_data_ok (cache_inst_data_ok )
    );

    data_cache data_cache(
        .clk(clk), .rst(rst),
        .cpu_data_en(cpu_data_en),
        .cpu_data_wen(cpu_data_wen),
        // .cpu_data_req     (cpu_data_req     ),
        // .cpu_data_wr      (cpu_data_wr      ),
        // .cpu_data_size    (cpu_data_size    ),
        .cpu_data_addr       (cpu_data_addr    ),
        .cpu_data_wdata      (cpu_data_wdata   ),
        .cpu_longest_stall   (cpu_longest_stall),
        .cpu_data_rdata      (cpu_data_rdata   ),
        .cpu_data_stall      (cpu_data_stall   ),
        // .cpu_data_addr_ok (cpu_data_addr_ok ),
        // .cpu_data_data_ok (cpu_data_data_ok ),
        .no_dcache          (no_dcache          ),
        .cache_data_req     (cache_data_req     ),
        .cache_data_wr      (cache_data_wr      ),
        .cache_data_size    (cache_data_size    ),
        .cache_data_addr    (cache_data_addr    ),
        .cache_data_wdata   (cache_data_wdata   ),
        .cache_data_rdata   (cache_data_rdata   ),
        .cache_data_addr_ok (cache_data_addr_ok ),
        .cache_data_data_ok (cache_data_data_ok )
    );
endmodule