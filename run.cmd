@echo off
iverilog -o core.out rtl/core.v rtl/reg.v rtl/alu.v rtl/decoder.v rtl/mem.v rtl/byte_op.v  rtl/half_op.v 
copy tests\test_all.dat memfile.dat
vvp core.out > output.dat
tests\cmp.exe output.dat tests\test_all.std