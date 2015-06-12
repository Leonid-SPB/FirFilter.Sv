@echo off
vlog ..\src\systolic\FirFilterNonSymmetric.sv
vlog ..\src\systolic\FirFilterSymmetric.sv
vlog ..\src\systolic\FirFilter.sv
vlog FirFilter_tb.sv
vsim FirFilter_tb -do "do wave.do; run -all"