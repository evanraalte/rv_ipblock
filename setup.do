vlib work;

do compile.do

vsim -gui -t ns work.avs_memory_tb

view structure
view signals
view locals
view wave -undock

add wave *

configure wave -timelineunits ns
config wave -signalnamewidth 1

do run.do