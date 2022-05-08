library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.Components.ALL;

entity Simp_Rotator_W4 is
	generic(	 
		Input_Data_size:	integer:=16			-- Size of the signal data to be processed
		);			
	port(
		control: 	 in  std_logic;
	  	X_in:  		 in  signed(Input_Data_size -1 downto 0);
		Y_in:  		 in  signed(Input_Data_size -1 downto 0); 
	  	X_out: 		 out signed(Input_Data_size -1 downto 0);
		Y_out: 		 out signed(Input_Data_size -1 downto 0));
end Simp_Rotator_W4;

architecture Simp_Rotator_W4_arch of Simp_Rotator_W4 is


begin
	
	with control select
	    X_out <= Y_in  when '1',
					  X_in when others;

	with control select
	    Y_out <= not(X_in) + 1  when '1',
								Y_in when others;

end Simp_Rotator_W4_arch;
