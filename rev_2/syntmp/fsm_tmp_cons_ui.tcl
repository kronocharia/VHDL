
proc syn_dump_io {} {
	execute_module -tool cdb -args "--back_annotate=pin_device"
}

source "C:/synopsys/fpga_G201209SP1/lib/altera/quartus_cons.tcl"
syn_create_and_open_prj fsm_tmp
source $::quartus(binpath)/prj_asd_import.tcl
syn_create_and_open_csf fsm_tmp
syn_handle_cons fsm_tmp
syn_dump_io
