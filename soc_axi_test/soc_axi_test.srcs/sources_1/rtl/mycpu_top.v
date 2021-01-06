`timescale 1ns / 1ps

module mycpu_top(
    input wire [5:0] int,

    input wire aclk     ,
    input wire aresetn  ,

    output wire [3 :0] arid     ,
    output wire [31:0] araddr   ,
    output wire [3 :0] arlen    ,
    output wire [2 :0] arsize   ,
    output wire [1 :0] arburst  ,
    output wire [1 :0] arlock   ,
    output wire [3 :0] arcache  ,
    output wire [2 :0] arprot   ,
    output wire        arvalid  ,
    input  wire        arready  ,

    input  wire [3 :0] rid      ,
    input  wire [31:0] rdata    ,
    input  wire [1 :0] rresp    ,
    input  wire        rlast    ,
    input  wire        rvalid   ,
    output wire        rready   ,

    output wire [3 :0] awid     ,
    output wire [31:0] awaddr   ,
    output wire [3 :0] awlen    ,
    output wire [2 :0] awsize   ,
    output wire [1 :0] awburst  ,
    output wire [1 :0] awlock   ,
    output wire [3 :0] awcache  ,
    output wire [2 :0] awprot   ,
    output wire        awvalid  ,
    input  wire        awready  ,

    output wire [3 :0] wid      ,
    output wire [31:0] wdata    ,
    output wire [3 :0] wstrb    ,
    output wire        wlast    ,
    output wire        wvalid   ,
    input  wire        wready   ,

    input  wire [3 :0] bid      ,
    input  wire [1 :0] bresp    ,
    input  wire        bvalid   ,
    output wire        bready   ,

    // debug interface
    output wire [31:0] debug_wb_pc      ,
    output wire [3 :0] debug_wb_rf_wen  ,
    output wire [4 :0] debug_wb_rf_wnum ,
    output wire [31:0] debug_wb_rf_wdata

    );
    //cpu inst sram
    wire        cpu_inst_en     ;
    wire [3 :0] cpu_inst_wen    ;
    wire [31:0] cpu_inst_addr   ;
    wire [31:0] cpu_inst_wdata  ;
    wire [31:0] cpu_inst_rdata  ;
    //cpu data sram
    wire        cpu_data_en     ;
    wire [3 :0] cpu_data_wen    ;
    wire [31:0] cpu_data_addr   ;
    wire [31:0] cpu_data_wdata  ;
    wire [31:0] cpu_data_rdata  ;

    // stall
    wire cpu_longest_stall;     // from cpu
    wire cpu_inst_stall;        // to cpu
    wire cpu_data_stall;        // to cpu

    //debug signals
    /*wire [31:0] debug_wb_pc;
    wire [3 :0] debug_wb_rf_wen;
    wire [4 :0] debug_wb_rf_wnum;
    wire [31:0] debug_wb_rf_wdata;*/
    //cpu
    mips_top cpu(
        .clk              (aclk         ),      // (in, 1) 注意时钟反转
        .resetn           (~aresetn      ),     // (in, 1) low active
        .int              (int           ),     // (in, 6) interrupt,high active

        .longest_stall    (cpu_longest_stall),  // (out, 1)

        .inst_sram_en     (cpu_inst_en   ),     // (out, 1)
        .inst_sram_wen    (cpu_inst_wen  ),     // (out, 4)
        .inst_sram_addr   (cpu_inst_addr ),     // (out,32)
        .inst_sram_wdata  (cpu_inst_wdata),     // (out,32)
        .inst_sram_rdata  (cpu_inst_rdata),     // (in, 32) 
        .inst_stall       (cpu_inst_stall),     // (in, 1)
        
        .data_sram_en     (cpu_data_en   ),     // (out, 1)
        .data_sram_wen    (cpu_data_wen  ),     // (out, 4)
        .data_sram_addr   (cpu_data_addr ),     // (out,32)
        .data_sram_wdata  (cpu_data_wdata),     // (out,32)
        .data_sram_rdata  (cpu_data_rdata),     // (in, 32)
        .data_stall       (cpu_data_stall),     // (in, 1)
        //debug
        .debug_wb_pc      (debug_wb_pc      ),  // (out,32)
        .debug_wb_rf_wen  (debug_wb_rf_wen  ),  // (out, 4)
        .debug_wb_rf_wnum (debug_wb_rf_wnum ),  // (out, 5)
        .debug_wb_rf_wdata(debug_wb_rf_wdata)   // (out,32)
    );

    // cache
    // inst sram-like 
    // inst_sram_like to bridge
    wire        cache_inst_req     ;
    wire        cache_inst_wr      ;
    wire [1 :0] cache_inst_size    ;
    wire [31:0] cache_inst_addr    ;
    wire [31:0] cache_inst_wdata   ;

    // bridge to inst_sram_like
    wire [31:0] cache_inst_rdata   ;
    wire        cache_inst_addr_ok ;
    wire        cache_inst_data_ok ;
    // data sram-like 
    // data_sram_like to bridge
    wire        cache_data_req     ;
    wire        cache_data_wr      ;
    wire [1 :0] cache_data_size    ;
    wire [31:0] cache_data_addr    ;
    wire [31:0] cache_data_wdata   ;
    // bridge to data_sram_like
    wire [31:0] cache_data_rdata   ;
    wire        cache_data_addr_ok ;
    wire        cache_data_data_ok ;

    cache cache(
        .clk(aclk),
        .rst(~aresetn),
        // inst sram
        // input from cpu
        .cpu_inst_en   (cpu_inst_en   ), //in
        .cpu_inst_wen  (cpu_inst_wen  ), //in
        .cpu_inst_addr (cpu_inst_addr ), //in
        .cpu_inst_wdata(cpu_inst_wdata), //in
        .cpu_inst_rdata(cpu_inst_rdata), //out
        .cpu_inst_stall(cpu_inst_stall), //out
        .cpu_longest_stall(cpu_longest_stall), //in
        // data sram
        .cpu_data_en   (cpu_data_en   ), //in
        .cpu_data_wen  (cpu_data_wen  ), //in
        .cpu_data_addr (cpu_data_addr ), //in
        .cpu_data_wdata(cpu_data_wdata), //in
        .cpu_data_rdata(cpu_data_rdata), //out
        .cpu_data_stall(cpu_data_stall), //out
        // .cpu_longest_stall(cpu_longest_stall),//in

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
        .cache_data_req    (cache_data_req    ), //out
        .cache_data_wr     (cache_data_wr     ), //out
        .cache_data_size   (cache_data_size   ), //out
        .cache_data_addr   (cache_data_addr   ), //out
        .cache_data_wdata  (cache_data_wdata  ), //out
        // input from axi bridge
        .cache_data_rdata  (cache_data_rdata  ), //in
        .cache_data_addr_ok(cache_data_addr_ok), //in
        .cache_data_data_ok(cache_data_data_ok) //in
    );

    ///////////////////////////////////////////////////////////////
    cpu_axi_interface cpu_axi_interface(
    .clk(aclk),
    .resetn(aresetn), 
    // inst sram-like
    // input from cache
    .inst_req    (cache_inst_req    ), // in
    .inst_wr     (cache_inst_wr     ), // in
    .inst_size   (cache_inst_size   ), // in
    .inst_addr   (cache_inst_addr   ), // in
    .inst_wdata  (cache_inst_wdata  ), // in
    // output to cache
    .inst_rdata  (cache_inst_rdata  ), // out
    .inst_addr_ok(cache_inst_addr_ok), // out
    .inst_data_ok(cache_inst_data_ok), // out
        
    // data sram-like 
    // input from cache
    .data_req    (cache_data_req    ), // in
    .data_wr     (cache_data_wr     ), // in
    .data_size   (cache_data_size   ), // in
    .data_addr   (cache_data_addr   ), // in
    .data_wdata  (cache_data_wdata  ), // in
    // output to cache
    .data_rdata  (cache_data_rdata  ), // out
    .data_addr_ok(cache_data_addr_ok), // out
    .data_data_ok(cache_data_data_ok), // out

    // axi
    // ar
    .arid   (arid   ),
    .araddr (araddr ),
    .arlen  (arlen  ),
    .arsize (arsize ),
    .arburst(arburst),
    .arlock (arlock ),
    .arcache(arcache),
    .arprot (arprot ),
    .arvalid(arvalid),
    .arready(arready),
    // r           
    .rid   (rid   ),
    .rdata (rdata ),
    .rresp (rresp ),
    .rlast (rlast ),
    .rvalid(rvalid),
    .rready(rready),
    // aw          
    .awid   (awid   ),
    .awaddr (awaddr ),
    .awlen  (awlen  ),
    .awsize (awsize ),
    .awburst(awburst),
    .awlock (awlock ),
    .awcache(awcache),
    .awprot (awprot ),
    .awvalid(awvalid),
    .awready(awready),
    // w          
    .wid   (wid   ),
    .wdata (wdata ),
    .wstrb (wstrb ),
    .wlast (wlast ),
    .wvalid(wvalid),
    .wready(wready),
    // b           
    .bid   (bid   ),
    .bresp (bresp ),
    .bvalid(bvalid),
    .bready(bready)
);

endmodule
