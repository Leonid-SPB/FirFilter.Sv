@echo off
vlog ..\src\systolic\FirFilterNonSymmetric.sv
vlog ..\src\systolic\FirFilterSymmetric.sv
vlog ..\src\systolic\FirFilter.sv
vlog Trivial_tb.sv
vsim Trivial_tb -do "do Trivial_wave.do; run -all"