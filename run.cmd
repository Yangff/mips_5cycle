iverilog -o core rtl/core.v rtl/reg.v rtl/alu.v rtl/decoder.v rtl/mem.v rtl/byte_op.v  rtl/half_op.v 
copy test_lw_sw_lui_ori.dat memfile.dat
vvp core
copy test_all.dat memfile.dat
vvp core