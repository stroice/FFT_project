library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity No_Mem_SDF is
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
end No_Mem_SDF;

architecture No_Mem_SDF_arch of No_Mem_SDF is

component DelayReg 

	generic(	
		WL: integer:=8;			-- Word Length
		BL: integer:= 1024);		-- Buffer Length
	port(
	  	clk:  in  std_logic;
	  	Din:  in  std_logic_vector(WL -1 downto 0); 
	  	Dout: out std_logic_vector(WL -1 downto 0));
end component;

SIGNAL M_in_aux: 	std_logic_vector(Input_Data_size downto 0);
SIGNAL out_sig:	signed(Input_Data_size downto 0);

begin

	with control select
	    M_in_aux <=  	std_logic_vector(resize(signed(M_out), Input_Data_size+1) - resize(signed(Din), Input_Data_size+1)) when '1',
								std_logic_vector(Din & "0") when others;

		M_in <= M_in_aux(Input_Data_size downto 1);


	with control select
	out_sig <=  	signed(resize(signed(M_out), Input_Data_size+1) + resize(signed(Din), Input_Data_size+1)) when '1',
						signed(M_out & "0") when others;
	
	
	Dout <= std_logic_vector(out_sig(Input_Data_size downto 1)) ;


end No_Mem_SDF_arch;