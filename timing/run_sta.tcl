read_liberty $::env(LIB_FILE)
read_verilog $::env(NETLIST_FILE)
link_design sensor_anomaly_detector
read_sdc /project/constraints/sensor_anomaly_detector.sdc

if { [info exists ::env(SPEF_FILE)] } {
    read_spef $::env(SPEF_FILE)
}

puts "----- SETUP (max) -----"
report_checks -path_delay max -format summary -digits 4

puts "----- HOLD (min) -----"
report_checks -path_delay min -format summary -digits 4

exit
