onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /Trivial_tb/clk
add wave -noupdate /Trivial_tb/rst
add wave -noupdate /Trivial_tb/valid_in
add wave -noupdate /Trivial_tb/valid_out
add wave -noupdate -format Analog-Step -height 74 -max 32766.999999999993 -min -32768.0 -radix decimal /Trivial_tb/din
add wave -noupdate -format Analog-Step -height 74 -max 247562240.00000012 -min -2281472000.0 -radix decimal -childformat {{{/Trivial_tb/dout[32]} -radix decimal} {{/Trivial_tb/dout[31]} -radix decimal} {{/Trivial_tb/dout[30]} -radix decimal} {{/Trivial_tb/dout[29]} -radix decimal} {{/Trivial_tb/dout[28]} -radix decimal} {{/Trivial_tb/dout[27]} -radix decimal} {{/Trivial_tb/dout[26]} -radix decimal} {{/Trivial_tb/dout[25]} -radix decimal} {{/Trivial_tb/dout[24]} -radix decimal} {{/Trivial_tb/dout[23]} -radix decimal} {{/Trivial_tb/dout[22]} -radix decimal} {{/Trivial_tb/dout[21]} -radix decimal} {{/Trivial_tb/dout[20]} -radix decimal} {{/Trivial_tb/dout[19]} -radix decimal} {{/Trivial_tb/dout[18]} -radix decimal} {{/Trivial_tb/dout[17]} -radix decimal} {{/Trivial_tb/dout[16]} -radix decimal} {{/Trivial_tb/dout[15]} -radix decimal} {{/Trivial_tb/dout[14]} -radix decimal} {{/Trivial_tb/dout[13]} -radix decimal} {{/Trivial_tb/dout[12]} -radix decimal} {{/Trivial_tb/dout[11]} -radix decimal} {{/Trivial_tb/dout[10]} -radix decimal} {{/Trivial_tb/dout[9]} -radix decimal} {{/Trivial_tb/dout[8]} -radix decimal} {{/Trivial_tb/dout[7]} -radix decimal} {{/Trivial_tb/dout[6]} -radix decimal} {{/Trivial_tb/dout[5]} -radix decimal} {{/Trivial_tb/dout[4]} -radix decimal} {{/Trivial_tb/dout[3]} -radix decimal} {{/Trivial_tb/dout[2]} -radix decimal} {{/Trivial_tb/dout[1]} -radix decimal} {{/Trivial_tb/dout[0]} -radix decimal}} -subitemconfig {{/Trivial_tb/dout[32]} {-radix decimal} {/Trivial_tb/dout[31]} {-radix decimal} {/Trivial_tb/dout[30]} {-radix decimal} {/Trivial_tb/dout[29]} {-radix decimal} {/Trivial_tb/dout[28]} {-radix decimal} {/Trivial_tb/dout[27]} {-radix decimal} {/Trivial_tb/dout[26]} {-radix decimal} {/Trivial_tb/dout[25]} {-height 15 -radix decimal} {/Trivial_tb/dout[24]} {-height 15 -radix decimal} {/Trivial_tb/dout[23]} {-height 15 -radix decimal} {/Trivial_tb/dout[22]} {-height 15 -radix decimal} {/Trivial_tb/dout[21]} {-height 15 -radix decimal} {/Trivial_tb/dout[20]} {-height 15 -radix decimal} {/Trivial_tb/dout[19]} {-height 15 -radix decimal} {/Trivial_tb/dout[18]} {-height 15 -radix decimal} {/Trivial_tb/dout[17]} {-height 15 -radix decimal} {/Trivial_tb/dout[16]} {-height 15 -radix decimal} {/Trivial_tb/dout[15]} {-height 15 -radix decimal} {/Trivial_tb/dout[14]} {-height 15 -radix decimal} {/Trivial_tb/dout[13]} {-height 15 -radix decimal} {/Trivial_tb/dout[12]} {-height 15 -radix decimal} {/Trivial_tb/dout[11]} {-height 15 -radix decimal} {/Trivial_tb/dout[10]} {-height 15 -radix decimal} {/Trivial_tb/dout[9]} {-height 15 -radix decimal} {/Trivial_tb/dout[8]} {-height 15 -radix decimal} {/Trivial_tb/dout[7]} {-height 15 -radix decimal} {/Trivial_tb/dout[6]} {-height 15 -radix decimal} {/Trivial_tb/dout[5]} {-height 15 -radix decimal} {/Trivial_tb/dout[4]} {-height 15 -radix decimal} {/Trivial_tb/dout[3]} {-height 15 -radix decimal} {/Trivial_tb/dout[2]} {-height 15 -radix decimal} {/Trivial_tb/dout[1]} {-height 15 -radix decimal} {/Trivial_tb/dout[0]} {-height 15 -radix decimal}} /Trivial_tb/dout
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1512224 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 223
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
WaveRestoreZoom {0 ps} {10273840 ps}
