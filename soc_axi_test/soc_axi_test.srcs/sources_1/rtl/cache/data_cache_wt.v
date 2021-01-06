module data_cache (
// module data_cache_wt (
    input wire clk, rst,
    //mips core
    input wire        cpu_data_en    , //* 读或写 new，一直高电平。
    input wire [3 :0] cpu_data_wen   , //* 读时全0，写时对应字节位置1。一直维持。new
    input wire [31:0] cpu_data_addr  , //* 一直维持。
    input wire [31:0] cpu_data_wdata , //* 一直维持。
    input wire        cpu_longest_stall,  //* new √
    output wire [31:0]cpu_data_rdata,
    output wire       cpu_data_stall,   //* new，如果cache命中就不用stall，如果没命中要一直等到mem返回数据。

    //√ input         cpu_data_req     , // 是不是数据请求(load 或 store指令)。一个周期后就清除了。//* 认为cache一个周期就读完，那么req和en是一致的，用en代替。
    //√ input         cpu_data_wr      , // mips->cache, 当前请求是否是写请求(是不是store指令)。一直保持电平状态直到请求成功。//*用cpu_data_en & (wen != 4'b0)代替
    //√ input  [1 :0] cpu_data_size    , // 结合地址最低两位，确定数据的有效字节（用于sb、sh等指令）//* 直接用wen
    //√ output        cpu_data_addr_ok , // 确认请求的地址已收到，一个周期后清除 //*√ 本来就是用于生成stall信号的
    //√ output        cpu_data_data_ok , // 确认请求的数据已收到，一个周期后清除 //*√ 本来就是用于生成stall信号的

    //axi interface
    output         cache_data_req     ,
    output         cache_data_wr      ,
    output  [1 :0] cache_data_size    ,
    output  [31:0] cache_data_addr    ,
    output  [31:0] cache_data_wdata   ,
    input   [31:0] cache_data_rdata   ,
    input          cache_data_addr_ok ,
    input          cache_data_data_ok 
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
    
    assign offset = cpu_data_addr[OFFSET_WIDTH - 1 : 0];
    assign index = cpu_data_addr[INDEX_WIDTH + OFFSET_WIDTH - 1 : OFFSET_WIDTH];
    assign tag = cpu_data_addr[31 : INDEX_WIDTH + OFFSET_WIDTH];

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

    //读或写
    wire read, write;
    // *
    assign write = cpu_data_en & (cpu_data_wen != 4'b0);
    // assign write = cpu_data_wr;
    assign read = cpu_data_en & (cpu_data_wen == 4'b0);
    // assign read = ~write;

    //FSM
    parameter IDLE = 2'b00, RM = 2'b01, WM = 2'b11;
    reg [1:0] state;
    always @(posedge clk) begin
        if(rst) begin
            state <= IDLE;
        end
        else begin
            case(state)
                //*
                IDLE:   state <= cpu_data_en & read & miss ? RM :
                                 cpu_data_en & read & hit  ? IDLE :
                                 cpu_data_en & write       ? WM : IDLE;
                // IDLE:   state <= cpu_data_req & read & miss ? RM :
                //                  cpu_data_req & read & hit  ? IDLE :
                //                  cpu_data_req & write       ? WM : IDLE;
                RM:     state <= read & cache_data_data_ok ? IDLE : RM;
                WM:     state <= write & cache_data_data_ok ? IDLE : WM;
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
                    read & cache_data_req & cache_data_addr_ok ? 1'b1 :
                    read_finish ? 1'b0 : addr_rcv;
    end
    assign read_req = state==RM;
    assign read_finish = read & cache_data_data_ok;

    //写内存
    wire write_req;     
    reg waddr_rcv;      
    wire write_finish;   
    always @(posedge clk) begin
        waddr_rcv <= rst ? 1'b0 :
                     write & cache_data_req & cache_data_addr_ok ? 1'b1 :
                     write_finish ? 1'b0 : waddr_rcv;
    end
    assign write_req = state==WM;
    assign write_finish = write & cache_data_data_ok;

    //output to mips core
    //* 如果数据准备好了(hit or cache_data_ok)，就告诉CPU数据准备好了(finish=1)，数据存到save里，等待CPU读
    // save rdata，防止丢失
    reg [31:0] cpu_data_rdata_save;
    always @(posedge clk) begin
        cpu_data_rdata_save <= rst ? 32'b0:
        // hit(一定算ok) 或 data_ok 则更新暂存值
                               hit ? c_block : cache_data_data_ok ? cache_data_rdata : 
                               cpu_data_rdata_save;
    end
    // *
    assign cpu_data_rdata   = cpu_data_rdata_save;
    // assign cpu_data_rdata   = hit ? c_block : cache_data_rdata;
    //* addr_ok 没用上
    // assign cpu_data_addr_ok = read & cpu_data_req & hit | cache_data_req & cache_data_addr_ok;
    // assign cpu_data_addr_ok = read & cpu_data_req & hit | cache_data_req & cache_data_addr_ok;
    wire cpu_data_data_ok;
    assign cpu_data_data_ok = cpu_data_en & hit | cache_data_data_ok;
    // assign cpu_data_data_ok = read & cpu_data_req & hit | cache_data_data_ok;
    // TODO 可能有bug。检查一下命中时会不会有延迟，造成周期浪费
    // * stall
    reg do_finish;
    always @(posedge clk) begin
        // 本次读cache事务是否完成。用来告诉CPU数据准备好了。
        // 如果数据准备好了(hit or cache_data_ok)，就告诉CPU数据准备好了(finish=1)，数据存到save里，等待CPU读。
        // 准备好了，同时如果CPU忙，cache这边就要一直保持do_finish(为1)，等CPU有空之后来读。
        // CPU有空之后(~longest_stall)，就会读，这时把do_finish归零，准备下一次访存。
        // 如果数据还没准备好，但是CPU已经有空了(~longest_stall)，就让CPU接着等(cpu_data_stall)。
        do_finish <= rst                ? 1'b0 :
                     cpu_data_data_ok   ? 1'b1 :
        // cpu 仍在暂停，保证一次流水线暂停只取一次指令，只进行一次内存访问
                     ~cpu_longest_stall ? 1'b0 : do_finish;
    end
    assign cpu_data_stall = cpu_data_en & ~do_finish; // 让CPU等


    //output to axi interface
    assign cache_data_req   = read_req & ~addr_rcv | write_req & ~waddr_rcv;
    // *
    assign cache_data_wr    = cpu_data_en & (cpu_data_wen != 4'b0);
    // assign cache_data_wr    = cpu_data_wr;
    // *
    assign cache_data_size  = (cpu_data_wen==4'b0001 || cpu_data_wen==4'b0010 || cpu_data_wen==4'b0100 || cpu_data_wen==4'b1000) ? 2'b00:
                              (cpu_data_wen==4'b0011 || cpu_data_wen==4'b1100 ) ? 2'b01 : 2'b10;
    // assign cache_data_size  = cpu_data_size;
    assign cache_data_addr  = cpu_data_addr;
    assign cache_data_wdata = cpu_data_wdata;

    //写入Cache
    //保存地址中的tag, index，防止addr发生改变
    reg [TAG_WIDTH-1:0] tag_save;
    reg [INDEX_WIDTH-1:0] index_save;
    always @(posedge clk) begin
        tag_save   <= rst ? 0 :
        //*
                      cpu_data_en ? tag : tag_save;
                    //   cpu_data_req ? tag : tag_save;
        index_save <= rst ? 0 :
        //*
                      cpu_data_en ? index : index_save;
                    //   cpu_data_req ? index : index_save;
    end

    wire [31:0] write_cache_data;
    wire [3:0] write_mask;

    //根据地址低两位和size，生成写掩码（针对sb，sh等不是写完整一个字的指令），4位对应1个字（4字节）中每个字的写使能
    // *
    assign write_mask = cpu_data_wen;
    // assign write_mask = cpu_data_size==2'b00 ?
    //                     (cpu_data_addr[1] ? (cpu_data_addr[0] ? 4'b1000 : 4'b0100):
    //                                         (cpu_data_addr[0] ? 4'b0010 : 4'b0001)) :
    //                     (cpu_data_size==2'b01 ? (cpu_data_addr[1] ? 4'b1100 : 4'b0011) : 4'b1111);

    //掩码的使用：位为1的代表需要更新的。
    //位拓展：{8{1'b1}} -> 8'b11111111
    //new_data = old_data & ~mask | write_data & mask
    assign write_cache_data = cache_block[index] & ~{{8{write_mask[3]}}, {8{write_mask[2]}}, {8{write_mask[1]}}, {8{write_mask[0]}}} | 
                              cpu_data_wdata & {{8{write_mask[3]}}, {8{write_mask[2]}}, {8{write_mask[1]}}, {8{write_mask[0]}}};

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
                cache_block[index_save] <= cache_data_rdata; //写入Cache line
            end
            // *
            else if(write & cpu_data_en & hit) begin   //写命中时需要写Cache
            // else if(write & cpu_data_req & hit) begin   //写命中时需要写Cache
                cache_block[index] <= write_cache_data;      //写入Cache line，使用index而不是index_save
            end
        end
    end
endmodule