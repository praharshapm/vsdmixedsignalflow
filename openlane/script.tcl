package require openlane 0.9
prep -design design_mux -overwrite
set lefs 	 [glob $::env(DESIGN_DIR)/src/lef/*.lef]
add_lefs -src $lefs
run_synthesis
init_floorplan_or
place_io
global_placement_or
detailed_placement
tap_decap_or
detailed_placement
gen_pdn
run_routing
run_magic_drc
run_magic
