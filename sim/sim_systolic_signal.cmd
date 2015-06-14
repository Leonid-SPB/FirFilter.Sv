@echo off
vlib work
vlog ..\src\systolic\FirFilterNonSymmetric.sv
vlog ..\src\systolic\FirFilterSymmetric.sv
vlog ..\src\systolic\FirFilter.sv
vlog SignalTester.sv
vlog SignalTest_tb.sv
vsim SignalTest_tb -do "do SignalTest_wave.do; run -all"
