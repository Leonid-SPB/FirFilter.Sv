@echo off
vlib work
vlog ..\src\design1\FirFilterNonSymmetric.sv
vlog ..\src\design1\FirFilterSymmetric.sv
vlog ..\src\design1\FirFilter.sv
vlog FirFilter_tb.sv
pause