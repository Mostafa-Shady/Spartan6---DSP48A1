vlib Work

vlog DSP.v DSP_TB.v MUX_REG.v

vsim -voptargs=+acc work.DSP_TB


add wave *

run -all

#quit -sim