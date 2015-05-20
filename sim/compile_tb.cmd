@echo off
vlib work
vlog ..\src\FirFilterSymmetric.sv
vlog ..\src\FirFilterNonSymmetric.sv
vlog ..\src\FirFilter.sv
vlog FirFilter_tb.sv
pause