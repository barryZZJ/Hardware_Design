`timescale 1ns / 1ps


module div(
	input clk,rst,
	input Signed_div_i,
	input [31:0] Opdata1_i, Opdata2_i,
	input start_i, annul_i,
	output wire [63:0] result_o,
	output reg ready_o
    );
	//除法需要运算周期(对于小型数字会优化运算次数)
	reg [4:0] div_max;
	//除法周期计数
	reg [4:0] div_count;
	//状态
	reg [1:0] main_state;
	//计算结果
	reg [63:0] result;
	//被除数，被除数符号
	reg [31:0] div_num1;
	reg sign1;
	//除数，除数符号
	reg [31:0] div_num2;
	reg sign2;

	assign result_o = result;

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			// reset
			div_max<=0;
			div_count<=0;
			main_state<=0;
			result<=0;
			ready_o<=0;
			div_num1<=0;
			div_num2<=0;
			sign1<=0;
			sign2<=0;
		end
		//除使能信号期间的处理
		else if(start_i)begin
			case(main_state)
			//一切就绪,等待除使能信号
			//初始化数据,进入计算状态
			2'b00:begin
				main_state<=2'b01;
				if(Signed_div_i)begin
					//div_max = 5'd30;
					div_num1=Opdata1_i[31] ? (~Opdata1_i)+1 : Opdata1_i; // 把负操作数存成正的
					div_num2=Opdata2_i[31] ? (~Opdata2_i)+1 : Opdata2_i;
				end
				else begin 
					//div_max = 5'd31;
					div_num1=Opdata1_i;
					div_num2=Opdata2_i;		
				end
				//简化周期
				div_max=div_num1[31]?5'd31:
						div_num1[30]?5'd30:
						div_num1[29]?5'd29:
						div_num1[28]?5'd28:
						div_num1[27]?5'd27:
						div_num1[26]?5'd26:
						div_num1[25]?5'd25:
						div_num1[24]?5'd24:
						div_num1[23]?5'd23:
						div_num1[22]?5'd22:
						div_num1[21]?5'd21:
						div_num1[20]?5'd20:
						div_num1[19]?5'd19:
						div_num1[18]?5'd18:
						div_num1[17]?5'd17:
						div_num1[16]?5'd16:
						div_num1[15]?5'd15:
						div_num1[14]?5'd14:
						div_num1[13]?5'd13:
						div_num1[12]?5'd12:
						div_num1[11]?5'd11:
						div_num1[10]?5'd10:
						div_num1[9]?5'd9:
						div_num1[8]?5'd8:
						div_num1[7]?5'd7:
						div_num1[6]?5'd6:
						div_num1[5]?5'd5:
						div_num1[4]?5'd4:
						div_num1[3]?5'd3:
						div_num1[2]?5'd2:
						div_num1[1]?5'd1:5'd0;
				result={32'h00000000,(div_num1<<(5'd31-div_max))};
				sign1=Opdata1_i[31];
				sign2=Opdata2_i[31];
			end
			//计算中,一共32周期
			2'b01:begin
				//整体左移
				result = result << 1;
				//试减
				if(result[63:32]>=div_num2)begin 
					result[0]=1;
					result[63:32]=result[63:32]-div_num2; 
				end
				else begin result[0]=0; end
				//判断执行次数,达到指定次数后进入符号结算阶段
				if(div_count==div_max)begin
					main_state<=2'b10;
				end
				//执行次数增加
				div_count=div_count+1;	
			end
			//符号处理
			2'b10:begin
				if(Signed_div_i)begin
					result[31:0]=(sign1^sign2) ? (~result[31:0])+1 : result[31:0];
					result[63:32]=sign1 ? (~result[63:32])+1 : result[63:32];
				end
				main_state<=2'b11;
				ready_o<=1;
			end
			//等待取值
			endcase
		end
		else if(annul_i)begin
			//重置所有值
			div_max<=0;
			div_count<=0;
			main_state<=0;
			result<=0;
			ready_o<=0;
			div_num1<=0;
			div_num2<=0;
			sign1<=0;
			sign2<=0;
		end
	end
endmodule
