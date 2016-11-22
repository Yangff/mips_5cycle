module memory(clk, reset, addr, read_data, write_data, write, load);
    input clk;
    input reset;
    input load;
    input write;

    input [31:0] addr;

    output [31:0] read_data;
    input [31:0] write_data;

    reg [31:0] mem[0:1024];

    wire [9:0] ext_addr;

    assign ext_addr = addr[11:2];

    always @(posedge reset) 
        if (load)
            $readmemh("memfile.dat", mem);

    always @(negedge clk)
        if (write) begin
            mem[ext_addr] <= write_data;
        end

    assign read_data = mem[ext_addr];

endmodule 