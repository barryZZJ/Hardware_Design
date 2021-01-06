module cachemux (
    input wire clk, rst,
    input no_dcache,
    //mips core
    input         inst_req     ,
    input         inst_wr      ,
    input  [1 :0] inst_size    ,
    input  [31:0] inst_addr    ,
    input  [31:0] inst_wdata   ,
    output [31:0] inst_rdata   ,
    output        inst_addr_ok ,
    output        inst_data_ok ,

    input         data_req     ,
    input         data_wr      ,
    input  [1 :0] data_size    ,
    input  [31:0] data_addr    ,
    input  [31:0] data_wdata   ,
    output [31:0] data_rdata   ,
    output        data_addr_ok ,
    output        data_data_ok ,

    //axi interface
    output         cache_inst_req     ,
    output         cache_inst_wr      ,
    output  [1 :0] cache_inst_size    ,
    output  [31:0] cache_inst_addr    ,
    output  [31:0] cache_inst_wdata   ,
    input   [31:0] cache_inst_rdata   ,
    input          cache_inst_addr_ok ,
    input          cache_inst_data_ok ,

    // data mux
    // cache or data sram-like to bridge
    output         tobridge_data_req     ,
    output         tobridge_data_wr      ,
    output  [1 :0] tobridge_data_size    ,
    output  [31:0] tobridge_data_addr    ,
    output  [31:0] tobridge_data_wdata   ,
    // bridge to cache or data sram-like
    input   [31:0] frombridge_data_rdata   ,
    input          frombridge_data_addr_ok ,
    input          frombridge_data_data_ok
);

    // cpu to cache
    wire        tocache_data_req   = no_dcache ? 1'b0 : data_req;
    wire        tocache_data_wr    = no_dcache ? 1'b0 : data_wr;
    wire [1 :0] tocache_data_size  = no_dcache ? 2'b0 : data_size;
    wire [31:0] tocache_data_addr  = no_dcache ? 32'b0 : data_addr;
    wire [31:0] tocache_data_wdata = no_dcache ? 32'b0 : data_wdata;

    wire        cachetobridge_data_req  ;
    wire        cachetobridge_data_wr   ;
    wire [ 1:0] cachetobridge_data_size ;
    wire [31:0] cachetobridge_data_addr ;
    wire [31:0] cachetobridge_data_wdata;

    // 去桥
    assign tobridge_data_req = no_dcache ? data_req : cachetobridge_data_req;
    assign tobridge_data_wr = no_dcache ? data_wr : cachetobridge_data_wr;
    assign tobridge_data_size = no_dcache ? data_size : cachetobridge_data_size;
    assign tobridge_data_addr = no_dcache ? data_addr : cachetobridge_data_addr;
    assign tobridge_data_wdata = no_dcache ? data_wdata : cachetobridge_data_wdata;

    // 桥回来，回CPU
    // 连cache
    // 从cache回来到CPU
    wire [31:0] fromcache_data_rdata;
    wire        fromcache_data_addr_ok;
    wire        fromcache_data_data_ok;
    //绕过cache
    assign data_rdata  = no_dcache ? frombridge_data_rdata : fromcache_data_rdata;
    assign data_addr_ok = no_dcache ? frombridge_data_addr_ok : fromcache_data_addr_ok;
    assign data_data_ok = no_dcache ? frombridge_data_data_ok : fromcache_data_data_ok;



    sramlikecache sramlikecache(
        .clk(clk), // FIXME
        .rst(rst),
        // inst sramlike
        // input from cpu
        .inst_req  (inst_req   ), //in
        .inst_wr   (inst_wr  ), //in
        .inst_size (inst_size ), //in
        .inst_addr (inst_addr),
        .inst_wdata(inst_wdata), //in
        .inst_rdata(inst_rdata), //out
        .inst_addr_ok(inst_addr_ok),
        .inst_data_ok(inst_data_ok),
        // data sramlike
        .data_req  (tocache_data_req   ), //in
        .data_wr   (tocache_data_wr  ), //in
        .data_size (tocache_data_size ), //in
        .data_addr (tocache_data_addr ), //in
        .data_wdata(tocache_data_wdata), //in
        .data_rdata(fromcache_data_rdata), //out
        .data_addr_ok(fromcache_data_addr_ok), //out
        .data_data_ok(fromcache_data_data_ok), //out

        // inst sram-like
        // output to axi bridge
        .cache_inst_req    (cache_inst_req    ), //out
        .cache_inst_wr     (cache_inst_wr     ), //out
        .cache_inst_size   (cache_inst_size   ), //out
        .cache_inst_addr   (cache_inst_addr   ), //out
        .cache_inst_wdata  (cache_inst_wdata  ), //out
        // input from axi bridge
        .cache_inst_rdata  (cache_inst_rdata  ), //in
        .cache_inst_addr_ok(cache_inst_addr_ok), //in
        .cache_inst_data_ok(cache_inst_data_ok), //in

        // data sram-like
        // output to axi bridge
        // bridge ports
        .cache_data_req    (cachetobridge_data_req    ), //out
        .cache_data_wr     (cachetobridge_data_wr     ), //out
        .cache_data_size   (cachetobridge_data_size   ), //out
        .cache_data_addr   (cachetobridge_data_addr   ), //out
        .cache_data_wdata  (cachetobridge_data_wdata  ), //out
        // input from axi bridge
        .cache_data_rdata  (no_dcache ? 32'b0 : frombridge_data_rdata  ), //in
        .cache_data_addr_ok(no_dcache ? 1'b0 : frombridge_data_addr_ok), //in
        .cache_data_data_ok(no_dcache ? 1'b0 : frombridge_data_data_ok) //in
    );
    




endmodule