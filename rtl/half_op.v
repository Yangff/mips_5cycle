// return org[pos] = val
// big-Endian
module half_op(org, pos, val, result);

	input [31:0] org;
	input [2:0] pos; // SIGNED MIX/FETCH POS
	input [15:0] val;

	output reg [31:0] result;

	always @(*) begin
		result = 0;
		case (pos)
		  4'b010: result = {val, org[15:0]}; // 00 - lower memory, higher data 
		  4'b011: result = {org[31:16], val}; 

		  4'b000: result = {16'b0, org[31:16]};
		  4'b001: result = {16'b0, org[15:0]};
		  4'b100: result = {{16{org[31]}}, org[31:16]};
		  4'b101: result = {{16{org[15]}}, org[15:0]};
		  default: result = 0;
		endcase
	end
endmodule
