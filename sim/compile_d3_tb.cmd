@echo off
vlib work
vlog ..\src\design3\FirFilterNonSymmetric.sv
vlog ..\src\design3\FirFilterSymmetric.sv
vlog ..\src\design3\FirFilter.sv
vlog FirFilter_tb.sv
pause