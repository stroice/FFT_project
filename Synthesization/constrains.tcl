set_ideal_network [get_ports clk]
set_ideal_network [get_ports rst]

#Minimum consumption (all out)

#Minimum Area
#set_max_area 0

#Frequency MAX
create_clock -name clk -period 0.81 [get_ports clk]

#MAX frequency pipeling memory
#create_clock -name clk -period 0.73 [get_ports clk]

#Uncertanity ignored
set_clock_uncertainty -setup 0.0 [get_clocks clk]
set_clock_uncertainty -hold 0.0 [get_clocks clk]

set_input_delay 0.27 -max -clock clk [get_ports {X_in Y_in}]
#set_input_delay 0 -min -clock clk [get_ports {X_in Y_in}]

set_output_delay 0.2 -max -clock clk [get_ports {X_out Y_out}]
#set_input_delay 0 -min -clock clk [get_ports {X_out Y_out}]

#Access times for writting of the different memories
set_input_delay 0.456 -max -clock clk [get_ports {M_out1_X M_out1_Y }]
#set_input_delay 0.0 -min -clock clk [get_ports {M_out1_X M_out1_Y}]

set_input_delay 0.430 -max -clock clk [get_ports {M_out2_X M_out2_Y }]
#set_input_delay 0.0 -min -clock clk [get_ports {M_out2_X M_out2_Y}]

set_input_delay 0.418 -max -clock clk [get_ports {M_out3_X M_out3_Y }]
#set_input_delay 0.0 -min -clock clk [get_ports {M_out3_X M_out3_Y}]

set_input_delay 0.392 -max -clock clk [get_ports {M_out4_X M_out4_Y }]
#set_input_delay 0.0 -min -clock clk [get_ports {M_out4_X M_out4_Y}]

#setup times for reading of the different memories
set_output_delay 0.093 -max -clock clk [get_ports {M_in1_X M_in1_Y }]
#set_output_delay 0.0 -min -clock clk [get_ports {M_in1_X M_in1_Y}]

set_output_delay 0.094 -max -clock clk [get_ports {M_in2_X M_in2_Y }]
#set_output_delay 0.0 -min -clock clk [get_ports {M_in2_X M_in2_Y}]

set_output_delay 0.095 -max -clock clk [get_ports {M_in3_X M_in3_Y }]
#set_output_delay 0.0 -min -clock clk [get_ports {M_in3_X M_in3_Y}]

set_output_delay 0.097 -max -clock clk [get_ports {M_in4_X M_in4_Y }]
#set_output_delay 0.0 -min -clock clk [get_ports {M_in4_X M_in4_Y}]
