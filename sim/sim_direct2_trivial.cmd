@echo off
vlog ..\src\direct_design2\FirFilterTree.sv
vlog ..\src\direct_design2\FirFilterDelayLine.sv
vlog ..\src\direct_design2\FirFilter.sv
vlog Trivial_tb.sv
vsim Trivial_tb -do "do Trivial_wave.do; run -all"