onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Real
add wave -noupdate /SignalTest_tb/i_SignalTester_re/clk
add wave -noupdate /SignalTest_tb/i_SignalTester_re/rst
add wave -noupdate /SignalTest_tb/i_SignalTester_re/valid_in
add wave -noupdate -format Analog-Step -height 74 -max 32767.0 -min -32767.0 -radix decimal /SignalTest_tb/i_SignalTester_re/din
add wave -noupdate /SignalTest_tb/i_SignalTester_re/valid_out
add wave -noupdate -format Analog-Step -height 74 -max 2282229999.9999995 -min -2036570000.0 -radix decimal /SignalTest_tb/i_SignalTester_re/dout
add wave -noupdate /SignalTest_tb/i_SignalTester_re/finished
add wave -noupdate -divider Imag
add wave -noupdate /SignalTest_tb/i_SignalTester_im/clk
add wave -noupdate /SignalTest_tb/i_SignalTester_im/rst
add wave -noupdate /SignalTest_tb/i_SignalTester_im/valid_in
add wave -noupdate -format Analog-Step -height 74 -max 32767.0 -min -32767.0 -radix decimal /SignalTest_tb/i_SignalTester_im/din
add wave -noupdate /SignalTest_tb/i_SignalTester_im/valid_out
add wave -noupdate -format Analog-Step -height 74 -max 2036570000.0 -min -2036570000.0 -radix decimal /SignalTest_tb/i_SignalTester_im/dout
add wave -noupdate /SignalTest_tb/i_SignalTester_im/finished
add wave -noupdate -divider Combined
add wave -noupdate -format Analog-Step -height 74 -max 2036570000.0 -radix decimal /SignalTest_tb/doutAbs
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {695000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 264
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {11723250 ps}
