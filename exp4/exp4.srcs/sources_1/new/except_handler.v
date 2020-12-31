`timescale 1ns / 1ps
`include "defines.vh"

module except_handler(input [31:0] curr_instr_addr,
                      input is_in_delayslot,
                      );
// �쳣����ģ��
// ! �쳣����ʱֻ������ǣ���M�׶�ͳһ����
// ! �쳣ָ������ָ����Ч�������ܶԼĴ�����HILO��CPU״̬���Ӱ�졣�����ָ��رռĴ���дʹ�ܡ��ر�ģ�ֹͣ�˳������㣩
wire [31:0] except_type;

reg [31:0] CP0[CP0_CNT-1:0];

wire [31:0] badVAddr, status, cause, epc;
assign badVAddr = CP0[CP0_REG_BADVADDR];
assign status   = CP0[CP0_REG_STATUS];
assign cause    = CP0[CP0_REG_CAUSE];
assign epc      = CP0[CP0_REG_EPC];



always @(*) begin
    CP0[CP0_REG_STATUS][STATUS_EXL] <= 1'b1;
    case (except_type)
        ExcCode_Int: begin
            // �ж�
            if (is_in_delayslot) begin
                epc <= curr_instr_addr - 4;
                cause[CAUSE_BD] <= 1'b1;
            end else begin
                epc <= curr_instr_addr;
                cause[CAUSE_BD] <= 1'b0;
            end
            status[STATUS_EXL] <= 1'b1;
            cause[CAUSE_EXECODE] <= 
        end
        ExcCode_AdEL: begin
            // addr error load
            // ��ַ�����⣨�����ݻ�ȡָ�
            if (is_in_delayslot) begin
                
            end else begin
                
            end
        end
        ExcCode_AdES: begin
            // addr error store
            // ��ַ�����⣨д���ݣ�
            if (is_in_delayslot) begin
                
            end else begin
                
            end
        end
        ExcCode_Sys: begin
            // ϵͳ�������� syscall
            if (is_in_delayslot) begin
                
            end else begin
                
            end
        end
        ExcCode_Bp: begin
            // �ϵ����� break
            if (is_in_delayslot) begin
                
            end else begin
                
            end
        end
        ExcCode_RI: begin
            // ����ָ������ invalid instruction
            if (is_in_delayslot) begin
                
            end else begin
                
            end
        end
        ExcCode_Ov: begin
            // �����������
            if (is_in_delayslot) begin
                
            end else begin
                
            end
        end

        default: 
    endcase
end

endmodule
