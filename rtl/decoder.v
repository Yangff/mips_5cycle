/* INPUT: 
	* Current Stage
	* Calculation Result

   OUTPUT:
   	* Control Signal
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

	parameter   FETCH   = 4'b0000; // State 0
	parameter   DECODE  = 4'b0001; // State 1
	parameter   MEMADR  = 4'b0010;	// State 2
	parameter   MEMRD   = 4'b0011;	// State 3
	parameter   MEMWB   = 4'b0100;	// State 4
	parameter   MEMWR   = 4'b0101;	// State 5
	parameter   RTYPEEX = 4'b0110;	// State 6
	parameter   RTYPEWB = 4'b0111;	// State 7
	parameter   BTYPEEX = 4'b1000;	// State 8
	parameter   ITYPEEX = 4'b1001;	// State 9
	parameter   ITYPEWB = 4'b1010;	// state 10
	parameter   JWRITE  = 4'b1011;	// State 11 (write when read)
	parameter   JREAD  = 4'b1100;	// State 12 (read)
	parameter   JEX     = 4'b1101;	// State 13
	
	// decoder
	reg [31:0] dc_ins;
	reg [3:0] dc_stage;

	// saved value
	reg [31:0] alu_result_current;
	reg [31:0] mem_data_current;

	/// Logic

	// dc_stage <= dc_stage_next; iff need different path

	always @(negedge clk) begin
	  // State Machine
	  case (dc_stage)
		FETCH: begin // fetch
			// init
			mem_data_current <= 0; 
			alu_result_current <= 0;

			dc_ins <= mem_data;
			pc <= alu_result;
			dc_stage <= DECODE;
		end
		DECODE: begin
			alu_result_current <= alu_result;
			dc_stage <= dc_stage_next;
		end
		MEMADR: begin
			alu_result_current <= alu_result;
			dc_stage <= dc_stage_next
		end
		MEMRD: 
			dc_stage <= dc_stage_next;
			mem_data_current <= mem_data;
		MEMWB:
			dc_stage <= 0;
		MEMWR:
			dc_stage <= 0;
		RTYPEEX: begin
			dc_stage <= RTYPEWB;
			alu_result_current <= alu_result;
		end
		RTYPEWB: 
			dc_stage <= 0;
		BTYPEEX: begin 
			if (branch_happen == 1)
				pc <= alu_result_current;
			dc_stage <= 0;
		end
		ITYPEWB: 
			dc_stage <= 0;
		JWRITE: begin
			dc_stage <= dc_stage_next;
		end
		JREAD: begin
			dc_stage <= 0;
			pc <= reg_rs_data;
		end
		JEX: 
			pc <= extension_26;
		default: begin
			$display("Error Occurs, unexpected stage!\n");
			dc_stage <= 0;
		end
	  endcase
	end

	always @(posedge reset) begin
		if (reset) begin
			dc_ins <= 0;
			dc_stage <= 0;
			// currents
			mem_data_current <= 0; 
			alu_result_current <= 0; 
		end
	end

	// control signals

	always @* begin
		alu_op = 0;	alu_mask = 0; alu_imm1 = 0; alu_imm0 = 0; 
		mem_addr = 0; mem_write_en = 0; mem_write_data = 0;
		reg_rs = dc_reg_s; reg_rt = dc_reg_t; reg_rd = dc_reg_d;
		reg_rd_data = 0; reg_write_en = 0; dc_stage_next = 0;

		case (dc_stage)
		  FETCH: begin
		  	alu_mask = 2'b11; alu_imm1 = pc; alu_imm0 = 4; alu_op = 0; mem_addr = pc; 
		  end
		  DECODE: begin
		  	// decoder
			if (dc_type_load | dc_type_save) 
				dc_stage_next = MEMADR;
			
			if (dc_type_r) 
				dc_stage_next = RTYPEEX;
			
			if (dc_type_i) 
				dc_stage_next = ITYPEEX;
			
			if (dc_type_b) begin
				dc_stage_next = BTYPEEX;
				alu_mask = 2'b11; alu_imm1 = pc; alu_imm0 = extension_16_addr; alu_op = 4'b1011; // a + b - 4
			end
			if (dc_ins_j) begin
				dc_stage_next = JEX;
			if (dc_ins_jal | dc_ins_jalr)
				dc_stage_next = JWRITE;
			if (dc_ins_jr)
				dc_stage_next = JREAD;
		  end
		  MEMADR: begin
		  	alu_mask = 2'b01;
		  	alu_imm0 = extension_signed_16;
		  	alu_op = 0;
		  	if (dc_ins_sw)
		  		dc_stage_next = MEMWR;
		  	else
		  		dc_stage_next = MEMRD;
		  end
		  MEMRD: begin
		  	mem_addr = alu_result_current;
		  	if (dc_type_load)
		  		dc_stage_next = MEMWB;
		  	if (dc_type_save)
		  		dc_stage_next = MEMWR;
		  end
		  MEMWB: begin
		  	// Mem -> Reg
		  	reg_rd = dc_reg_t;
		  	if (dc_ins_lw)
		  		reg_rd_data = mem_data_current;
		  	else begin
			  	if (dc_ins_lb | dc_ins_lbu) begin
				  	by_pos = {dc_ins_lb, 1'b0, alu_result_current[1:0]}
					reg_rd_data = result_b;
				end else begin
					hl_pos = {dc_ins_lh, 1'b0, alu_result_current[1]}
					reg_rd_data = result_h;
				end
		  	end 
		  	reg_write_en = 1;
		  end
		  MEMWR: begin
		  	// Reg -> Mem
		  	mem_addr = alu_result_current;
		  	if (dc_ins_sw)
		  		mem_write_data = reg_rt_data;
		  	else begin
			  	if (dc_ins_sb) begin
				  	by_pos = {1'b0, 1'b1, alu_result_current[1:0]}
					mem_write_data = result_b;
				end else begin
					hl_pos = {1'b0, 1'b1, alu_result_current[1]}
					mem_write_data = result_h;
				end
		  	end
		  	mem_write_en = 1;
		  end
		  RTYPEEX: begin
		  	alu_op = dc_rr_alu_op;
			if (dc_ins_sll | dc_ins_srl | dc_ins_sra) begin
				alu_mask = 2'b10;
				alu_imm1 = {{27{x}}, dc_smt};
			end else alu_mask = 2'b00;
		  end
		  RTYPEWB: begin
		  	if ((alu_flags[1] | alu_flags[0]) & (dc_ins_add | dc_ins_sub))
			  	$display("Overflow Happened, nothing written");
			else begin
				reg_rd = dc_reg_d;
				reg_rd_data = alu_result_current;
				reg_write_en = 1;
			end
		  end
		  BTYPEEX: begin
		  	// determine by command
			alu_op = 4'b0001;
			if (dc_ins_beq | dc_ins_bne) begin
				alu_mask = 2'b00;
		  		branch_happen = dc_ins_bne ^ alu_flags[2]; // zf differ from bne
			end else begin
				alu_mask = 2'b01;
				alu_imm0 = 0; // a - 0 
				branch_happen = (dc_type_be & alu_flags[2]) | (dc_type_gt ^ alu_flags[3]) // gt differ from ne
			end
		  end
		  ITYPEEX: begin
		  	alu_op = dc_ri_alu_op;
			alu_mask = 2'01;
			alu_imm0 = dc_ri_signed_extension ? (extension_signed_16) : (dc_ri_high_extension ? extension_high_16 : extension_zero_16);
		  end
		  ITYPEWB: begin
			if ((alu_flags[1] | alu_flags[0]) & (dc_ins_addi))
				$display("Overflow Happened, nothing written");
			else begin
				reg_rd = dc_reg_d;
				reg_rd_data = alu_result_current;
				reg_write_en = 1;
			end
		  end
		  JWRITE: begin
		  	reg_rd = dc_ins_jal ? (31) : dc_reg_d;
			reg_rd_data = pc;
			reg_write_en = 1;
			dc_stage_next = dc_ins_jal ? JEX : JREAD; // jalr
		  end
		  JREAD: begin
		  	reg_rs = dc_reg_s;
		  end
		  JEX: begin
		  	// nop
			// - can be opt by reduce this code
		  end
		endcase
	end

	/// half & byte ops

	half_op hf(mem_data_current, hl_pos, reg_rt_data[7:0], result_h);
	byte_op hf(mem_data_current, by_pos, reg_rt_data[7:0], result_b);

	wire [2:0] hl_pos;
	wire [3:0] by_pos;

	wire [31:0] result_h;
	wire [31:0] result_b;

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

	wire [31:0] extension_26;
	wire [31:0] extension_signed_16;
	wire [31:0] extension_zero_16;
	wire [31:0] extension_high_16;
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

	wire [3:0] dc_rr_alu_op;

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

	wire [3:0] dc_ri_alu_op;

	// 分支
	wire dc_ins_beq;
	wire dc_ins_bne;
	wire dc_ins_blez;
	wire dc_ins_bgtz;
	wire dc_ins_bltz;
	wire dc_ins_bgez;
	wire dc_type_b;
	wire dc_type_be;
	wire dc_type_gt;
	wire branch_happen;
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
	assign dc_op = dc_ins[31:26];

	// 加载
	assign dc_ins_lb = dc_op == 6'b100000 ?1'b1:1'b0;
	assign dc_ins_lbu = dc_op == 6'b100100 ?1'b1:1'b0;
	assign dc_ins_lh = dc_op == 6'b100001 ?1'b1:1'b0;
	assign dc_ins_lhu = dc_op == 6'b100101 ?1'b1:1'b0;
	assign dc_ins_lw = dc_op == 6'b100011 ?1'b1:1'b0;
	assign dc_type_load = dc_ins_lb | dc_ins_lbu | dc_ins_lh | dc_ins_lhu | dc_ins_lw;
	// 保存
	assign dc_ins_sb = dc_op == 6'b101000 ?1'b1:1'b0;
	assign dc_ins_sh = dc_op == 6'b101001 ?1'b1:1'b0;
	assign dc_ins_sw = dc_op == 6'b101011 ?1'b1:1'b0;
	assign dc_type_save = dc_ins_sb | dc_ins_sh | dc_ins_sw;
	// R-R运算
	assign dc_ins_add = (dc_op == 6'b000000) & (dc_funt == 6'b100000) ?1'b1:1'b0;
	assign dc_ins_addu = (dc_op == 6'b000000) & (dc_funt == 6'b100001 ?1'b1:1'b0);
	assign dc_ins_sub = (dc_op == 6'b000000) & (dc_funt == 6'b100010) ?1'b1:1'b0;
	assign dc_ins_subu = (dc_op == 6'b000000) & (dc_funt == 6'b100011) ?1'b1:1'b0;
	assign dc_ins_slt = (dc_op == 6'b000000) & (dc_funt == 6'b101010) ?1'b1:1'b0;
	assign dc_ins_sltu = (dc_op == 6'b000000) & (dc_funt == 6'b101011) ?1'b1:1'b0;
	assign dc_ins_sll = (dc_op == 6'b000000) & (dc_funt == 6'b000000) ?1'b1:1'b0;
	assign dc_ins_srl = (dc_op == 6'b000000) & (dc_funt == 6'b000010) ?1'b1:1'b0;
	assign dc_ins_sra = (dc_op == 6'b000000) & (dc_funt == 6'b000011) ?1'b1:1'b0;
	assign dc_ins_sllv = (dc_op == 6'b000000) & (dc_funt == 6'b000100) ?1'b1:1'b0;
	assign dc_ins_srlv = (dc_op == 6'b000000) & (dc_funt == 6'b000110) ?1'b1:1'b0;
	assign dc_ins_srav = (dc_op == 6'b000000) & (dc_funt == 6'b000111) ?1'b1:1'b0;
	assign dc_ins_and = (dc_op == 6'b000000) & (dc_funt == 6'b100100) ?1'b1:1'b0;
	assign dc_ins_or = (dc_op == 6'b000000) & (dc_funt == 6'b100101) ?1'b1:1'b0;
	assign dc_ins_xor = (dc_op == 6'b000000) & (dc_funt == 6'b100110) ?1'b1:1'b0;
	assign dc_ins_nor = (dc_op == 6'b000000) & (dc_funt == 6'b100111) ?1'b1:1'b0;
	assign dc_type_r = dc_ins_add | dc_ins_addu | dc_ins_sub | dc_ins_subu | dc_ins_slt | dc_ins_sltu | dc_ins_sll | dc_ins_srl | dc_ins_sra | dc_ins_sllv | dc_ins_srlv | dc_ins_srav | dc_ins_and | dc_ins_or | dc_ins_xor | dc_ins_nor;

	always @(*) begin
		dc_rr_alu_op = 4'b1111;
		if (dc_ins_add | dc_ins_addu)
			dc_rr_alu_op = 4'b0000;
		if (dc_ins_sub | dc_ins_subu)
			dc_rr_alu_op = 4'b0001;
		if (dc_ins_slt)
			dc_rr_alu_op = 4'b1010;
		if (dc_ins_sltu)
			dc_rr_alu_op = 4'b1001;
		if (dc_ins_sll | dc_ins_sllv)
			dc_rr_alu_op = 4'b0010;
		if (dc_ins_srl | dc_ins_srlv)
			dc_rr_alu_op = 4'b0011;
		if (dc_ins_sra | dc_ins_srav)
			dc_rr_alu_op = 4'b0011;
		if (dc_ins_and)
			dc_rr_alu_op = 4'b0101;
		if (dc_ins_or)
			dc_rr_alu_op = 4'b0110;
		if (dc_ins_xor)
			dc_rr_alu_op = 4'b0111;
		if (dc_ins_nor)
			dc_rr_alu_op = 4'b1000;
	end

	// R-I运算
	assign dc_ins_addi = dc_op == 6'b001000 ?1'b1:1'b0;
	assign dc_ins_addiu = dc_op == 6'b001001 ?1'b1:1'b0;
	assign dc_ins_andi = dc_op == 6'b001100 ?1'b1:1'b0;
	assign dc_ins_ori = dc_op == 6'b001101 ?1'b1:1'b0;
	assign dc_ins_xori = dc_op == 6'b001110 ?1'b1:1'b0;
	assign dc_ins_lui = dc_op == 6'b001111 ?1'b1:1'b0; // [SPECIAL] high_extension
	assign dc_ins_slti = dc_op == 6'b001010 ?1'b1:1'b0;
	assign dc_ins_sltiu = dc_op == 6'b001011 ?1'b1:1'b0;
	assign dc_type_i = dc_ins_addi | dc_ins_addiu | dc_ins_andi | dc_ins_ori | dc_ins_xori | dc_ins_lui | dc_ins_slti | dc_ins_sltiu;

	assign dc_ri_signed_extension = (dc_ins_addi | dc_ins_addiu | dc_ins_slti | dc_ins_sltiu);
	assign dc_ri_high_extension = dc_ins_lui;

	always @(*) begin
		dc_ri_alu_op = 4'b1111;
		if (dc_ins_addi | dc_ins_addiu)
			dc_ri_alu_op = 4'b0000;
		if (dc_ins_andi)
			dc_ri_alu_op = 4'b0101;
		if (dc_ins_ori)
			dc_ri_alu_op = 4'b0110;
		if (dc_ins_xori)
			dc_ri_alu_op = 4'b0111;
		if (dc_ins_lui)
			dc_ri_alu_op = 4'b1111;
		if (dc_ins_slti)
			dc_ri_alu_op = 4'b1010;
		if (dc_ins_sltiu)
			dc_ri_alu_op = 4'b1001;
	end

	// 分支
	assign dc_ins_beq = dc_op == 6'b000100 ?1'b1:1'b0; // a==b
	assign dc_ins_bne = dc_op == 6'b000101 ?1'b1:1'b0; // a!=b
	assign dc_ins_blez = dc_op == 6'b000110 ?1'b1:1'b0; // a <= 0
	assign dc_ins_bgtz = dc_op == 6'b000111 ?1'b1:1'b0; // a > 0
	assign dc_ins_bltz = (dc_op == 6'b000001) & (dc_reg_t == 5'b00000) ?1'b1:1'b0; // a < 0
	assign dc_ins_bgez = (dc_op == 6'b000001) & (dc_reg_t == 5'b00001) ?1'b1:1'b0; // a >= 0
	assign dc_type_b = dc_ins_beq | dc_ins_bne | dc_ins_blez | dc_ins_bgtz | dc_ins_bltz | dc_ins_bgez;
	assign dc_type_be = dc_ins_blez | dc_ins_bgez;
	assign dc_type_gt = dc_ins_bgtz | dc_ins_bgez;
	// 跳转
	assign dc_ins_j = dc_op == 6'b000010 ?1'b1:1'b0;
	assign dc_ins_jal = dc_op == 6'b000011 ?1'b1:1'b0;
	assign dc_ins_jalr = (dc_op == 6'b000000) & (dc_funt == 6'b001001) ?1'b1:1'b0;
	assign dc_ins_jr = (dc_op == 6'b000000) & (dc_funt == 6'b001000) ?1'b1:1'b0;
	assign dc_type_jump = dc_ins_j | dc_ins_jal | dc_ins_jalr | dc_ins_jr;
	// 传输
	assign dc_ins_mfhi = (dc_op == 6'b000000) & (dc_funt == 6'b010000) ?1'b1:1'b0;
	assign dc_ins_mflo = (dc_op == 6'b000000) & (dc_funt == 6'b010010) ?1'b1:1'b0;
	assign dc_ins_mthi = (dc_op == 6'b000000) & (dc_funt == 6'b010001) ?1'b1:1'b0;
	assign dc_ins_mtlo = (dc_op == 6'b000000) & (dc_funt == 6'b010011) ?1'b1:1'b0;

endmodule