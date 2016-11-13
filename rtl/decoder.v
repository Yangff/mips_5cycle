/* INPUT: 
	* Current Stage
	* Calculation Result

   OUTPUT:
   	* Control Signal
   	* Next Stage
*/
module decoder(
	/* System In */
	clk, reset, 
	/* Decoder In */
	ins, 
	/* Decoder Out */
	pc,

	/* ALU In */
	alu_result, alu_flags, //  
	/* ALU Control Out */
	alu_op, alu_mask /* 00 all reg, 01/10 (a, b) reg + imm, 11 forbidden */, alu_imm1, alu_imm0,

	/* Memory In */
	mem_data,
	/* Memory Out */
	mem_addr, mem_write_en, mem_write_data, 

	/* Register In */
	reg_rs_data, reg_rt_data,
	/* Register Out */
	reg_rs, reg_rt, reg_rd,
	reg_rd_data, reg_write_en,
	
);

	// decoder
	reg [31:0] dc_ins;
	reg [3:0] dc_stage;

	/// Logic

	// dc_stage <= dc_stage_next; iff need different path

	always @(negedge clk) begin
	  // State Machine
	  case (dc_stage)
		4'b0000: begin // fetch
			dc_ins <= mem_data;
			pc <= alu_result;
			dc_stage <= 4'b0001; 
		end
	  endcase
	end

	always @(reset) begin
		dc_ins <= 0;
		dc_stage <= 0;
	end

	// control signals

	always @* begin
		alu_op = 0;	alu_mask = 0; alu_imm1 = 0; alu_imm0 = 0; 
		mem_addr = 0; mem_write_en = 0; mem_write_data = 0;
		reg_rs = dc_reg_s; reg_rt = dc_reg_t; reg_rd = dc_reg_d;
		reg_rd_data = 0; reg_write_en = 0;
		case (dc_stage)
		  4'b0000: begin
		  	alu_mask = 2'b11; alu_imm1 = pc; alu_imm0 = 4; mem_addr = pc; 
		  end
		  4'b0001: begin
		  	// decoder
			
		  end
		endcase
	end


	/// Defines & Assignments
	input clk;
	input reset;

	input [31:0] ins;

	output [31:0] pc;


	wire [5:0] dc_op;
	
	wire [4:0] dc_reg_s;
	wire [4:0] dc_reg_t;
	wire [4:0] dc_reg_d;

	wire [4:0] dc_smt;

	wire [5:0] dc_funt;

	wire [25:0] dc_immj;
	wire [15:0] dc_immi;

	wire [31:0] extension_26;
	wire [31:0] extension_16;
	wire [31:0] extension_16_addr;

	wire [3:0] dc_stage_next; 

	// 加载
	wire dc_ins_lb;
	wire dc_ins_lbu;
	wire dc_ins_lh;
	wire dc_ins_lhu;
	wire dc_ins_lw;
	wire dc_type_load;
	// 保存
	wire dc_ins_sb;
	wire dc_ins_sh;
	wire dc_ins_sw;
	wire dc_type_save;
	// R-R运算
	wire dc_ins_add;
	wire dc_ins_addu;
	wire dc_ins_sub;
	wire dc_ins_subu;
	wire dc_ins_slt;
	wire dc_ins_sltu;
	wire dc_ins_sll;
	wire dc_ins_srl;
	wire dc_ins_sra;
	wire dc_ins_sllv;
	wire dc_ins_srlv;
	wire dc_ins_srav;
	wire dc_ins_and;
	wire dc_ins_or;
	wire dc_ins_xor;
	wire dc_ins_nor;
	wire dc_type_r;
	// R-I运算
	wire dc_ins_addi;
	wire dc_ins_addiu;
	wire dc_ins_andi;
	wire dc_ins_ori;
	wire dc_ins_xori;
	wire dc_ins_lui;
	wire dc_ins_slti;
	wire dc_ins_sltiu;
	wire dc_type_i;
	// 分支
	wire dc_ins_beq;
	wire dc_ins_bne;
	wire dc_ins_blez;
	wire dc_ins_bgtz;
	wire dc_ins_bltz;
	wire dc_ins_bgez;
	wire dc_type_b;
	// 跳转
	wire dc_ins_j;
	wire dc_ins_jal;
	wire dc_ins_jalr;
	wire dc_ins_jr;
	wire dc_type_jump;
	// 传输
	wire dc_ins_mfhi;
	wire dc_ins_mflo;
	wire dc_ins_mthi;
	wire dc_ins_mtlo;

	// decode op
	assign dc_op = ins[31:26];

	// 加载
	assign dc_ins_lb = dc_op == 6'b100000;
	assign dc_ins_lbu = dc_op == 6'b100100;
	assign dc_ins_lh = dc_op == 6'b100001;
	assign dc_ins_lhu = dc_op == 6'b100101;
	assign dc_ins_lw = dc_op == 6'b100011;
	assign dc_type_load = dc_ins_lb | dc_ins_lbu | dc_ins_lh | dc_ins_lhu | dc_ins_lw;
	// 保存
	assign dc_ins_sb = dc_op == 6'b101000;
	assign dc_ins_sh = dc_op == 6'b101001;
	assign dc_ins_sw = dc_op == 6'b101011;
	assign dc_type_save = dc_ins_sb | dc_ins_sh | dc_ins_sw;
	// R-R运算
	assign dc_ins_add = (dc_op == 6'b000000) & (dc_funt == 6'b100000);
	assign dc_ins_addu = (dc_op == 6'b000000) & (dc_funt == 6'b100001);
	assign dc_ins_sub = (dc_op == 6'b000000) & (dc_funt == 6'b100010);
	assign dc_ins_subu = (dc_op == 6'b000000) & (dc_funt == 6'b100011);
	assign dc_ins_slt = (dc_op == 6'b000000) & (dc_funt == 6'b101010);
	assign dc_ins_sltu = (dc_op == 6'b000000) & (dc_funt == 6'b101011);
	assign dc_ins_sll = (dc_op == 6'b000000) & (dc_funt == 6'b000000);
	assign dc_ins_srl = (dc_op == 6'b000000) & (dc_funt == 6'b000010);
	assign dc_ins_sra = (dc_op == 6'b000000) & (dc_funt == 6'b000011);
	assign dc_ins_sllv = (dc_op == 6'b000000) & (dc_funt == 6'b000100);
	assign dc_ins_srlv = (dc_op == 6'b000000) & (dc_funt == 6'b000110);
	assign dc_ins_srav = (dc_op == 6'b000000) & (dc_funt == 6'b000111);
	assign dc_ins_and = (dc_op == 6'b000000) & (dc_funt == 6'b100100);
	assign dc_ins_or = (dc_op == 6'b000000) & (dc_funt == 6'b100101);
	assign dc_ins_xor = (dc_op == 6'b000000) & (dc_funt == 6'b100110);
	assign dc_ins_nor = (dc_op == 6'b000000) & (dc_funt == 6'b100111);
	assign dc_type_r = dc_ins_add | dc_ins_addu | dc_ins_sub | dc_ins_subu | dc_ins_slt | dc_ins_sltu | dc_ins_sll | dc_ins_srl | dc_ins_sra | dc_ins_sllv | dc_ins_srlv | dc_ins_srav | dc_ins_and | dc_ins_or | dc_ins_xor | dc_ins_nor;
	// R-I运算
	assign dc_ins_addi = dc_op == 6'b001000;
	assign dc_ins_addiu = dc_op == 6'b001001;
	assign dc_ins_andi = dc_op == 6'b001100;
	assign dc_ins_ori = dc_op == 6'b001101;
	assign dc_ins_xori = dc_op == 6'b001110;
	assign dc_ins_lui = dc_op == 6'b001111;
	assign dc_ins_slti = dc_op == 6'b001010;
	assign dc_ins_sltiu = dc_op == 6'b001011;
	assign dc_type_i = dc_ins_addi | dc_ins_addiu | dc_ins_andi | dc_ins_ori | dc_ins_xori | dc_ins_lui | dc_ins_slti | dc_ins_sltiu;
	// 分支
	assign dc_ins_beq = dc_op == 6'b000100;
	assign dc_ins_bne = dc_op == 6'b000101;
	assign dc_ins_blez = dc_op == 6'b000110;
	assign dc_ins_bgtz = dc_op == 6'b000111;
	assign dc_ins_bltz = (dc_op == 6'b000001) & (dc_rt == 6'b00000);
	assign dc_ins_bgez = (dc_op == 6'b000001) & (dc_rt == 6'b00001);
	assign dc_type_b = dc_ins_beq | dc_ins_bne | dc_ins_blez | dc_ins_bgtz | dc_ins_bltz | dc_ins_bgez;
	// 跳转
	assign dc_ins_j = dc_op == 6'b000010;
	assign dc_ins_jal = dc_op == 6'b000011;
	assign dc_ins_jalr = (dc_op == 6'b000000) & (dc_funt == 6'b001001);
	assign dc_ins_jr = (dc_op == 6'b000000) & (dc_funt == 6'b001000);
	assign dc_type_jump = dc_ins_j | dc_ins_jal | dc_ins_jalr | dc_ins_jr;
	// 传输
	assign dc_ins_mfhi = (dc_op == 6'b000000) & (dc_funt == 6'b010000);
	assign dc_ins_mflo = (dc_op == 6'b000000) & (dc_funt == 6'b010010);
	assign dc_ins_mthi = (dc_op == 6'b000000) & (dc_funt == 6'b010001);
	assign dc_ins_mtlo = (dc_op == 6'b000000) & (dc_funt == 6'b010011);

endmodule