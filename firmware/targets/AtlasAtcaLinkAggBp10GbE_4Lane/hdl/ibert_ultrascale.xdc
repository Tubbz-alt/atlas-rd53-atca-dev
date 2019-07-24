set_property C_CLK_INPUT_FREQ_HZ 156250000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER true [get_debug_cores dbg_hub]

set_property PACKAGE_PIN J29 [get_ports qsfpSpareRefClkP]
set_property PACKAGE_PIN J30 [get_ports qsfpSpareRefClkN]

create_clock -name qsfpSpareRefClkP -period 6.4 [get_ports qsfpSpareRefClkP]
set_clock_groups -group [get_clocks qsfpSpareRefClkP -include_generated_clocks] -asynchronous
set_clock_groups -group [get_clocks fabEthRefClkP    -include_generated_clocks] -asynchronous

set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_IBERT/inst/QUAD[0].u_q/CH[0].u_ch/u_gtye4_channel/TXOUTCLKPCS}]] -group [get_clocks -of_objects [get_pins dbg_hub/inst/BSCANID.u_xsdbm_id/USE_DIVIDER.ULTRASCALEPLUS.U_GT_MMCM/CLKOUT0]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_IBERT/inst/QUAD[0].u_q/CH[1].u_ch/u_gtye4_channel/TXOUTCLKPCS}]] -group [get_clocks -of_objects [get_pins dbg_hub/inst/BSCANID.u_xsdbm_id/USE_DIVIDER.ULTRASCALEPLUS.U_GT_MMCM/CLKOUT0]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_IBERT/inst/QUAD[0].u_q/CH[2].u_ch/u_gtye4_channel/TXOUTCLKPCS}]] -group [get_clocks -of_objects [get_pins dbg_hub/inst/BSCANID.u_xsdbm_id/USE_DIVIDER.ULTRASCALEPLUS.U_GT_MMCM/CLKOUT0]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_IBERT/inst/QUAD[0].u_q/CH[3].u_ch/u_gtye4_channel/TXOUTCLKPCS}]] -group [get_clocks -of_objects [get_pins dbg_hub/inst/BSCANID.u_xsdbm_id/USE_DIVIDER.ULTRASCALEPLUS.U_GT_MMCM/CLKOUT0]]

# file: ibert_ultrascale_gty_0.xdc
####################################################################################
##   ____  ____ 
##  /   /\/   /
## /___/  \  /    Vendor: Xilinx
## \   \   \/     Version : 2017.1
##  \   \         Application : IBERT Ultrascale
##  /   /         Filename : ibert_ultrascale_gty_ip_example.xdc
## /___/   /\     
## \   \  /  \ 
##  \___\/\___\
##
##
## 
## Generated by Xilinx IBERT Ultrascale
##**************************************************************************
## TX/RX out clock clock constraints
##
# GT X0Y12
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_IBERT/inst/QUAD[0].u_q/CH[0].u_ch/u_gtye4_channel/RXOUTCLK}] -include_generated_clocks]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_IBERT/inst/QUAD[0].u_q/CH[0].u_ch/u_gtye4_channel/TXOUTCLK}] -include_generated_clocks]
# GT X0Y13
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_IBERT/inst/QUAD[0].u_q/CH[1].u_ch/u_gtye4_channel/RXOUTCLK}] -include_generated_clocks]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_IBERT/inst/QUAD[0].u_q/CH[1].u_ch/u_gtye4_channel/TXOUTCLK}] -include_generated_clocks]
# GT X0Y14
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_IBERT/inst/QUAD[0].u_q/CH[2].u_ch/u_gtye4_channel/RXOUTCLK}] -include_generated_clocks]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_IBERT/inst/QUAD[0].u_q/CH[2].u_ch/u_gtye4_channel/TXOUTCLK}] -include_generated_clocks]
# GT X0Y15
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_IBERT/inst/QUAD[0].u_q/CH[3].u_ch/u_gtye4_channel/RXOUTCLK}] -include_generated_clocks]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_IBERT/inst/QUAD[0].u_q/CH[3].u_ch/u_gtye4_channel/TXOUTCLK}] -include_generated_clocks]
