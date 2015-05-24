@echo off
call compile_d1_tb.cmd
vsim FirFilter_tb -do "do wave.do; run -all"