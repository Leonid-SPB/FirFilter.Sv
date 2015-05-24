@echo off
vlib work
vlog ..\src\design2\FirFilterTree.sv
vlog ..\src\design2\FirFilterDelayLine.sv
vlog ..\src\design2\FirFilter.sv
vlog FirFilter_tb.sv
pause