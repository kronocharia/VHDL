
proc syn_dump_io {} {
	execute_module -tool cdb -args "--back_annotate=pin_device"
}

source "C:/synopsys/fpga_G201209SP1/lib/altera/quartus_cons.tcl"
syn_create_and_open_prj rcb_post
source $::quartus(binpath)/prj_asd_import.tcl
syn_create_and_open_csf rcb_post
syn_handle_cons rcb_post
syn_compile_quartus
syn_dump_io
