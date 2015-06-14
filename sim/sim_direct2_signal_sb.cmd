@echo off
vlib work
vlog ..\src\direct_design2\FirFilterTree.sv
vlog ..\src\direct_design2\FirFilterDelayLine.sv
vlog ..\src\direct_design2\FirFilter.sv
vlog SignalTesterShortBurst.sv
vlog SignalTest_tb.sv
vsim SignalTest_tb -do "do SignalTest_wave.do; run -all"
