# User config
set ::env(DESIGN_NAME) design_mux

# Change if needed
set ::env(VERILOG_FILES) [glob $::env(OPENLANE_ROOT)/designs/design_mux/src/design_mux.v]
 #for macro verilog 
set ::env(VERILOG_FILES_BLACKBOX) [glob $::env(OPENLANE_ROOT)/designs/design_mux/src/AMUX2_3V.v]
# for macro lef
set ::env(EXTRA_LEFS) [glob $::env(OPENLANE_ROOT)/designs/design_mux/src/lef/AMUX2_3V.lef] 


# Fill this
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_PORT) "select" 
# low for small designs
set ::env(FP_CORE_UTIL) 20
# optimized value
set ::env(PL_TARGET_DENSITY) 0.4 
#for small designs
set ::env(FP_PDN_VOFFSET) 4
set ::env(FP_PDN_VPITCH) 15
set ::env(FP_PDN_HOFFSET) 4
set ::env(FP_PDN_HPITCH) 15

 


set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(PDK_VARIANT)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}


