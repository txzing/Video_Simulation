transcript on
#compile
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

#vcom -2008 -work work {./RX_DESERIALIZER.vhd}
vlog -vlog01compat -work work {./colorbar_gen.v}
vlog -vlog01compat -work work {./Image_RGB888_YCbCr444.v}
vlog -vlog01compat -work work {./Image_YCbCr444_RGB888.v}
vlog -vlog01compat -work work {./Image_YCbCr444_YCbCr422.v}
vlog -vlog01compat -work work {./Image_YCbCr422_YCbCr444.v}
vlog -vlog01compat -work work {./top_tb.v}


#simulate
vsim -novopt top_tb

add wave -radix hexadecimal *
#add wave -radix hexadecimal /top_tb/colorbar_gen_inst/*
#add wave -radix hexadecimal /top_tb/VIP_inst2/*
add wave -radix hexadecimal /top_tb/VIP_inst3/*
#add wave -radix unsigned /top_tb/colorbar_gen_inst/*
view structure
view signals


run 50ms

