// return org[pos] = val
// big-editon
module byte_op(org, pos, val, result);

	input [31:0] org;
	input [2:0] pos;
	input [7:0] val;

	output [31:0] result;

	always @(*) begin
		result = 0;
		case (pos)
		  4'b100: result = {val, org[23:0]}; // 00 - lower memory, higher data 
		  4'b101: result = {org[31:24], val, org[15:0]};
		  4'b110: result = {org[31:16], val, org[7:0]};
		  4'b111: result = {org[31:8], val}; 

		  4'b000: result = org[31:24];
		  4'b001: result = org[23:16];
		  4'b010: result = org[15:8];
		  4'b011: result = org[7:0];
		  default: result = 0;
		endcase
	end
endmodule

/*

little-editon

module byte_op(org, pos, val, result);

	input [31:0] org;
	input [2:0] pos;
	input [7:0] val;

	output [31:0] result;

	always @(*) begin
		case (pos) begin
		  4'b100: result = {org[31:8], val};; // 00 - lower memory, lower data 
		  4'b101: result = {org[31:16], val, org[7:0]};
		  4'b110: result = {org[31:24], val, org[15:0]};
		  4'b111: result = {val, org[23:0]}
		  4'b000: result = org[7:0];
		  4'b001: result = org[15:8];
		  4'b010: result = org[23:16];
		  4'b011: result = org[31:24];
		default: result = 0;
	  endcase
	end
endmodule

*/