@echo off
call compile_d2_tb.cmd
vsim FirFilter_tb -do "do wave.do; run -all"