module alu(
	// a = rs, b = rt
	a, b, imm1, imm0, op, mask /*ab*/,
	result, flags
);
	input [31:0] a;
	input [31:0] b;
	input [31:0] imm1;
	input [31:0] imm0;
	input [3:0] op;
	input [1:0] mask;

	output [31:0] result;
	output [3:0] flags;

	wire [31:0] _mux_a;
	wire [31:0] _mux_b;

	wire [32:0] mux_a;
	wire [32:0] mux_b;
	reg [32:0] c;

	wire carry;

	assign _mux_a = mask[1] ? imm1 : a;
	assign _mux_b = mask[0] ? imm0 : b;
	assign mux_a = {_mux_a[31], _mux_a};
	assign mux_b = {_mux_b[31], _mux_b};
	assign result = c[31:0];

	//zf of uf
	assign flags = {c[31], result == 0,  c[32:31] == 2'b01,  c[32:31] == 2'b10};

	always @* begin
	  	case (op)
        	4'b0000: c = mux_a + mux_b; 
        	4'b0001: c = mux_a - mux_b;
        	4'b0010: c = mux_b << mux_a[4:0];
        	4'b0011: c = mux_b >> mux_a[4:0];
			4'b0100: c = $signed(mux_b) >>> mux_a[4:0]; 
        	4'b0101: c = mux_a & mux_b;
        	4'b0110: c = mux_a | mux_b;
        	4'b0111: c = mux_a ^ mux_b;
			4'b1000: c = mux_a ~| mux_b;    
        	4'b1001: c = (mux_a < mux_b) ? 32'b1 : 32'b0; // sltu
        	4'b1010: c = ($signed(mux_a) < $signed(mux_b)) ? 32'b1 : 32'b0; // slt
			4'b1011: c = mux_a + mux_b - 4;
       		default: c = 0;
		endcase
	end
endmodule