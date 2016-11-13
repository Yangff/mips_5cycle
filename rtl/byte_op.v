// return org[pos] = val
// big-editon
module byte_op(org, pos, val, result);

    input [31:0] org;
    input [1:0] pos;
    input [7:0] val;

    output [31:0] result;

    always @(*) begin
      case (pos) begin
        4'b00: result = {val, org[23:0]}; // 00 - lower memory, higher data 
        4'b01: result = {org[31:24], val, org[15:0]};
        4'b10: result = {org[31:16], val, org[7:0]};
        4'b11: result = {org[31:8], val}; 
        default: result = 0;
      endcase
    end
endmodule

/*

little-editon

module byte_op(org, pos, val, result);

    input [31:0] org;
    input [1:0] pos;
    input [7:0] val;

    output [31:0] result;

    always @(*) begin
      case (pos) begin
        4'b00: result = {org[31:8], val};; // 00 - lower memory, lower data 
        4'b01: result = {org[31:16], val, org[7:0]};
        4'b10: result = {org[31:24], val, org[15:0]};
        4'b11: result = {val, org[23:0]}
        default: result = 0;
      endcase
    end
endmodule

*/