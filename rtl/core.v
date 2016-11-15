`timescale 1ns/1ps
module core;
    
    reg clk;
    reg reset;

    wire [31:0] pc;

    // data memory
    wire [31:0] mem_addr;
    wire [31:0] mem_data;
    wire [31:0] mem_write_data;
    wire mem_write_en;
    reg mem_load;
    memory mem(clk, reset, mem_addr, mem_data, mem_write_data, mem_write_en, mem_load);

    // register file

    wire [4:0] reg_rs;
    wire [4:0] reg_rt;
    wire [4:0] reg_rd;
    wire reg_write_en;
    wire [31:0] reg_rs_data;
    wire [31:0] reg_rt_data;
    wire [31:0] reg_rd_data;

    register reg_file(clk, reset, reg_rs, reg_rt, reg_rd, reg_write_en, reg_rs_data, reg_rt_data, reg_rd_data);

    // alu
    wire [31:0] alu_imm1;
    wire [31:0] alu_imm0;
    wire [3:0] alu_op;
    wire [31:0] alu_result;
    wire [1:0] alu_mask;
    wire [3:0] alu_flags;
    alu core_alu(reg_rs_data, reg_rt_data, alu_imm1, alu_imm0, alu_op, alu_mask, alu_result, alu_flags);
    
    decoder core_deocder(	/* System In */
        clk, reset, 
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
        reg_rd_data, reg_write_en
    );

    // test module
    initial begin
        $display("Start");
        mem_load = 1;reset = 1; #5; reset = 0; mem_load = 0;
    end
    always #1000 begin
      clk = 0; #500; clk = 1; #500;
    end
endmodule
