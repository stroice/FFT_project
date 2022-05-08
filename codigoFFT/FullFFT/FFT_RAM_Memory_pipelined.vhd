library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package vpkg is
	type v is array(natural range <>) of std_logic_vector(9 downto 0);
end package;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.Components.ALL;
use work.vpkg.all;

entity FFT_RAM_Memory_pipelined is
	generic(	 
		Input_Data_size:	integer:=16			-- Size of the signal data to be processed
		);			
	port(
		rst: 	 		 in  std_logic;
		clk: 	 		 in  std_logic;
	  	X_in:  		 in  std_logic_vector(Input_Data_size -1 downto 0);
		Y_in:  		 in  std_logic_vector(Input_Data_size -1 downto 0);
		
		M_in1_X:   	 out  std_logic_vector(Input_Data_size -1 downto 0); 
	  	M_out1_X: 	 in std_logic_vector(Input_Data_size -1 downto 0);		
		control1: 	 out  std_logic_vector(8 downto 0);
		M_in1_Y:   	 out  std_logic_vector(Input_Data_size -1 downto 0); 
	  	M_out1_Y: 	 in std_logic_vector(Input_Data_size -1 downto 0);		
		control1_2: 	 out  std_logic_vector(8 downto 0);
		
		M_in2_X:   	 out  std_logic_vector(Input_Data_size -1 downto 0); 
	  	M_out2_X: 	 in std_logic_vector(Input_Data_size -1 downto 0);		
		control2: 	 out  std_logic_vector(7 downto 0);
		M_in2_Y:   	 out  std_logic_vector(Input_Data_size -1 downto 0); 
	  	M_out2_Y: 	 in std_logic_vector(Input_Data_size -1 downto 0);		
		control2_2: 	 out  std_logic_vector(7 downto 0);
		
		M_in3_X:   	 out  std_logic_vector(Input_Data_size -1 downto 0); 
	  	M_out3_X: 	 in std_logic_vector(Input_Data_size -1 downto 0);		
		control3: 	 out  std_logic_vector(6 downto 0);
		M_in3_Y:   	 out  std_logic_vector(Input_Data_size -1 downto 0); 
	  	M_out3_Y: 	 in std_logic_vector(Input_Data_size -1 downto 0);		
		control3_2: 	 out  std_logic_vector(6 downto 0);
		
		M_in4_X:   	 out  std_logic_vector(Input_Data_size -1 downto 0); 
	  	M_out4_X: 	 in std_logic_vector(Input_Data_size -1 downto 0);		
		control4: 	 out  std_logic_vector(5 downto 0);
		M_in4_Y:   	 out  std_logic_vector(Input_Data_size -1 downto 0); 
	  	M_out4_Y: 	 in std_logic_vector(Input_Data_size -1 downto 0);		
		control4_2: 	 out  std_logic_vector(5 downto 0);
		
	  	X_out: 		 out std_logic_vector(Input_Data_size -1 downto 0);
		Y_out: 		 out std_logic_vector(Input_Data_size -1 downto 0)
		);
end FFT_RAM_Memory_pipelined;

architecture FFT_RAM_Memory_pipelined_arch of FFT_RAM_Memory_pipelined is

	--First, auxiliar components:

--Piplein lines
component MultyPipeline
	generic(	
	  N:		   natural:=27 ;		  -- Number of pipelines used
	  WL: 	   natural:= 16
	  );		  -- Word Length	
	port(
	  clk: 	 		 in  std_logic;
	  Input:     in  std_logic_vector(WL - 1 downto 0); 
	  Output:    out v (0 to N)
	  );
end component;

--For some reason I have to add this here or it crashes ( Do not found the Delay1bit )
component DelayReg 

	generic(	
		WL: integer:=8;			-- Word Length
		BL: integer:= 1024);		-- Buffer Length
	port(
	  	clk:  in  std_logic;
	  	Din:  in  std_logic_vector(WL -1 downto 0); 
	  	Dout: out std_logic_vector(WL -1 downto 0));
end component;

   component Delay1bit
  	   generic(BL: integer); 
  		port( 
  		  clk:  in  std_logic;
		  Din:  in  std_logic;
	     Dout: out std_logic);
	end component;

component Pipeline
	generic(	
	  WL: 	   integer:= 8);		  -- Word Length	
	port(
	  clk:     in  std_logic;
	  Input:     in  std_logic_vector(WL - 1 downto 0); 
	  Output:    out std_logic_vector(WL - 1 downto 0));
end component;

--Counter for the control
component COUNTER
  generic (
    WIDTH     : integer := 8
    );
  port (
    account   : out STD_LOGIC_VECTOR (WIDTH-1  downto 0);
    start    : in  STD_LOGIC;
    rst      : in  STD_LOGIC;
    clk      : in  STD_LOGIC
    );
end component;


	--Butterfly architectures
	
--Proposed architectures for the stages from 1 to 4 (memories outside of the FFT)

component No_Mem_SDF is
	generic(	 
		N_Stages: 		integer:=3;			-- Butterfly Stage of the butterfly
		Stage: 			integer:=1;			-- Butterfly Stage of the butterfly
		Input_Data_size:	integer:=16			-- Size of the signal data to be processed
		);			
	port(
	  	clk:  		 in  std_logic;
		control: 	 in  std_logic;
	  	Din:  		 in  std_logic_vector(Input_Data_size -1 downto 0);
		M_in:  		 out  std_logic_vector(Input_Data_size -1 downto 0); 
	  	M_out: 		 in std_logic_vector(Input_Data_size -1 downto 0);
	  	Dout: 		 out std_logic_vector(Input_Data_size -1 downto 0)
		);
end component;

--Proposed architectures for the stages from 5 to 7

component Butterfly_SDF_memories is
	generic(	 
		N_Stages: 		integer:=3;			-- Butterfly Stage of the butterfly
		Stage: 			integer:=1;			-- Butterfly Stage of the butterfly
		Input_Data_size:	integer:=16			-- Size of the signal data to be processed
		);			
	port(
	  	rst:		 in  std_logic;
	  	clk:  		 in  std_logic;
		control: in  std_logic_vector(N_Stages - Stage downto 0);
	  	Din:  		 in  std_logic_vector(Input_Data_size -1 downto 0); 
	  	Dout: 		 out std_logic_vector(Input_Data_size -1 downto 0));
end component;

--Proposed architecture for the 3 latest stages
component Butterfly_SDF_registers
	generic(	 
		N_Stages: 		integer:=3;			-- Butterfly Stage of the butterfly
		Stage: 			integer:=1;			-- Butterfly Stage of the butterfly
		Input_Data_size:	integer:=16			-- Size of the signal data to be processed
		);			
	port(
	  	clk:  		 in  std_logic;
		control: 	 in  std_logic;
	  	Din:  		 in  std_logic_vector(Input_Data_size -1 downto 0); 
	  	Dout: 		 out std_logic_vector(Input_Data_size -1 downto 0));
end component;



	--Rotators

--W4 rotator, no internal pipeline
component Simp_Rotator_W4
	generic(	 
		Input_Data_size:	integer:=16			-- Size of the signal data to be processed
		);			
	port(
		control: 	 in  std_logic;
	  	X_in:  		 in  signed(Input_Data_size -1 downto 0);
		Y_in:  		 in  signed(Input_Data_size -1 downto 0); 
	  	X_out: 		 out signed(Input_Data_size -1 downto 0);
		Y_out: 		 out signed(Input_Data_size -1 downto 0));
end component;

--W8 rotator, have 1 internal line of pipeline
component Simp_W8_1Pip
	generic(	 
		Input_Data_size:	integer:=16			-- Size of the signal data to be processed
		);			
	port(
		clk: 	 	 in  std_logic;
		control: 	 in  std_logic_vector(1 downto 0);
	  	X_in:  		 in  signed(Input_Data_size -1 downto 0);
		Y_in:  		 in  signed(Input_Data_size -1 downto 0); 
	  	X_out: 		 out signed(Input_Data_size +9 downto 0);
		Y_out: 		 out signed(Input_Data_size +9 downto 0)
		);
end component;

--W32 rotator control
component Control_Rotator_W32
	generic(	 
		Input_Data_size:	integer:=16			-- Size of the signal data to be processed
		);			
	port(
	  	account: 		 in std_logic_vector(4 downto 0);
		control: 		 out std_logic_vector(4 downto 0)
		);
end component;

--W32 rotator, have 3 internal lines of CORDIC_min_area
component Rotator_W32 
	generic(	 
		Input_Data_size:	integer:=16			-- Size of the signal data to be processed
		);			
	port(
		clk: 	 	 in  std_logic;
		control: 	 in  std_logic_vector(4 downto 0);
	  	X_in:  		 in  signed(Input_Data_size -1  downto 0);
		Y_in:  		 in  signed(Input_Data_size -1  downto 0); 
	  	X_out: 		 out signed(Input_Data_size +16  downto 0);
		Y_out: 		 out signed(Input_Data_size +16  downto 0)
		);
end component;


component UD_CORDIC_csd_phi
	generic(	
		WL: integer:= 16;	 -- Data word length
		b:  integer:= 10;    -- Number of bits to represent phi
		n:  integer:= 5);    -- Number of stages of the CSD UD CORDIC. n must be equal or smaller than (b+6)/2
	port(
	    clk:   in  std_logic;
	    reset: in  std_logic;
	  	xin:   in  signed(WL -1 downto 0);  -- Real part of the input
	  	yin:   in  signed(WL -1 downto 0);  -- Imaginary part of the input
        angle: in  unsigned(b-1 downto 0);  -- Rotation angle (in phi, from 0 to (2^b)-1)
	  	xout:  out signed(WL -1 downto 0);  -- Real part of the output
	  	yout:  out signed(WL -1 downto 0)); -- Imaginary part of the output	 
end component;

--Signals of control, counter of 10 bits throw the multiple pipelines of the architecture
SIGNAL account 	: std_logic_vector(9 downto 0); --Main one
--Pipelines of the control
CONSTANT N_Pipelines : natural := 37;
SIGNAL account_Pipelines : v (0 to N_Pipelines);

--Stage constants
CONSTANT N_Stages : natural := 10;


--Stage 1 variables
SIGNAL Out_Butterfly1_X 	: std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL Out_Butterfly1_Y 	: std_logic_vector(Input_Data_size-1 downto 0); 

SIGNAL Out_Midpip1_1_X : std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL Out_Midpip1_1_Y : std_logic_vector(Input_Data_size-1 downto 0);

SIGNAL Restart_Counter1	: std_logic; 
SIGNAL M_out1_X_pip	: std_logic_vector(Input_Data_size-1 downto 0); 
SIGNAL M_out1_Y_pip	: std_logic_vector(Input_Data_size-1 downto 0); 
SIGNAL control1_wire	: std_logic_vector(8 downto 0); 
SIGNAL control1_pip	: std_logic_vector(8 downto 0); 

SIGNAL Rot_control1	 	: std_logic; 
SIGNAL Out_Rot1_X 		: signed(Input_Data_size-1 downto 0);
SIGNAL Out_Rot1_Y 		: signed(Input_Data_size-1 downto 0);


--Stage 2 variables
SIGNAL In_Butterfly2_X 	: std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL In_Butterfly2_Y 	: std_logic_vector(Input_Data_size-1 downto 0); 

SIGNAL Out_Butterfly2_X 	: std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL Out_Butterfly2_Y 	: std_logic_vector(Input_Data_size-1 downto 0); 

SIGNAL Out_Midpip2_1_X	: std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL Out_Midpip2_1_Y	: std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL Out_Midpip2_2_X	: std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL Out_Midpip2_2_Y	: std_logic_vector(Input_Data_size-1 downto 0); 

SIGNAL Restart_Counter2	: std_logic; 
SIGNAL M_out2_X_pip	: std_logic_vector(Input_Data_size-1 downto 0); 
SIGNAL M_out2_Y_pip	: std_logic_vector(Input_Data_size-1 downto 0); 
SIGNAL control2_wire	: std_logic_vector(7 downto 0); 
SIGNAL control2_pip	: std_logic_vector(7 downto 0); 

SIGNAL Rot_mult2_0_conv	 	: std_logic_vector(1 downto 0);
SIGNAL Rot_mult2_0	 	: unsigned(1 downto 0);
SIGNAL Rot_mult2_1	 	: unsigned(2 downto 0);
SIGNAL Rot_control2_0	 	: std_logic_vector(4 downto 0);
SIGNAL Rot_control2_1	 	: std_logic_vector(6 downto 0);
SIGNAL Out_Rot2_X 		: signed(Input_Data_size +16 downto 0);
SIGNAL Out_Rot2_Y 		: signed(Input_Data_size +16 downto 0);
SIGNAL Rot_control2_1_pipped	 	: std_logic_vector(4 downto 0);


--Stage 3 variables
SIGNAL In_Butterfly3_X 	: std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL In_Butterfly3_Y 	: std_logic_vector(Input_Data_size-1 downto 0); 

SIGNAL Out_Butterfly3_X 	: std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL Out_Butterfly3_Y 	: std_logic_vector(Input_Data_size-1 downto 0); 

SIGNAL Out_Midpip3_1_X : std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL Out_Midpip3_1_Y : std_logic_vector(Input_Data_size-1 downto 0);

SIGNAL Restart_Counter3	: std_logic; 
SIGNAL M_out3_X_pip	: std_logic_vector(Input_Data_size-1 downto 0); 
SIGNAL M_out3_Y_pip	: std_logic_vector(Input_Data_size-1 downto 0); 
SIGNAL control3_wire	: std_logic_vector(6 downto 0); 
SIGNAL control3_pip	: std_logic_vector(6 downto 0); 

SIGNAL Rot_control3	 	: std_logic; 
SIGNAL Out_Rot3_X 		: signed(Input_Data_size-1 downto 0);
SIGNAL Out_Rot3_Y 		: signed(Input_Data_size-1 downto 0);


--Stage 4 variables
SIGNAL In_Butterfly4_X 	: std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL In_Butterfly4_Y 	: std_logic_vector(Input_Data_size-1 downto 0); 

SIGNAL Out_Butterfly4_X 	: std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL Out_Butterfly4_Y 	: std_logic_vector(Input_Data_size-1 downto 0); 

SIGNAL Restart_Counter4	: std_logic; 

SIGNAL Out_Midpip4_1_X	: std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL Out_Midpip4_1_Y	: std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL Out_Midpip4_2_X	: std_logic_vector(Input_Data_size-1 downto 0); 
SIGNAL Out_Midpip4_2_Y	: std_logic_vector(Input_Data_size-1 downto 0); 


SIGNAL M_out4_X_pip	: std_logic_vector(Input_Data_size-1 downto 0); 
SIGNAL M_out4_Y_pip	: std_logic_vector(Input_Data_size-1 downto 0); 
SIGNAL control4_wire	: std_logic_vector(5 downto 0); 
SIGNAL control4_pip	: std_logic_vector(5 downto 0); 

SIGNAL Rot_control4	 	: std_logic_vector(1 downto 0);
SIGNAL Out_Rot4_X 		: signed(Input_Data_size +9 downto 0);
SIGNAL Out_Rot4_Y 		: signed(Input_Data_size +9 downto 0); 


--Stage 5 variables
SIGNAL In_Butterfly5_X 	: std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL In_Butterfly5_Y 	: std_logic_vector(Input_Data_size-1 downto 0); 

SIGNAL Out_Butterfly5_X 	: std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL Out_Butterfly5_Y 	: std_logic_vector(Input_Data_size-1 downto 0); 

SIGNAL Out_Midpip5_1_X	: std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL Out_Midpip5_1_Y	: std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL Out_Midpip5_2_X	: std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL Out_Midpip5_2_Y	: std_logic_vector(Input_Data_size-1 downto 0); 

SIGNAL Rot_control5_0	 	: std_logic_vector(10 downto 0);
SIGNAL Rot_control5_1	 	: std_logic_vector(4 downto 0);
SIGNAL Rot_control5	 	: unsigned(9 downto 0);
SIGNAL Rot_control5_piped	: std_logic_vector(9 downto 0);
SIGNAL Out_Rot5_X 		: signed(Input_Data_size-1 downto 0);
SIGNAL Out_Rot5_Y 		: signed(Input_Data_size-1 downto 0); 


--Stage 6 variables
SIGNAL In_Butterfly6_X 	: std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL In_Butterfly6_Y 	: std_logic_vector(Input_Data_size-1 downto 0); 

SIGNAL Out_Butterfly6_X 	: std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL Out_Butterfly6_Y 	: std_logic_vector(Input_Data_size-1 downto 0); 

SIGNAL Out_Midpip6_1_X	: std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL Out_Midpip6_1_Y	: std_logic_vector(Input_Data_size-1 downto 0);

SIGNAL Rot_control6	 	: std_logic; 
SIGNAL Out_Rot6_X 		: signed(Input_Data_size-1 downto 0);
SIGNAL Out_Rot6_Y 		: signed(Input_Data_size-1 downto 0);


--Stage 7 variables
SIGNAL In_Butterfly7_X 	: std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL In_Butterfly7_Y 	: std_logic_vector(Input_Data_size-1 downto 0); 

SIGNAL Out_Butterfly7_X 	: std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL Out_Butterfly7_Y 	: std_logic_vector(Input_Data_size-1 downto 0); 

SIGNAL Out_Midpip7_1_X	: std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL Out_Midpip7_1_Y	: std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL Out_Midpip7_2_X	: std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL Out_Midpip7_2_Y	: std_logic_vector(Input_Data_size-1 downto 0); 

SIGNAL Rot_mult7_0_conv	 	: std_logic_vector(2 downto 0);
SIGNAL Rot_mult7_0	 	: unsigned(2 downto 0);
SIGNAL Rot_mult7_1	 	: unsigned(2 downto 0);
SIGNAL Rot_control7_0	 	: std_logic_vector(4 downto 0);
SIGNAL Rot_control7_1	 	: unsigned(5 downto 0);
SIGNAL Rot_control7_2	 	: std_logic_vector(4 downto 0);
SIGNAL Rot_control7_2_pipped	 	: std_logic_vector(4 downto 0);
--SIGNAL Rot_control7_3	 	: std_logic_vector(4 downto 0);
SIGNAL Out_Rot7_X 		: signed(Input_Data_size +16 downto 0);
SIGNAL Out_Rot7_Y 		: signed(Input_Data_size +16 downto 0);


--Stage 8 variables
SIGNAL In_Butterfly8_X 	: std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL In_Butterfly8_Y 	: std_logic_vector(Input_Data_size-1 downto 0); 

SIGNAL Out_Butterfly8_X 	: std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL Out_Butterfly8_Y 	: std_logic_vector(Input_Data_size-1 downto 0); 

SIGNAL Out_Midpip8_1_X	: std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL Out_Midpip8_1_Y	: std_logic_vector(Input_Data_size-1 downto 0);

SIGNAL Rot_control8	 	: std_logic; 
SIGNAL Out_Rot8_X 		: signed(Input_Data_size-1 downto 0);
SIGNAL Out_Rot8_Y 		: signed(Input_Data_size-1 downto 0);


--Stage 9 variables
SIGNAL In_Butterfly9_X 	: std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL In_Butterfly9_Y 	: std_logic_vector(Input_Data_size-1 downto 0); 

SIGNAL Out_Butterfly9_X 	: std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL Out_Butterfly9_Y 	: std_logic_vector(Input_Data_size-1 downto 0); 

SIGNAL Out_Midpip9_1_X	: std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL Out_Midpip9_1_Y	: std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL Out_Midpip9_2_X	: std_logic_vector(Input_Data_size-1 downto 0); 
SIGNAL Out_Midpip9_2_Y	: std_logic_vector(Input_Data_size-1 downto 0); 

SIGNAL Rot_control9	 	: std_logic_vector(1 downto 0);
SIGNAL Out_Rot9_X 		: signed(Input_Data_size +9 downto 0);
SIGNAL Out_Rot9_Y 		: signed(Input_Data_size +9 downto 0); 


--Stage 10 variables
SIGNAL In_Butterfly10_X 	: std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL In_Butterfly10_Y 	: std_logic_vector(Input_Data_size-1 downto 0); 

SIGNAL Out_Butterfly10_X 	: std_logic_vector(Input_Data_size-1 downto 0);
SIGNAL Out_Butterfly10_Y 	: std_logic_vector(Input_Data_size-1 downto 0); 

begin

--Control of the system (counter of )

CONTROL : COUNTER	
	generic map (WIDTH => 10)
  	port map (account => account, start => '0', rst => rst, clk => clk);

CONTROL_PIPELINES : MultyPipeline
	generic map( N => N_Pipelines, WL => 10)
      port map (clk => clk, Input => account, Output => account_Pipelines);


--Control RAM_memory_1
RAM1_CONTROL : COUNTER	
	generic map (WIDTH => 9)
  	port map (account => control1_wire, start => Restart_Counter1, rst => rst, clk => clk);
	
	Restart_Counter1 <= '1' when (control1_wire = "111111110") else '0';
	
--Pipeline for control
RAM_Control_pipeline1 : Pipeline generic map( WL => 9) port map (clk => clk, Input => control1_wire, Output => control1_pip);

RAM_Control_pipeline1_2 : Pipeline generic map( WL => 9) port map (clk => clk, Input => control1_pip, Output => control1_2);

control1 <= control1_pip;

--Pipelines for the RAM input and output
RAM1_Control_pipeline_X_out : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => M_out1_X, Output => M_out1_X_pip);
RAM1_Control_pipeline_Y_out : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => M_out1_Y, Output => M_out1_Y_pip);

--Stage número 1
Stage1_X_Butterfly : No_Mem_SDF
	generic map( N_Stages => N_Stages, Stage => 1, Input_Data_size => Input_Data_size)		  -- Word Length	
      port map (clk => clk, control => account(9), M_in => M_in1_X, M_out => M_out1_X_pip, Din => X_in,	Dout => Out_Butterfly1_X);
	  
Stage1_Y_Butterfly : No_Mem_SDF
	generic map( N_Stages => N_Stages, Stage => 1, Input_Data_size => Input_Data_size)		  -- Word Length	
      port map (clk => clk, control => account(9), M_in => M_in1_Y, M_out => M_out1_Y_pip, Din => Y_in,	Dout => Out_Butterfly1_Y);

--Pipeline pre-rotator1
Pipeline_stageX_1_1 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => Out_Butterfly1_X, Output => Out_Midpip1_1_X);
Pipeline_stageY_1_1 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => Out_Butterfly1_Y, Output => Out_Midpip1_1_Y);

--Rotator 1 control:
Rot_control1 <= not(account_Pipelines(0)(9)) and account_Pipelines(0)(8);

--Rotator 1
Rotator_1 : Simp_Rotator_W4
	generic map( Input_Data_size => Input_Data_size)		  -- Word Length	
      port map (control => Rot_control1, X_in => signed(Out_Midpip1_1_X), Y_in => signed(Out_Midpip1_1_Y), X_out => Out_Rot1_X, Y_out => Out_Rot1_Y );

--Pipeline stage1
Pipeline_stageX_1 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => std_logic_vector(Out_Rot1_X), Output => In_Butterfly2_X);
Pipeline_stageY_1 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => std_logic_vector(Out_Rot1_Y), Output => In_Butterfly2_Y);
--End stage 1



--Control RAM_memory_2
RAM2_CONTROL : COUNTER	
	generic map (WIDTH => 8)
  	port map (account => control2_wire, start => Restart_Counter2, rst => rst, clk => clk);
	
	Restart_Counter2 <= '1' when (control2_wire = "11111110") else '0';
	
--Pipeline for control
RAM_Control_pipeline2 : Pipeline generic map( WL => 8) port map (clk => clk, Input => control2_wire, Output => control2_pip);

RAM_Control_pipeline2_2 : Pipeline generic map( WL => 8) port map (clk => clk, Input => control2_pip, Output => control2_2);

control2 <= control2_pip;

--Pipelines for the RAM input and output
RAM2_Control_pipeline_X_out : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => M_out2_X, Output => M_out2_X_pip);
RAM2_Control_pipeline_Y_out : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => M_out2_Y, Output => M_out2_Y_pip);

--Stage número 2
Stage2_X_Butterfly : No_Mem_SDF
	generic map( N_Stages => N_Stages, Stage => 2, Input_Data_size => Input_Data_size)		  -- Word Length	
      port map (clk => clk, control => account_Pipelines(1)(8), M_in => M_in2_X, M_out => M_out2_X_pip, Din => In_Butterfly2_X,	Dout => Out_Butterfly2_X);
	  
Stage2_Y_Butterfly : No_Mem_SDF
	generic map( N_Stages => N_Stages, Stage => 2, Input_Data_size => Input_Data_size)		  -- Word Length	
      port map (clk => clk, control => account_Pipelines(1)(8), M_in => M_in2_Y, M_out => M_out2_Y_pip, Din => In_Butterfly2_Y,	Dout => Out_Butterfly2_Y);

--Pipeline pre-rotator2
Pipeline_stageX_2_1 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => Out_Butterfly2_X, Output => Out_Midpip2_1_X);
Pipeline_stageY_2_1 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => Out_Butterfly2_Y, Output => Out_Midpip2_1_Y);


--Rotator 2 control:
--Rot_control2_0 <=  not(account_Pipelines(2)(8))  & (account_Pipelines(2)(8) xor account_Pipelines(2)(9) ) & account_Pipelines(2)(7 downto 5);

--Rotator2_Control_Rotator_W32 : Control_Rotator_W32	
	--generic map (Input_Data_size => Input_Data_size)
  	--port map (account => Rot_control2_0, control => Rot_control2_1);
	
	--Rot_control2_1 <= std_logic_vector(Rot_control7_2(4 downto 0));
Rot_mult2_0_conv <= not(account_Pipelines(1)(8))  & (account_Pipelines(1)(8) xor account_Pipelines(1)(9) );
Rot_mult2_0 <= unsigned(Rot_mult2_0_conv);
Rot_mult2_1 <= unsigned(account_Pipelines(1)(7 downto 5));
Rot_control2_1 <= std_logic_vector(resize(Rot_mult2_0,3) * resize(Rot_mult2_1,4));

Pipeline_rotator_control_2 : Pipeline generic map( WL => 5) port map (clk => clk, Input => std_logic_vector(Rot_control2_1(4 downto 0)), Output => Rot_control2_1_pipped);

--Rotator 2
Rotator_2 : Rotator_W32
	generic map( Input_Data_size => Input_Data_size)		  -- Word Length	
      port map (clk => clk, control => Rot_control2_1_pipped, X_in => signed(Out_Midpip2_1_X), Y_in => signed(Out_Midpip2_1_Y),  X_out => Out_Rot2_X, Y_out => Out_Rot2_Y );

--Pipeline stage2
Pipeline_stageX_2 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => std_logic_vector(Out_Rot2_X(Input_Data_size +16 downto 17)), Output => In_Butterfly3_X);
Pipeline_stageY_2 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => std_logic_vector(Out_Rot2_Y(Input_Data_size +16 downto 17)), Output => In_Butterfly3_Y);
--End stage 2


--Control RAM_memory_3
RAM3_CONTROL : COUNTER	
	generic map (WIDTH => 7)
  	port map (account => control3_wire, start => Restart_Counter3, rst => rst, clk => clk);
	
	Restart_Counter3 <= '1' when (control3_wire = "1111110") else '0';
	
--Pipeline for control
RAM_Control_pipeline3 : Pipeline generic map( WL => 7) port map (clk => clk, Input => control3_wire, Output => control3_pip);

RAM_Control_pipeline3_2 : Pipeline generic map( WL => 7) port map (clk => clk, Input => control3_pip, Output => control3_2);

control3 <= control3_pip;

--Pipelines for the RAM input and output
RAM3_Control_pipeline_X_out : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => M_out3_X, Output => M_out3_X_pip);
RAM3_Control_pipeline_Y_out : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => M_out3_Y, Output => M_out3_Y_pip);

--Stage número 3
Stage3_X_Butterfly : No_Mem_SDF
	generic map( N_Stages => N_Stages, Stage => 3, Input_Data_size => Input_Data_size)		  -- Word Length	
      port map (clk => clk, control => account_Pipelines(6)(7), M_in => M_in3_X, M_out => M_out3_X_pip, Din => In_Butterfly3_X,	Dout => Out_Butterfly3_X);
	  
Stage3_Y_Butterfly : No_Mem_SDF
	generic map( N_Stages => N_Stages, Stage => 3, Input_Data_size => Input_Data_size)		  -- Word Length	
      port map (clk => clk, control => account_Pipelines(6)(7), M_in => M_in3_Y, M_out => M_out3_Y_pip, Din => In_Butterfly3_Y,	Dout => Out_Butterfly3_Y);

--Pipeline pre-rotator3
Pipeline_stageX_3_1 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => Out_Butterfly3_X, Output => Out_Midpip3_1_X);
Pipeline_stageY_3_1 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => Out_Butterfly3_Y, Output => Out_Midpip3_1_Y);

--Rotator 3 control:

Rot_control3 <= not(account_Pipelines(7)(7)) and account_Pipelines(7)(6);

--Rotator 3
Rotator_3 : Simp_Rotator_W4
	generic map( Input_Data_size => Input_Data_size)		  -- Word Length	
      port map (control => Rot_control3,  X_in => signed(Out_Midpip3_1_X), Y_in => signed(Out_Midpip3_1_Y) , X_out => Out_Rot3_X, Y_out => Out_Rot3_Y );

--Pipeline stage3
Pipeline_stageX_3 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => std_logic_vector(Out_Rot3_X), Output => In_Butterfly4_X);
Pipeline_stageY_3 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => std_logic_vector(Out_Rot3_Y), Output => In_Butterfly4_Y);
--End stage 3



--Control RAM_memory_4
RAM4_CONTROL : COUNTER	
	generic map (WIDTH => 6)
  	port map (account => control4_wire, start => Restart_Counter4, rst => rst, clk => clk);
	
	Restart_Counter4 <= '1' when (control4_wire = "111110") else '0';
	
--Pipeline for control
RAM_Control_pipeline4 : Pipeline generic map( WL => 6) port map (clk => clk, Input => control4_wire, Output => control4_pip);

RAM_Control_pipeline4_2 : Pipeline generic map( WL => 6) port map (clk => clk, Input => control4_pip, Output => control4_2);

control4 <= control4_pip;

--Pipelines for the RAM input and output
RAM4_Control_pipeline_X_out : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => M_out4_X, Output => M_out4_X_pip);
RAM4_Control_pipeline_Y_out : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => M_out4_Y, Output => M_out4_Y_pip);

--Stage número 4
Stage4_X_Butterfly : No_Mem_SDF
	generic map( N_Stages => N_Stages, Stage => 4, Input_Data_size => Input_Data_size)		  -- Word Length	
      port map (clk => clk, control => account_Pipelines(8)(6), M_in => M_in4_X, M_out => M_out4_X_pip, Din => In_Butterfly4_X,	Dout => Out_Butterfly4_X);
	  
Stage4_Y_Butterfly : No_Mem_SDF
	generic map( N_Stages => N_Stages, Stage => 4, Input_Data_size => Input_Data_size)		  -- Word Length	
      port map (clk => clk, control => account_Pipelines(8)(6), M_in => M_in4_Y, M_out => M_out4_Y_pip, Din => In_Butterfly4_Y,	Dout => Out_Butterfly4_Y);



--Pipeline pre-rotator4
Pipeline_stageX_4_1 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => Out_Butterfly4_X, Output => Out_Midpip4_1_X);
Pipeline_stageY_4_1 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => Out_Butterfly4_Y, Output => Out_Midpip4_1_Y);


--Rotator 4 control:
	
Rot_control4 <= (account_Pipelines(9)(5) and not(account_Pipelines(9)(6))) & (account_Pipelines(9)(5) and (account_Pipelines(9)(6) xor account_Pipelines(9)(7)));

--Rotator 4
Rotator_4 : Simp_W8_1Pip
	generic map( Input_Data_size => Input_Data_size)		  -- Word Length	
      port map (clk => clk, control => Rot_control4, X_in => signed(Out_Midpip4_1_X), Y_in => signed(Out_Midpip4_1_Y), X_out => Out_Rot4_X, Y_out => Out_Rot4_Y );

--Pipeline stage4
Pipeline_stageX_4 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => std_logic_vector(Out_Rot4_X(Input_Data_size +9 downto 10)), Output => In_Butterfly5_X);
Pipeline_stageY_4 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => std_logic_vector(Out_Rot4_Y(Input_Data_size +9 downto 10)), Output => In_Butterfly5_Y);
--End stage 4





--Stage número 5
Stage5_X_Butterfly : Butterfly_SDF_registers
	generic map( N_Stages => N_Stages, Stage => 5, Input_Data_size => Input_Data_size)		  -- Word Length	
      port map (clk => clk, control => account_Pipelines(11)(5), Din => In_Butterfly5_X,	Dout => Out_Butterfly5_X);
	  
Stage5_Y_Butterfly : Butterfly_SDF_registers
	generic map( N_Stages => N_Stages, Stage => 5, Input_Data_size => Input_Data_size)		  -- Word Length	
      port map (clk => clk, control => account_Pipelines(11)(5), Din => In_Butterfly5_Y,	Dout => Out_Butterfly5_Y);

--Pipeline pre-rotator5
Pipeline_stageX_5_1 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => Out_Butterfly5_X, Output => Out_Midpip5_1_X);
Pipeline_stageY_5_1 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => Out_Butterfly5_Y, Output => Out_Midpip5_1_Y);


--Rotator 5 control:
Rot_control5_0 <= std_logic_vector(resize(unsigned(account_Pipelines(1)), 11) + 22) ;
Rot_control5_1 <= (Rot_control5_0(5) & Rot_control5_0(6) & Rot_control5_0(7) & Rot_control5_0(8) & Rot_control5_0(9));
Rot_control5 <= (unsigned(Rot_control5_1) *  unsigned(Rot_control5_0(4 downto 0)));

--Pippeline to the Rotator 5 control
Pipeline_stage_control_5 : Pipeline generic map( WL => 10) port map (clk => clk, Input => std_logic_vector(Rot_control5), Output => Rot_control5_piped);

--Rotator 5
Rotator_5 : UD_CORDIC_csd_phi
	generic map( WL => Input_Data_size, b  => 10,  n => 5)
      port map (clk => clk, reset => rst, angle => unsigned(Rot_control5_piped), xin => signed(Out_Midpip5_1_X) , yin =>  signed(Out_Midpip5_1_Y) , xout =>  Out_Rot5_X, yout => Out_Rot5_Y );

--Pipeline stage5
Pipeline_stageX_5 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => std_logic_vector(Out_Rot5_X(Input_Data_size -1 downto 0)), Output => In_Butterfly6_X);
Pipeline_stageY_5 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => std_logic_vector(Out_Rot5_Y(Input_Data_size -1 downto 0)), Output => In_Butterfly6_Y);
--End stage 5




--Stage número 6
Stage6_X_Butterfly : Butterfly_SDF_registers
	generic map( N_Stages => N_Stages, Stage => 6, Input_Data_size => Input_Data_size)		  -- Word Length	
      port map (clk => clk, control => account_Pipelines(24)(4), Din => In_Butterfly6_X,	Dout => Out_Butterfly6_X);
	  
Stage6_Y_Butterfly : Butterfly_SDF_registers
	generic map( N_Stages => N_Stages, Stage => 6, Input_Data_size => Input_Data_size)		  -- Word Length	
      port map ( clk => clk, control => account_Pipelines(24)(4), Din => In_Butterfly6_Y,	Dout => Out_Butterfly6_Y);

--Pipeline pre-rotator6
Pipeline_stageX_6_1 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => Out_Butterfly6_X, Output => Out_Midpip6_1_X);
Pipeline_stageY_6_1 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => Out_Butterfly6_Y, Output => Out_Midpip6_1_Y);

--Rotator 6 control:

Rot_control6 <= not(account_Pipelines(25)(4)) and account_Pipelines(25)(3);

--Rotator 6
Rotator_6 : Simp_Rotator_W4
	generic map( Input_Data_size => Input_Data_size)		  -- Word Length	
      port map (control => Rot_control6, X_in => signed(Out_Midpip6_1_X), Y_in => signed(Out_Midpip6_1_Y), X_out => Out_Rot6_X, Y_out => Out_Rot6_Y );

--Pipeline stage6
Pipeline_stageX_6 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => std_logic_vector(Out_Rot6_X), Output => In_Butterfly7_X);
Pipeline_stageY_6 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => std_logic_vector(Out_Rot6_Y), Output => In_Butterfly7_Y);
--End stage 6


--Stage número 7
Stage7_X_Butterfly : Butterfly_SDF_registers
	generic map( N_Stages => N_Stages, Stage => 7, Input_Data_size => Input_Data_size)		  -- Word Length	
      port map (clk => clk, control => account_Pipelines(26)(3), Din => In_Butterfly7_X,	Dout => Out_Butterfly7_X);
	  
Stage7_Y_Butterfly : Butterfly_SDF_registers
	generic map( N_Stages => N_Stages, Stage => 7, Input_Data_size => Input_Data_size)		  -- Word Length	
      port map (clk => clk, control => account_Pipelines(26)(3), Din => In_Butterfly7_Y,	Dout => Out_Butterfly7_Y);

--Pipeline pre-rotator7
Pipeline_stageX_7_1 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => Out_Butterfly7_X, Output => Out_Midpip7_1_X);
Pipeline_stageY_7_1 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => Out_Butterfly7_Y, Output => Out_Midpip7_1_Y);


--Rotator 7 control:
--Rot_control7_0 <=  account_Pipelines(19)(3)  & account_Pipelines(19)(4) & account_Pipelines(19)(2 downto 0);

--Rotator7_Control_Rotator_W32 : Control_Rotator_W32	
	--generic map (Input_Data_size => Input_Data_size)
  	--port map (account => Rot_control7_0, control => Rot_control7_1);
	
	--Rot_control7_2 <= resize(unsigned(Rot_control7_1), 6) -3;
	--Rot_control7_3 <= std_logic_vector(Rot_control7_2(4 downto 0));
Rot_mult7_0_conv <= '0' & account_Pipelines(18)(3)  & account_Pipelines(18)(4);
Rot_mult7_0 <= unsigned(Rot_mult7_0_conv);
Rot_mult7_1 <= unsigned(account_Pipelines(18)(2 downto 0));
Rot_control7_1 <= (Rot_mult7_0 * Rot_mult7_1) + 3;
Rot_control7_2 <= std_logic_vector(Rot_control7_1(4 downto 0));

Pipeline_rotator_control_7 : Pipeline generic map( WL => 5) port map (clk => clk, Input => std_logic_vector(Rot_control7_2), Output => Rot_control7_2_pipped);

--Rotator 7
Rotator_7 : Rotator_W32
	generic map( Input_Data_size => Input_Data_size)		  -- Word Length	
      port map (clk => clk, control => Rot_control7_2_pipped, X_in => signed(Out_Midpip7_1_X), Y_in => signed(Out_Midpip7_1_Y),  X_out => Out_Rot7_X, Y_out => Out_Rot7_Y );

--Pipeline stage7
Pipeline_stageX_7 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => std_logic_vector(Out_Rot7_X(Input_Data_size +16 downto 17)), Output => In_Butterfly8_X);
Pipeline_stageY_7 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => std_logic_vector(Out_Rot7_Y(Input_Data_size +16 downto 17)), Output => In_Butterfly8_Y);
--End stage 7

--Stage número 8
Stage8_X_Butterfly : Butterfly_SDF_registers
	generic map( N_Stages => N_Stages, Stage => 8, Input_Data_size => Input_Data_size)		  -- Word Length	
      port map (clk => clk, control => account_Pipelines(31)(2), Din => In_Butterfly8_X,	Dout => Out_Butterfly8_X);
	  
Stage8_Y_Butterfly : Butterfly_SDF_registers
	generic map( N_Stages => N_Stages, Stage => 8, Input_Data_size => Input_Data_size)		  -- Word Length	
      port map (clk => clk, control => account_Pipelines(31)(2), Din => In_Butterfly8_Y,	Dout => Out_Butterfly8_Y);

--Pipeline pre-rotator8
Pipeline_stageX_8_1 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => Out_Butterfly8_X, Output => Out_Midpip8_1_X);
Pipeline_stageY_8_1 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => Out_Butterfly8_Y, Output => Out_Midpip8_1_Y);

--Rotator 8 control:

Rot_control8 <= not(account_Pipelines(32)(2)) and account_Pipelines(32)(1);

--Rotator 8
Rotator_8 : Simp_Rotator_W4
	generic map( Input_Data_size => Input_Data_size)		  -- Word Length	
      port map (control => Rot_control8,  X_in => signed(Out_Midpip8_1_X), Y_in => signed(Out_Midpip8_1_Y) , X_out => Out_Rot8_X, Y_out => Out_Rot8_Y );

--Pipeline stage8
Pipeline_stageX_8 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => std_logic_vector(Out_Rot8_X), Output => In_Butterfly9_X);
Pipeline_stageY_8 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => std_logic_vector(Out_Rot8_Y), Output => In_Butterfly9_Y);
--End stage 8



--Stage número 9
Stage9_X_Butterfly : Butterfly_SDF_registers
	generic map( N_Stages => N_Stages, Stage => 9, Input_Data_size => Input_Data_size)		  -- Word Length	
      port map (clk => clk, control => account_Pipelines(33)(1), Din => In_Butterfly9_X,	Dout => Out_Butterfly9_X);
	  
Stage9_Y_Butterfly : Butterfly_SDF_registers
	generic map( N_Stages => N_Stages, Stage => 9, Input_Data_size => Input_Data_size)		  -- Word Length	
      port map (clk => clk, control => account_Pipelines(33)(1), Din => In_Butterfly9_Y,	Dout => Out_Butterfly9_Y);

--Pipeline pre-rotator9
Pipeline_stageX_9_1 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => Out_Butterfly9_X, Output => Out_Midpip9_1_X);
Pipeline_stageY_9_1 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => Out_Butterfly9_Y, Output => Out_Midpip9_1_Y);


--Rotator 9 control:

Rot_control9 <= (account_Pipelines(34)(0) and not(account_Pipelines(34)(1))) & (account_Pipelines(34)(0) and (account_Pipelines(34)(2) xor account_Pipelines(34)(1)));

--Rotator 9
Rotator_9 : Simp_W8_1Pip
	generic map( Input_Data_size => Input_Data_size)		  -- Word Length	
      port map (clk => clk, control => Rot_control9, X_in => signed(Out_Midpip9_1_X), Y_in => signed(Out_Midpip9_1_Y), X_out => Out_Rot9_X, Y_out => Out_Rot9_Y );

--Pipeline stage9
Pipeline_stageX_9 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => std_logic_vector(Out_Rot9_X(Input_Data_size +9 downto 10)), Output => In_Butterfly10_X);
Pipeline_stageY_9 : Pipeline generic map( WL => Input_Data_size) port map (clk => clk, Input => std_logic_vector(Out_Rot9_Y(Input_Data_size +9 downto 10)), Output => In_Butterfly10_Y);
--End stage 9

--Stage número 10
Stage10_X_Butterfly : Butterfly_SDF_registers
	generic map( N_Stages => N_Stages, Stage => 10, Input_Data_size => Input_Data_size)		  -- Word Length	
      port map (clk => clk, control => std_logic(account_Pipelines(36)(0)), Din => In_Butterfly10_X,	Dout => Out_Butterfly10_X);
	  
Stage10_Y_Butterfly : Butterfly_SDF_registers
	generic map( N_Stages => N_Stages, Stage => 10, Input_Data_size => Input_Data_size)		  -- Word Length	
      port map (clk => clk, control => std_logic(account_Pipelines(36)(0)), Din => In_Butterfly10_Y,	Dout => Out_Butterfly10_Y);
--End stage 10

X_out <= Out_Butterfly10_X;
Y_out <= Out_Butterfly10_Y;



end FFT_RAM_Memory_pipelined_arch;

