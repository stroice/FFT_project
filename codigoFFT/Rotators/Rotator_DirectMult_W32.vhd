library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Rotator_DirectMult_W32 is
	generic(	 
		constant Input_Data_size:	integer:=16			-- Size of the signal data to be processed
		);			
	port(
		Term1_bits: 	 in  std_logic_vector(1 downto 0);   -- b8, b9 order of the control bets
		Term2_bits: 	 in  std_logic_vector(2 downto 0);   -- b5, b6, b7 order of the control bets
	  	X_in:  		 in  signed(Input_Data_size -1 downto 0);
		Y_in:  		 in  signed(Input_Data_size -1 downto 0); 
	  	X_out: 		 out signed(Input_Data_size +10 downto 0);
		Y_out: 		 out signed(Input_Data_size +10 downto 0)
		);
end Rotator_DirectMult_W32;

architecture Rotator_DirectMult_W32_arch of Rotator_DirectMult_W32 is

component ROM_32
generic (
	  constant WL: 	   integer:= 11;			  -- Word Length	
	  constant BL_exp:  integer:= 5);		   -- Power of 2 size of memory
	port(
	  control:  in  std_logic_vector(BL_exp - 1 downto 0);
	  C:    out std_logic_vector(WL - 1 downto 0);
	  S:    out std_logic_vector(WL - 1 downto 0));
end component;

SIGNAL ROM_control: 	std_logic_vector(4 downto 0);

SIGNAL C: 	signed(10 downto 0);
SIGNAL S: 	signed(10 downto 0);

begin 

ROM_control <= (Term1_bits & Term2_bits);

ROM:ROM_32 port map(control => ROM_control, signed(C)=> C, signed(S)=> S);

X_out<= X_in*C - Y_in*S;

Y_out<= Y_in*C + X_in*S;


end Rotator_DirectMult_W32_arch;