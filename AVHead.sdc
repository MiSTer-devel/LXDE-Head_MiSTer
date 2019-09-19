# Specify root clocks
create_clock -period "50.0 MHz" [get_ports FPGA_CLK1_50]
create_clock -period "50.0 MHz" [get_ports FPGA_CLK2_50]
create_clock -period "50.0 MHz" [get_ports FPGA_CLK3_50]
create_clock -period "100.0 MHz" [get_pins {soc|spi_0|SCLK_reg|clk}]

derive_pll_clocks

create_generated_clock -source [get_pins {soc|hdmi_pll|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}] \
                       -name VID_CLK -divide_by 2 -duty_cycle 50 [get_nets {soc_system:soc|out_mix:outmixer|vid_clk}]

derive_clock_uncertainty

# Put constraints on input ports
set_false_path -from [get_ports {KEY*}] -to *
set_false_path -from [get_ports {BTN_*}] -to *

# Put constraints on output ports
set_false_path -from * -to [get_ports {LED_*}]
set_false_path -from * -to [get_ports {VGA_*}]
set_false_path -from * -to [get_ports {AUDIO_SPDIF}]
set_false_path -from * -to [get_ports {AUDIO_L}]
set_false_path -from * -to [get_ports {AUDIO_R}]
