// return org[pos] = val
// big-Endian
module byte_op(org, pos, val, result);

	input [31:0] org;
	input [3:0] pos; // SIGNED MIX/FETCH POS
	input [7:0] val;

	output [31:0] result;

	always @(*) begin
		result = 0;
		case (pos)
		  4'b0100: result = {val, org[23:0]}; // 00 - lower memory, higher data 
		  4'b0101: result = {org[31:24], val, org[15:0]};
		  4'b0110: result = {org[31:16], val, org[7:0]};
		  4'b0111: result = {org[31:8], val}; 

		  4'b0000: result = {24'b0, org[31:24]};
		  4'b0001: result = {24'b0, org[23:16]};
		  4'b0010: result = {24'b0, org[15:8]};
		  4'b0011: result = {24'b0, org[7:0]};

		  4'b1000: result = {{24{org[31]}}, org[31:24]};
		  4'b1001: result = {{24{org[23]}}, org[23:16]};
		  4'b1010: result = {{24{org[15]}}, org[15:8]};
		  4'b1011: result = {{24{org[7]}}, org[7:0]};
		  default: result = 0;
		endcase
	end
endmodule