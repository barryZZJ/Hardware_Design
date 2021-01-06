module inst_cache (
    input wire clk, rst,
    // sram, from cpu
    input wire         cpu_inst_en   , //* new 读，一直高电平。
    input wire [3 :0]  cpu_inst_wen  , //* new, 4'b0, no use 一直维持
    input wire [31:0]  cpu_inst_addr , //* 一直维持。
    input wire [31:0]  cpu_inst_wdata, // 32'b0
    input wire         cpu_longest_stall, //* new
    output wire [31:0] cpu_inst_rdata,
    output wire        cpu_inst_stall, //* new，如果cache命中就不用stall，如果没命中要一直等到mem返回数据。
    // input         cpu_inst_req     ,
    // input         cpu_inst_wr      ,
    // input  [1 :0] cpu_inst_size    ,
    // output        cpu_inst_addr_ok ,
    // output        cpu_inst_data_ok ,

    //axi interface
    output         cache_inst_req     ,
    output         cache_inst_wr      ,
    output  [1 :0] cache_inst_size    ,
    output  [31:0] cache_inst_addr    ,
    output  [31:0] cache_inst_wdata   ,
    input   [31:0] cache_inst_rdata   ,
    input          cache_inst_addr_ok ,
    input          cache_inst_data_ok 
);
    //Cache配置
    parameter  INDEX_WIDTH  = 10, OFFSET_WIDTH = 2;
    localparam TAG_WIDTH    = 32 - INDEX_WIDTH - OFFSET_WIDTH;
    localparam CACHE_DEEPTH = 1 << INDEX_WIDTH;
    
    //Cache存储单元
    reg                 cache_valid [CACHE_DEEPTH - 1 : 0];
    reg [TAG_WIDTH-1:0] cache_tag   [CACHE_DEEPTH - 1 : 0];
    reg [31:0]          cache_block [CACHE_DEEPTH - 1 : 0];

    //访问地址分解
    wire [OFFSET_WIDTH-1:0] offset;
    wire [INDEX_WIDTH-1:0] index;
    wire [TAG_WIDTH-1:0] tag;
    
    assign offset = cpu_inst_addr[OFFSET_WIDTH - 1 : 0];
    assign index = cpu_inst_addr[INDEX_WIDTH + OFFSET_WIDTH - 1 : OFFSET_WIDTH];
    assign tag = cpu_inst_addr[31 : INDEX_WIDTH + OFFSET_WIDTH];

    //访问Cache line
    wire c_valid;
    wire [TAG_WIDTH-1:0] c_tag;
    wire [31:0] c_block;

    assign c_valid = cache_valid[index];
    assign c_tag   = cache_tag  [index];
    assign c_block = cache_block[index];

    //判断是否命中
    //* hit和miss互反，合起来总保持高电平
    wire hit, miss;
    assign hit = c_valid & (c_tag == tag);  //cache line的valid位为1，且tag与地址中tag相等
    assign miss = ~hit;

    //FSM
    parameter IDLE = 2'b00, RM = 2'b01; // i cache只有read
    reg [1:0] state;
    always @(posedge clk) begin
        if(rst) begin
            state <= IDLE;
        end
        else begin
            case(state)
                // *
                IDLE:   state <= cpu_inst_en & miss ? RM : IDLE;
                // IDLE:   state <= cpu_inst_req & miss ? RM : IDLE;
                RM:     state <= cache_inst_data_ok ? IDLE : RM;
            endcase
        end
    end

    //读内存
    //变量read_req, addr_rcv, read_finish用于构造类sram信号。
    wire read_req;      //一次完整的读事务，从发出读请求到结束
    reg addr_rcv;       //地址接收成功(addr_ok)后到结束
    wire read_finish;   //数据接收成功(data_ok)，即读请求结束
    always @(posedge clk) begin
        addr_rcv <= rst ? 1'b0 :
        // 保证先inst_req再addr_rcv；如果addr_ok同时data_ok，则优先data_ok
        // *
                    cache_inst_req & cache_inst_addr_ok & ~cache_inst_data_ok ? 1'b1 :
                    read_finish ? 1'b0 : addr_rcv;
    end
    assign read_req = state==RM;
    assign read_finish = cache_inst_data_ok;

    //output to mips core
    //* 如果数据准备好了(hit or cache_data_ok)，就告诉CPU数据准备好了(finish=1)，数据存到save里，等待CPU读
    // save rdata，防止丢失
    reg [31:0] cpu_inst_rdata_save;
    always @(posedge clk) begin
        cpu_inst_rdata_save <= rst ? 32'b0:
        // hit(一定算ok) 或 data_ok 则更新暂存值
                               hit ? c_block : cache_inst_data_ok ? cache_inst_rdata : 
                               cpu_inst_rdata_save;
    end
    // *
    assign cpu_inst_rdata   = cpu_inst_rdata_save;
    // assign cpu_inst_rdata   = hit ? c_block : cache_inst_rdata;
    //* addr_ok 没用上
    // assign cpu_inst_addr_ok = cpu_inst_en & hit | cache_inst_req & cache_inst_addr_ok;
    // assign cpu_inst_addr_ok = cpu_inst_req & hit | cache_inst_req & cache_inst_addr_ok;
    //* data_ok 没用上
    // wire cpu_inst_data_ok;
    // assign cpu_inst_data_ok = cpu_inst_en & hit | cache_inst_data_ok;
    // assign cpu_inst_data_ok = cpu_inst_req & hit | cache_inst_data_ok;
    // * stall
    reg do_finish;
    always @(posedge clk) begin
        // 本次读cache事务是否完成。用来告诉CPU数据准备好了。
        // 如果数据准备好了(hit or cache_data_ok)，就告诉CPU数据准备好了(finish=1)，数据存到save里，等待CPU读。
        // 准备好了，同时如果CPU忙，cache这边就要一直保持do_finish(为1)，等CPU有空之后来读。
        // CPU有空之后(~longest_stall)，就会读，这时把do_finish归零，准备下一次访存。
        // 如果数据还没准备好，但是CPU已经有空了(~longest_stall)，就让CPU接着等(cpu_data_stall)。
        do_finish <= rst                ? 1'b0 :
                     cache_inst_data_ok ? 1'b1 :
        // cpu 仍在暂停，保证一次流水线暂停只取一次指令，只进行一次内存访问
                     ~cpu_longest_stall ? 1'b0 : do_finish;
    end
    assign cpu_inst_stall = cpu_inst_en & ~do_finish; // 让CPU等

    //output to axi interface
    // *
    assign cache_inst_req   = (read_req & ~addr_rcv) & ~do_finish;
    assign cache_inst_wr    = 1'b0;
    assign cache_inst_size  = 2'b10;
    assign cache_inst_addr  = cpu_inst_addr;
    assign cache_inst_wdata = cpu_inst_wdata; // 32'b0

    //写入Cache
    //保存地址中的tag, index，防止addr发生改变
    reg [TAG_WIDTH-1:0] tag_save;
    reg [INDEX_WIDTH-1:0] index_save;
    always @(posedge clk) begin
        tag_save   <= rst ? 0 :
        //*
                      cpu_inst_en ? tag : tag_save;
                    //   cpu_inst_req ? tag : tag_save;
        index_save <= rst ? 0 :
        //*
                      cpu_inst_en ? index : index_save;
                    //   cpu_inst_req ? index : index_save;
    end

    integer t;
    always @(posedge clk) begin
        if(rst) begin
            for(t=0; t<CACHE_DEEPTH; t=t+1) begin   //刚开始将Cache置为无效
                cache_valid[t] <= 0;
            end
        end
        else begin
            if(read_finish) begin //读缺失，访存结束时
                cache_valid[index_save] <= 1'b1;             //将Cache line置为有效
                cache_tag  [index_save] <= tag_save;
                cache_block[index_save] <= cache_inst_rdata; //写入Cache line
            end
        end
    end
endmodule