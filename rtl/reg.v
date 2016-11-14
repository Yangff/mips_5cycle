module register(clk, reset, addr_s, addr_t, addr_d, write_en, data_s, data_t, data_d);
    input clk;
    input reset;

    input [4:0] addr_s;
    output [31:0] data_s;
    input [4:0] addr_t;
    output [31:0] data_t;

    input [4:0] addr_d;
    input [31:0] data_d;
    input write_en;

    reg [31:0] reg_file[0:31];

    integer i;
    always @(posedge reset)
        if (reset)
            for (i = 0; i < 32; i = i + 1)
                reg_file[i] = 0;

    always @(negedge clk)
        if (write_en) begin
          reg_file[addr_d] = data_d;
        end
            

    assign data_s = (addr_s == 5'b0 ? 32'b0 : reg_file[addr_s]);
    assign data_t = (addr_t == 5'b0 ? 32'b0 : reg_file[addr_t]);

endmodule