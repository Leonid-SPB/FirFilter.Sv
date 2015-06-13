@echo off
vlib work
vlog ..\src\direct_design1\FirFilterNonSymmetric.sv
vlog ..\src\direct_design1\FirFilterSymmetric.sv
vlog ..\src\direct_design1\FirFilter.sv
vlog Trivial_tb.sv
vsim Trivial_tb -do "do Trivial_wave.do; run -all"