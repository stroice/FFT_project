set path "/home/mcre310/TFM/Main/scripts/"
set RTL_PATH "${path}/.."

exec rm -rf work
define_design_lib work -path ${path}/work

#top model to be compiled
set top "FFT_Proposed_LowArea_RAM"

#set design "FFT_Proposed_consumpt"
#set design "FFT_Proposed_area"
set design "FFT_Proposed_max"
#set design "FFT_Proposed_max_PipeMem"

#Libraries technologies

set target_library			"/eda/technologies/tsmc_40nm/digital/Back_End/milkyway/tcbn40lpbwp_200a/frame_only_VHV_0d5_0/tcbn40lpbwp/LM/tcbn40lpbwptc.db"
set synthetic_library 		"dw_foundation.sldb"
set link_library 				"$target_library * $synthetic_library"

set_svf -append ${path}/svf/$design/$top.svf

analyze -lib work -format vhdl {/home/mcre310/TFM/Main/work/Components.vhd}

analyze -lib work -format vhdl {/home/mcre310/TFM/Main/Simp_W8_1Pip.vhd /home/mcre310/TFM/Main/Simp_W4.vhd /home/mcre310/TFM/Main/Rotator_W32.vhd /home/mcre310/TFM/Main/Rotator_W8.vhd /home/mcre310/TFM/Main/Pippelined_Add.vhd /home/mcre310/TFM/Main/Pipeline.vhd /home/mcre310/TFM/Main/phi2rad.vhd /home/mcre310/TFM/Main/NoPIP_Rotator_W4.vhd /home/mcre310/TFM/Main/No_Mem_SDF.vhd /home/mcre310/TFM/Main/MultyPipeline.vhd /home/mcre310/TFM/Main/MicroRot_csd.vhd /home/mcre310/TFM/Main/Full_adder.vhd /home/mcre310/TFM/Main/W4rot.vhd /home/mcre310/TFM/Main/UD_CORDIC_csd_phi.vhd /home/mcre310/TFM/Main/UD_CORDIC_csd.vhd /home/mcre310/TFM/Main/DelayReg.vhd /home/mcre310/TFM/Main/DelayMem.vhd /home/mcre310/TFM/Main/Delay1bit.vhd /home/mcre310/TFM/Main/Delay.vhd /home/mcre310/TFM/Main/Datapath_csd.vhd /home/mcre310/TFM/Main/ctrl_csd.vhd /home/mcre310/TFM/Main/Counter.vhd /home/mcre310/TFM/Main/CORDIC.vhd /home/mcre310/TFM/Main/Control_RotatorW32.vhd /home/mcre310/TFM/Main/Components.vhd /home/mcre310/TFM/Main/Butterfly_SFF_registers.vhd /home/mcre310/TFM/Main/Butterfly_SFF_memories.vhd /home/mcre310/TFM/Main/Butterfly_SDF_registers.vhd /home/mcre310/TFM/Main/Butterfly_SDF_memories.vhd /home/mcre310/TFM/Main/Butterfly_Proposed.vhd /home/mcre310/TFM/Main/buffer_1bit.vhd /home/mcre310/TFM/Main/bin2csd.vhd /home/mcre310/TFM/Main/Adder_Carry.vhd /home/mcre310/TFM/Main/FFT_Proposed_LowArea_RAM.vhd}


elaborate $top -architecture FFT_Proposed_LowArea_RAM_arch -library work -parameters "Input_Data_size = 16"

current_design ${top}_Input_Data_size16

link

ungroup -all -flatten -force

#Constrains
source ./constrains.tcl

check_design

set_fix_hold [all_clocks]

compile_ultra

#Write all necesary reports
report_clock > ${path}/reports/${design}/${design}_clock.report.rpt
report_area > ${path}/reports/${design}/${design}_design.area.rpt
report_timing > ${path}/reports/${design}/${design}_check.timing.rpt


#Write necesary outputs

write -hierarchy -format ddc -output ${path}/ddc/${design}.ddc
write -hierarchy -format verilog -output ${path}/verilog/${design}.v
write_sdf ${path}/timing/${design}.sdf
write_sdc ${path}/sdc/${design}.sdc

report_constraint -verbose -all_violators > ${path}/reports/${design}/${design}_verbose.violations.rpt
report_timing -tran -net -attr -nosplit > ${path}/netlist/${design}.v

exit