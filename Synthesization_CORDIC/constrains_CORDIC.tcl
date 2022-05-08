set_ideal_network [get_ports clk]
set_ideal_network [get_ports reset]

#Minimum consumption (all out)

#Minimum Area
#set_max_area 0

#selection of frequency, max speed for clock allowed for the memories are 0.686ns
#Frequency no problem
#create_clock -name clk -period 10.00 [get_ports clk]

#Frequency 500MHzset_ideal_network [get_ports clk]
set_ideal_network [get_ports reset]

#Minimum consumption (all out)

#Minimum Area
#set_max_area 0

#selection of frequency, max speed for clock allowed for the memories are 0.686ns

#Frequency 100MHz
#create_clock -name clk -period 5 [get_ports clk]

#Frequency MAX currently
create_clock -name clk -period 0.6 [get_ports clk]


#Uncertanity ignored
set_clock_uncertainty -setup 0.0 [get_clocks clk]
set_clock_uncertainty -hold 0.0 [get_clocks clk]

set_input_delay 0 -max -clock clk [get_ports {xin yin}]
set_input_delay 0 -min -clock clk [get_ports {xin yin}]
