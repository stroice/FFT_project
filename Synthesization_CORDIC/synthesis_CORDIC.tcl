set path "/home/mcre310/TFM/Main/scripts/"
set result_path "/home/mcre310/TFM/Main/scripts/CORDIC/"
set RTL_PATH "${path}/.."

exec rm -rf work
define_design_lib work -path ${path}/work

#top model to be compiled
set top "UD_CORDIC_csd_phi"

#top model to be compiled
#Max frequency
set design "CORDIC_max_freq"
#Min Area
#set design "CORDIC_min_area"

#Libraries technologies

set target_library			"/eda/technologies/tsmc_40nm/digital/Back_End/milkyway/tcbn40lpbwp_200a/frame_only_VHV_0d5_0/tcbn40lpbwp/LM/tcbn40lpbwptc.db"
set synthetic_library 		"dw_foundation.sldb"
set link_library 				"$target_library * $synthetic_library"

set_svf -append ${result_path}/svf/$design/$top.svf

analyze -lib work -format vhdl {/home/mcre310/TFM/Main/work/Components.vhd}

analyze -lib work -format vhdl {/home/mcre310/TFM/Main/Simp_W8_1Pip.vhd /home/mcre310/TFM/Main/Simp_W4.vhd /home/mcre310/TFM/Main/Rotator_W32.vhd /home/mcre310/TFM/Main/Rotator_W8.vhd /home/mcre310/TFM/Main/Pippelined_Add.vhd /home/mcre310/TFM/Main/Pipeline.vhd /home/mcre310/TFM/Main/phi2rad.vhd /home/mcre310/TFM/Main/NoPIP_Rotator_W4.vhd /home/mcre310/TFM/Main/No_Mem_SDF.vhd /home/mcre310/TFM/Main/MultyPipeline.vhd /home/mcre310/TFM/Main/MicroRot_csd.vhd /home/mcre310/TFM/Main/Full_adder.vhd /home/mcre310/TFM/Main/W4rot.vhd /home/mcre310/TFM/Main/UD_CORDIC_csd_phi.vhd /home/mcre310/TFM/Main/UD_CORDIC_csd.vhd /home/mcre310/TFM/Main/DelayReg.vhd /home/mcre310/TFM/Main/DelayMem.vhd /home/mcre310/TFM/Main/Delay1bit.vhd /home/mcre310/TFM/Main/Delay.vhd /home/mcre310/TFM/Main/Datapath_csd.vhd /home/mcre310/TFM/Main/ctrl_csd.vhd /home/mcre310/TFM/Main/Counter.vhd /home/mcre310/TFM/Main/CORDIC.vhd /home/mcre310/TFM/Main/Control_RotatorW32.vhd /home/mcre310/TFM/Main/Components.vhd /home/mcre310/TFM/Main/Butterfly_SFF_registers.vhd /home/mcre310/TFM/Main/Butterfly_SFF_memories.vhd /home/mcre310/TFM/Main/Butterfly_SDF_registers.vhd /home/mcre310/TFM/Main/Butterfly_SDF_memories.vhd /home/mcre310/TFM/Main/Butterfly_Proposed.vhd /home/mcre310/TFM/Main/buffer_1bit.vhd /home/mcre310/TFM/Main/bin2csd.vhd /home/mcre310/TFM/Main/Adder_Carry.vhd /home/mcre310/TFM/Main/FFT_Proposed_LowArea_RAM.vhd}


elaborate $top -architecture arch -library work -parameters "WL = 16, b  = 10,  n = 5"

current_design ${top}_WL16_b10_n5

link

ungroup -all -flatten -force

#Constrains
source ./constrains_CORDIC.tcl

check_design

set_fix_hold [all_clocks]

compile_ultra

#Write all necesary reports
report_clock > ${result_path}/reports/${design}/${design}_clock.report.rpt
report_area > ${result_path}/reports/${design}/${design}_design.area.rpt
report_timing > ${result_path}/reports/${design}/${design}_check.timing.rpt


#Write necesary outputs

write -hierarchy -format ddc -output ${result_path}/ddc/${design}.ddc
write -hierarchy -format verilog -output ${result_path}/verilog/${design}.v
write_sdf ${result_path}/timing/${design}.sdf
write_sdc ${result_path}/sdc/${design}.sdc

report_constraint -verbose -all_violators > ${result_path}/reports/${design}/${design}_verbose.violations.rpt
report_timing -tran -net -attr -nosplit > ${result_path}/netlist/${design}.v

exit