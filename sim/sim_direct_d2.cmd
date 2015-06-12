@echo off
vlog ..\src\direct_design2\FirFilterTree.sv
vlog ..\src\direct_design2\FirFilterDelayLine.sv
vlog ..\src\direct_design2\FirFilter.sv
vlog FirFilter_tb.sv
vsim FirFilter_tb -do "do wave.do; run -all"