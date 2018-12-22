vcom -93 -explicit -work work ram.vhd
vcom -93 -explicit -work work avs_memory.vhd
vcom -93 -explicit -work work tb_avs_memory.vhd
vlog -work work src/simpleuart.v 
vlog -work work src/picosoc.v 
vlog -work work src/picorv32.v 

