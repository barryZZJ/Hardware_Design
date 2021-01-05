module d_cache (
    input wire clk, rst,
    //mips core
    input         cpu_data_req     , // �ǲ�����������(load �� storeָ��)��һ�����ں�������
    input         cpu_data_wr      , // mips->cache, ��ǰ�����Ƿ���д����(�ǲ���storeָ��)��һֱ���ֵ�ƽ״ֱ̬������ɹ�
    input  [1 :0] cpu_data_size    , // ��ϵ�ַ�����λ��ȷ�����ݵ���Ч�ֽڣ�����sb��sh��ָ�
    input  [31:0] cpu_data_addr    ,
    input  [31:0] cpu_data_wdata   ,
    output [31:0] cpu_data_rdata   ,
    output        cpu_data_addr_ok , // ȷ������ĵ�ַ���յ���һ�����ں����
    output        cpu_data_data_ok , // ȷ��������������յ���һ�����ں����

    //axi interface
    output         cache_data_req     , // cache->mem, �ǲ�����������(RM��WM״̬)��һ�����ں�������
    output         cache_data_wr      , // cache->mem, ��ǰ�����Ƿ���д����(�ǲ��Ǵ���WM״̬)��һֱ���ֵ�ƽ״ֱ̬������ɹ�
    output  [1 :0] cache_data_size    ,
    output  [31:0] cache_data_addr    ,
    output  [31:0] cache_data_wdata   ,
    input   [31:0] cache_data_rdata   ,
    input          cache_data_addr_ok , // ȷ������ĵ�ַ���յ���һ�����ں����
    input          cache_data_data_ok   // ȷ��������������յ���һ�����ں����
);
    //Cache����
    parameter  INDEX_WIDTH  = 10, OFFSET_WIDTH = 2;
    localparam TAG_WIDTH    = 32 - INDEX_WIDTH - OFFSET_WIDTH;
    localparam CACHE_DEEPTH = 1 << INDEX_WIDTH;
    
    //Cache�洢��Ԫ
    //* ��·������cache����һ��
    reg                 cache_valid [CACHE_DEEPTH - 1 : 0][1:0];
    reg                 cache_dirty [CACHE_DEEPTH - 1 : 0][1:0]; // �Ƿ��޸Ĺ�
    reg                 cache_ru    [CACHE_DEEPTH - 1 : 0][1:0]; //* recently used
    reg [TAG_WIDTH-1:0] cache_tag   [CACHE_DEEPTH - 1 : 0][1:0];
    reg [31:0]          cache_block [CACHE_DEEPTH - 1 : 0][1:0];

    //���ʵ�ַ�ֽ�
    wire [OFFSET_WIDTH-1:0] offset;
    wire [INDEX_WIDTH-1:0] index;
    wire [TAG_WIDTH-1:0] tag;
    
    assign offset = cpu_data_addr[OFFSET_WIDTH - 1 : 0];
    assign index = cpu_data_addr[INDEX_WIDTH + OFFSET_WIDTH - 1 : OFFSET_WIDTH];
    assign tag = cpu_data_addr[31 : INDEX_WIDTH + OFFSET_WIDTH];

    //����Cache line
    wire                 c_valid[1:0];
    wire                 c_dirty[1:0]; // �Ƿ��޸Ĺ�
    wire                 c_ru   [1:0]; //* recently used
    wire [TAG_WIDTH-1:0] c_tag  [1:0];
    wire [31:0]          c_block[1:0];

    assign c_valid[0] = cache_valid[index][0];
    assign c_valid[1] = cache_valid[index][1];
    assign c_dirty[0] = cache_dirty[index][0];
    assign c_dirty[1] = cache_dirty[index][1];
    assign c_ru   [0] = cache_ru   [index][0];
    assign c_ru   [1] = cache_ru   [index][1];
    assign c_tag  [0] = cache_tag  [index][0];
    assign c_tag  [1] = cache_tag  [index][1];
    assign c_block[0] = cache_block[index][0];
    assign c_block[1] = cache_block[index][1];

    //�ж��Ƿ�����
    wire hit, miss;
    assign hit = c_valid[0] & (c_tag[0] == tag) | c_valid[1] & (c_tag[1] == tag);  //* cache line��һ·�е�validλΪ1����tag���ַ��tag���
    assign miss = ~hit;

    //* �����cache����Ӧ������һ·
    wire c_way;
    //* 1. hit��ѡhit����һ·
    //* 2. miss��ѡ�������ʹ�õ���һ·(c_ru[0]==1��0·���ʹ�� -> c_way=1·)
    assign c_way = hit ? (c_valid[0] & (c_tag[0] == tag) ? 1'b0 : 1'b1) : 
                   c_ru[0] ? 1'b1 : 1'b0; 

    // cpu�����ǲ��Ƕ���д����(�ǲ���load��storeָ��)
    wire load, store;
    assign store = cpu_data_wr;
    assign load = cpu_data_req & ~store; // �����������Ҳ���store����ô����load

    //* cache��ǰλ���Ƿ�dirty
    wire dirty, clean;
    assign dirty = c_dirty[c_way];
    assign clean = ~dirty;

    //FSM
    parameter IDLE = 2'b00, RM = 2'b01, WM = 2'b11;
    reg [1:0] state;
    // storeָ��Ƿ��Ǵ���RM״̬��������miss)����RM����ʱ(state��RM->IDLE)�������أ�in_RM��������Ϊ1.
    reg in_RM;

    always @(posedge clk) begin
        if(rst) begin
            state <= IDLE;
            in_RM <= 1'b0;
        end
        else begin
            case(state)
            // ����״̬����д
                IDLE: begin
                    state <= IDLE;
                    if (cpu_data_req) begin
                        if (hit) 
                            state <= IDLE;
                        else if (miss & dirty)
                            state <= WM;
                        else if (miss & clean)
                            state <= RM;
                    end
                    in_RM <= 1'b0;
                end

                WM: begin
                    state <= WM;
                    if (cache_data_data_ok)
                        state <= RM;
                end

                RM: begin
                    state <= RM;
                    if (cache_data_data_ok)
                        state <= IDLE;

                    in_RM <= 1'b1;
                end
            endcase
        end
    end

    //���ڴ�
    //���� isRM, addr_rcv, read_finish���ڹ�����sram�źš�
    wire isRM;      //һ�������Ķ����񣬴ӷ��������󵽽��� // �ǲ��Ǵ���RM״̬
    reg addr_rcv;       //��ַ���ճɹ�(addr_ok)�󵽽���      // ����RM״̬���ҵ�ַ�ѵõ�mem��ȷ��
    wire read_finish;   //���ݽ��ճɹ�(data_ok)������������� // ����RM״̬�����ѵõ�mem��ȡ������
    always @(posedge clk) begin
        addr_rcv <= rst ? 1'b0 :
                    cache_data_req & isRM & cache_data_addr_ok ? 1'b1 :
                    read_finish ? 1'b0 : 
                    addr_rcv;
    end
    assign isRM = state==RM;
    assign read_finish = isRM & cache_data_data_ok;

    //д�ڴ�
    wire isWM;     // �ǲ��Ǵ���WM״̬
    reg waddr_rcv;      // ����WM״̬���ҵ�ַ�ѵõ�mem��ȷ��
    wire write_finish;  // ����WM״̬������д��mem������
    always @(posedge clk) begin
        waddr_rcv <= rst ? 1'b0 :
                     cache_data_req& isWM & cache_data_addr_ok ? 1'b1 :
                     write_finish ? 1'b0 :
                     waddr_rcv;
    end
    assign isWM = state==WM;
    assign write_finish = isWM & cache_data_data_ok;

    //output to mips core
    //* �����Ӧ·��cache block
    assign cpu_data_rdata   = hit ? c_block[c_way] : cache_data_rdata;

    // ȷ�ϵ�ַ
    // �����дָ��store�����У���ôֱ��ȷ�ϵ�ַ;
    //                  ȱʧ������mem�һ�δ�յ���ַ(cache_data_req)��
    //                       �ɾ�����ô�ȶ�memʱ(isRM)��memȷ�����ַ(cache_data_addr_ok)ʱȷ�ϣ�
    //                       �࣬��ô��д��mem�󣬵ȵ���memʱ(isRM)��memȷ�����ַ(cache_data_addr_ok)ʱȷ�ϣ�
    
    // ����Ƕ�ָ��load �����У���ô��ֱ��ȷ�ϵ�ַ��
    //                  ȱʧ������mem�һ�δ�յ���ַ(cache_data_req)��
    //                       �ɾ�����ô�ȶ�memʱ(isRM)��memȷ�����ַ(cache_data_addr_ok)ʱȷ�ϣ�
    //                       �࣬��ô��д��mem�󣬵ȵ���memʱ(isRM)��memȷ�����ַ(cache_data_addr_ok)ʱȷ��
    // �ۺ�һ��:
    // if (cpu_data_req & hit){
    //     return 1'b1;
    // }else if (cache_data_req & isRM){
    //     return cache_data_addr_ok;
    // }
    // �� -> cpu_data_req & hit | cache_data_req & isRM & cache_data_addr_ok;
    assign cpu_data_addr_ok = cpu_data_req & hit | cache_data_req & isRM & cache_data_addr_ok;

    // ȷ������
    // �����дָ��store�����У���ô����cache��ͬʱȷ�����ݣ�
    //                  ȱʧ���ɾ�����ô�ȶ�memʱ(isRM)��memȷ��������(cache_data_data_ok)�󣬸���cache��ͬʱȷ�ϣ�
    //                       �࣬��ô��д��mem�󣬵ȵ���memʱ(isRM)��memȷ��������(cache_data_data_ok)�󣬸���cache��ͬʱȷ�ϣ�
    // ����Ƕ�ָ��load�����У���ô����cache��ͬʱȷ�����ݣ�
    //                 ȱʧ���ɾ�����ô�ȶ�memʱ(isRM)��memȷ��������(cache_data_data_ok)�󣬸���cache��ͬʱȷ�ϣ�
    //                      �࣬��ô��д��mem�󣬵ȵ���memʱ(isRM)��memȷ��������(cache_data_data_ok)�󣬸���cache��ͬʱȷ�ϣ�

    // if (cpu_data_req & hit){
    //     return 1'b1;
    // }else if (isRM){
    //     return cache_data_data_ok;
    // }
    // �� -> cpu_data_req & hit | isRM & cache_data_data_ok;
    assign cpu_data_data_ok = cpu_data_req & hit | isRM & cache_data_data_ok;

    //output to axi interface
    // cache->mem
    // �ǲ�����������(RM��WM״̬)���һ�û�յ���ַ��һ�����ں�������
    assign cache_data_req   = isRM & ~addr_rcv | isWM & ~waddr_rcv;
    // ��ǰ�����Ƿ���д����ֻҪ����WM״̬����д������load����storeָ���޹ء�
    assign cache_data_wr    = isWM;
    // ȷ�����ݵ���Ч�ֽڡ�
    // �����loadָ��, ��Ч�ֽ���4B����ǰcpu_data_size��;
    // �����storeָ�����sb, sh����ǰcpu_data_size��ȷ����ͬ����Ч�ֽ�
    assign cache_data_size  = cpu_data_size;
    //* ���Ҫд�ڴ棬д��mem�ĵ�ַΪԭcache line��Ӧ�ĵ�ַ���ɵ�ַ��
    // ����Ƕ��ڴ棬��Ӧmem�ĵ�ַΪcpu_data_addr���µ�ַ��
    assign cache_data_addr  = cache_data_wr ? {c_tag[c_way], index, offset}:
                                              cpu_data_addr;
    //* cacheҪд��memory��������ԭcache line������
    assign cache_data_wdata = c_block[c_way];

    //д��Cache
    //�����ַ�е�tag, index����ֹaddr�����ı�
    reg [TAG_WIDTH-1:0] tag_save;
    reg [INDEX_WIDTH-1:0] index_save;
    always @(posedge clk) begin
        tag_save   <= rst ? 0 :
                      cpu_data_req ? tag : tag_save;
        index_save <= rst ? 0 :
                      cpu_data_req ? index : index_save;
    end

    wire [31:0] write_cache_data;
    wire [3:0] write_mask;

    //���ݵ�ַ����λ��size������д���루���sb��sh�Ȳ���д����һ���ֵ�ָ���4λ��Ӧ1���֣�4�ֽڣ���ÿ���ֵ�дʹ��
    assign write_mask = cpu_data_size==2'b00 ?
                            (cpu_data_addr[1] ? (cpu_data_addr[0] ? 4'b1000 : 4'b0100):
                                                (cpu_data_addr[0] ? 4'b0010 : 4'b0001)) :
                            (cpu_data_size==2'b01 ? (cpu_data_addr[1] ? 4'b1100 : 4'b0011) : 4'b1111);

    //�����ʹ�ã�λΪ1�Ĵ�����Ҫ���µġ�
    //λ��չ��{8{1'b1}} -> 8'b11111111
    //new_data = old_data & ~mask | write_data & mask
    assign write_cache_data = cache_block[index][c_way] & ~{{8{write_mask[3]}}, {8{write_mask[2]}}, {8{write_mask[1]}}, {8{write_mask[0]}}} | 
                              cpu_data_wdata & {{8{write_mask[3]}}, {8{write_mask[2]}}, {8{write_mask[1]}}, {8{write_mask[0]}}};

    wire isIDLE = state==IDLE;

    integer t, y;
    always @(posedge clk) begin
        if(rst) begin
            for(t=0; t<CACHE_DEEPTH; t=t+1) begin   //�տ�ʼ��Cache��ʼ��Ϊ��Ч��dirty ��ʼ��Ϊ 0��//* ru ��ʼ��Ϊ0
                for (y = 0; y<2; y=y+1) begin
                    cache_valid[t][y] <= 0;
                    cache_dirty[t][y] <= 0;
                    cache_ru   [t][y] <= 0;
                end
            end
        end
        else begin
            if(read_finish) begin // ����RM״̬�����ѵõ�mem��ȡ������
                cache_valid[index_save][c_way] <= 1'b1;             //��Cache line��Ϊ��Ч
                cache_dirty[index_save][c_way] <= 1'b0; // ��ȡ�ڴ�����ݺ�һ����clean
                cache_tag  [index_save][c_way] <= tag_save;
                cache_block[index_save][c_way] <= cache_data_rdata; //д��Cache line
            end
            else if (store & isIDLE & (hit | in_RM)) begin 
                // storeָ�hit����IDLE״̬ �� �Ӷ��ڴ�ص�IDLE�󣬽��Ĵ���ֵ��(����)�ֽ�д��cache��Ӧ��
                // �ж������м�(hit | in_RM)����Ϊ�����ֻ�ж�(store & isIDLE)������missʱ�����ڽ���WM��RM֮ǰ��ǰ����������������Ǵ�RM�ص�IDLE��ʱ���Ѿ�����mem�����ݵ�cache���ٽ��������������Ǹս���store��֧���ͽ����˸���������
                // �����ǰ���������Ļ�����ʱд��cache��write_cache_dataΪ {��cache[:x], �Ĵ���[x-1:0]}��WMʱ��������������д��mem�����³���Ϊ��������⣬�������һ���ź�in_RM����¼֮ǰ�ǲ���һֱ����RM״̬��
                cache_dirty[index][c_way] <= 1'b1; // �������ݣ���dirty
                cache_block[index][c_way] <= write_cache_data;      //д��Cache line��ʹ��index������index_save
            end

            if ((load | store) & isIDLE & (hit | in_RM)) begin
                //* load �� storeָ�hit����IDLE״̬ �� �Ӷ��ڴ�ص�IDLE�󣬽����ʹ���������
                cache_ru[index][c_way]   <= 1'b1; //* c_way ·���ʹ����
                cache_ru[index][1-c_way] <= 1'b0; //* 1-c_way ·���δʹ��
            end
        end
    end
endmodule