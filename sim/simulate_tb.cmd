@echo off
vlib work
vlog ..\src\FirFilter.sv
vlog FirFilter_tb.sv
vsim FirFilter_tb -do "do wave.do; run -all"