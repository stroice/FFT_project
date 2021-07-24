library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.Components.ALL;

entity NoPip_Rotator_W4 is
	generic(	 
		Input_Data_size:	integer:=16			-- Size of the signal data to be processed
		);			
	port(
		control: 	 in  std_logic_vector(1 downto 0);
	  	X_in:  		 in  signed(Input_Data_size -1 downto 0);
		Y_in:  		 in  signed(Input_Data_size -1 downto 0); 
	  	X_out: 		 out signed(Input_Data_size -1 downto 0);
		Y_out: 		 out signed(Input_Data_size -1 downto 0));
end NoPip_Rotator_W4;

architecture NoPip_Rotator_W4_arch of NoPip_Rotator_W4 is

SIGNAL X_out_aux1: 	signed(Input_Data_size -1 downto 0);
SIGNAL Y_out_aux1: 	signed(Input_Data_size -1 downto 0);


begin

	
	with control(0) select
	    Y_out_aux1<= X_in  when '1',
							  Y_in when others;
	
	with control(0) xor control(1) select
	    Y_out <= not(Y_out_aux1) + 1  when '1',
			 Y_out_aux1 when others;
	
	with control(0) select
	    X_out_aux1<= Y_in  when '1',
							  X_in when others;

	with control(1) select
	    X_out<= not(X_out_aux1) + 1  when '1',
			 X_out_aux1 when others;

end NoPip_Rotator_W4_arch;