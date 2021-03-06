# Load RUCKUS library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Get the family type
set family [getFpgaFamily]

if { ${family} eq {kintexu} } {
   set fpgaType "UltraScale"
}

if { ${family} eq {kintexuplus} ||
     ${family} eq {virtexuplus} ||
     ${family} eq {virtexuplusHBM} ||
     ${family} eq {zynquplus} ||
     ${family} eq {zynquplusRFSOC} } {
   set fpgaType "UltraScale+"
}
loadSource -dir           "$::DIR_PATH/rtl"
loadSource -sim_only -dir "$::DIR_PATH/tb"

loadSource      -dir  "$::DIR_PATH/ip"
loadConstraints -dir  "$::DIR_PATH/ip"

loadSource -path "$::DIR_PATH/ip/${fpgaType}/xlx_ku_mgt_10g24.vhd"
loadIpCore -path "$::DIR_PATH/ip/${fpgaType}/xlx_ku_mgt_ip_10g24.xci"

loadConstraints -path "$::DIR_PATH/ip/${fpgaType}/xlx_ku_mgt_ip_10g24.xdc"
set_property PROCESSING_ORDER {EARLY}               [get_files {xlx_ku_mgt_ip_10g24.xdc}]
set_property SCOPED_TO_REF    {xlx_ku_mgt_ip_10g24} [get_files {xlx_ku_mgt_ip_10g24.xdc}]
set_property SCOPED_TO_CELLS  {inst}                [get_files {xlx_ku_mgt_ip_10g24.xdc}]

loadSource -path "$::DIR_PATH/ip/${fpgaType}/xlx_ku_mgt_10g24_emu.vhd"
loadSource -path "$::DIR_PATH/ip/${fpgaType}/xlx_ku_mgt_10g24_emu_qpll.vhd"
loadIpCore -path "$::DIR_PATH/ip/${fpgaType}/xlx_ku_mgt_ip_10g24_emu.xci"

loadConstraints -path "$::DIR_PATH/ip/${fpgaType}/xlx_ku_mgt_ip_10g24_emu.xdc"
set_property PROCESSING_ORDER {EARLY}                   [get_files {xlx_ku_mgt_ip_10g24_emu.xdc}]
set_property SCOPED_TO_REF    {xlx_ku_mgt_ip_10g24_emu} [get_files {xlx_ku_mgt_ip_10g24_emu.xdc}]
set_property SCOPED_TO_CELLS  {inst}                    [get_files {xlx_ku_mgt_ip_10g24_emu.xdc}]

if { ${family} eq {kintexuplus} } {
   loadIpCore -path "$::DIR_PATH/ip/${fpgaType}/xlx_ku_gty_ip_10g24_emu.xci"

   loadConstraints -path "$::DIR_PATH/ip/${fpgaType}/xlx_ku_gty_ip_10g24_emu.xdc"
   set_property PROCESSING_ORDER {EARLY}                   [get_files {xlx_ku_gty_ip_10g24_emu.xdc}]
   set_property SCOPED_TO_REF    {xlx_ku_gty_ip_10g24_emu} [get_files {xlx_ku_gty_ip_10g24_emu.xdc}]
   set_property SCOPED_TO_CELLS  {inst}                    [get_files {xlx_ku_gty_ip_10g24_emu.xdc}]
}

# Adding the common Si5345 configuration
add_files -norecurse "$::DIR_PATH/pll-config/AtlasRd53Fmc_EmuLpGbt.mem"
add_files -norecurse "$::DIR_PATH/pll-config/AtlasRd53Fmc_lpcRefClk.mem"
