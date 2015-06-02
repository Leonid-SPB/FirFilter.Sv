@echo off
call compile_d3_tb.cmd
vsim FirFilter_tb -do "do wave.do; run -all"