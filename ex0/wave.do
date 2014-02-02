onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /f3_alu_tb/clk
add wave -noupdate /f3_alu_tb/reset
add wave -noupdate /f3_alu_tb/y_i
add wave -noupdate /f3_alu_tb/f_i
add wave -noupdate /f3_alu_tb/z_i
add wave -noupdate /f3_alu_tb/result1
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1250 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 196
configure wave -valuecolwidth 92
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {0 ns} {9865 ns}
