`timescale 1ns / 1ps

module mycpu_sramlikecache_top(
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
    wire no_dcache;
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
        .no_dcache        (no_dcache     ),
        .data_sram_rdata  (cpu_data_rdata),     // (in, 32)
        .data_stall       (cpu_data_stall),     // (in, 1)
        //debug
        .debug_wb_pc      (debug_wb_pc      ),  // (out,32)
        .debug_wb_rf_wen  (debug_wb_rf_wen  ),  // (out, 4)
        .debug_wb_rf_wnum (debug_wb_rf_wnum ),  // (out, 5)
        .debug_wb_rf_wdata(debug_wb_rf_wdata)   // (out,32)
    );

    ///////////////////////////////////////////////////////////////
    // inst sram-like 
    // inst_sram_like to cache
    wire        inst_req     ;
    wire        inst_wr      ;
    wire [1 :0] inst_size    ;
    wire [31:0] inst_addr    ;
    wire [31:0] inst_wdata   ;

    // cache to inst_sram_like
    wire [31:0] inst_rdata   ;
    wire        inst_addr_ok ;
    wire        inst_data_ok ;

    inst_sram_like inst_sram_like(
        .clk(aclk),
        .rst(~aresetn),
        // cpu
        .cpu_inst_en   (cpu_inst_en   ),
        .cpu_inst_wen  (cpu_inst_wen  ),
        .cpu_inst_addr (cpu_inst_addr ),
        .cpu_inst_wdata(cpu_inst_wdata),
        .cpu_inst_rdata(cpu_inst_rdata),
        .cpu_inst_stall(cpu_inst_stall),
        .cpu_longest_stall(cpu_longest_stall),
        // to cache
        .inst_req    (inst_req    ),
        .inst_wr     (inst_wr     ),
        .inst_size   (inst_size   ),
        .inst_addr   (inst_addr   ),
        .inst_wdata  (inst_wdata  ),
        .inst_rdata  (inst_rdata  ),
        .inst_addr_ok(inst_addr_ok),
        .inst_data_ok(inst_data_ok)
    );

    ///////////////////////////////////////////////////////////////
    // data sram-like 
    // data_sram_like to cache
    wire        data_req     ;
    wire        data_wr      ;
    wire [1 :0] data_size    ;
    wire [31:0] data_addr    ;
    wire [31:0] data_wdata   ;
    // cache to data_sram_like
    wire [31:0] data_rdata   ;
    wire        data_addr_ok ;
    wire        data_data_ok ;

    data_sram_like data_sram_like(
        .clk(aclk),
        .rst(~aresetn),
        // cpu
        .cpu_data_en   (cpu_data_en   ),
        .cpu_data_wen  (cpu_data_wen  ),
        .cpu_data_addr (cpu_data_addr ),
        .cpu_data_wdata(cpu_data_wdata),
        .cpu_data_rdata(cpu_data_rdata),
        .cpu_data_stall(cpu_data_stall),
        .cpu_longest_stall(cpu_longest_stall),
        // to cache
        .data_req    (data_req    ),
        .data_wr     (data_wr     ),
        .data_size   (data_size   ),
        .data_addr   (data_addr   ),
        .data_wdata  (data_wdata  ),
        .data_rdata  (data_rdata  ),
        .data_addr_ok(data_addr_ok),
        .data_data_ok(data_data_ok)
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
    wire        tobridge_data_req     ;
    wire        tobridge_data_wr      ;
    wire [1 :0] tobridge_data_size    ;
    wire [31:0] tobridge_data_addr    ;
    wire [31:0] tobridge_data_wdata   ;
    // bridge to data_sram_like
    wire [31:0] frombridge_data_rdata   ;
    wire        frombridge_data_addr_ok ;
    wire        frombridge_data_data_ok ;

    cachemux cachemux(
        .clk(aclk), // FIXME
        .rst(~aresetn),
        .no_dcache(no_dcache),
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
        .data_req  (data_req   ), //in
        .data_wr   (data_wr  ), //in
        .data_size (data_size ), //in
        .data_addr (data_addr ), //in
        .data_wdata(data_wdata), //in
        .data_rdata(data_rdata), //out
        .data_addr_ok(data_addr_ok),
        .data_data_ok(data_data_ok),

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
        .tobridge_data_req    (tobridge_data_req    ), //out
        .tobridge_data_wr     (tobridge_data_wr     ), //out
        .tobridge_data_size   (tobridge_data_size   ), //out
        .tobridge_data_addr   (tobridge_data_addr   ), //out
        .tobridge_data_wdata  (tobridge_data_wdata  ), //out
        // input from axi bridge
        .frombridge_data_rdata  (frombridge_data_rdata  ), //in
        .frombridge_data_addr_ok(frombridge_data_addr_ok), //in
        .frombridge_data_data_ok(frombridge_data_data_ok) //in
    );

    ///////////////////////////////////////////////////////////////

    cpu_axi_interface cpu_axi_interface(
    .clk(aclk),
    .resetn(aresetn), 
    // inst
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
        
    // data
    // input from cache or data sram-like
    .data_req    (tobridge_data_req    ), // in
    .data_wr     (tobridge_data_wr     ), // in
    .data_size   (tobridge_data_size   ), // in
    .data_addr   (tobridge_data_addr   ), // in
    .data_wdata  (tobridge_data_wdata  ), // in
    // output to cache or data sram-like
    .data_rdata  (frombridge_data_rdata  ), // out
    .data_addr_ok(frombridge_data_addr_ok), // out
    .data_data_ok(frombridge_data_data_ok), // out
    // cpu_axi_interface cpu_axi_interface(
    // .clk(aclk),
    // .resetn(aresetn), 
    // // inst sram-like 
    // .inst_req    (inst_req    ),
    // .inst_wr     (inst_wr     ),
    // .inst_size   (inst_size   ),
    // .inst_addr   (inst_addr   ),
    // .inst_wdata  (inst_wdata  ),
    // .inst_rdata  (inst_rdata  ),
    // .inst_addr_ok(inst_addr_ok),
    // .inst_data_ok(inst_data_ok),
        
    // // data sram-like 
    // .data_req    (data_req    ),
    // .data_wr     (data_wr     ),
    // .data_size   (data_size   ),
    // .data_addr   (data_addr   ),
    // .data_wdata  (data_wdata  ),
    // .data_rdata  (data_rdata  ),
    // .data_addr_ok(data_addr_ok),
    // .data_data_ok(data_data_ok),

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
