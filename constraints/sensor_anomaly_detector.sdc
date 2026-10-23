create_clock -name clk -period 15.0 [get_ports clk]
set_clock_uncertainty 0.1 [get_clocks clk]
