@echo off
vlib work
vlog ..\src\direct_design1\FirFilterNonSymmetric.sv
vlog ..\src\direct_design1\FirFilterSymmetric.sv
vlog ..\src\direct_design1\FirFilter.sv
vlog SignalTesterBurst.sv
vlog SignalTest_tb.sv
vsim SignalTest_tb -do "do SignalTest_wave.do; run -all"
