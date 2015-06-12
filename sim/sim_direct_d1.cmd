@echo off
vlib work
vlog ..\src\direct_design1\FirFilterNonSymmetric.sv
vlog ..\src\direct_design1\FirFilterSymmetric.sv
vlog ..\src\direct_design1\FirFilter.sv
vlog FirFilter_tb.sv
vsim FirFilter_tb -do "do wave.do; run -all"