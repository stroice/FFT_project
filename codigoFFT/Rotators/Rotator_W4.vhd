library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Rotator_W4 is
	generic(	 
		Input_Data_size:	integer:=16			-- Size of the signal data to be processed
		);			
	port(
		clk: 	 	 in  std_logic;
		counter: 	 in  std_logic_vector(1 downto 0);
	  	X_in:  		 in  signed(Input_Data_size -1 downto 0);
		Y_in:  		 in  signed(Input_Data_size -1 downto 0); 
	  	X_out: 		 out signed(Input_Data_size -1 downto 0);
		Y_out: 		 out signed(Input_Data_size -1 downto 0));
end Rotator_W4;

architecture Rotator_W4_norm_arch of Rotator_W4 is

SIGNAL aux_0: 	signed(Input_Data_size -1 downto 0);
SIGNAL aux_1: 	signed(Input_Data_size -1 downto 0);
SIGNAL aux_not0:signed(Input_Data_size -1 downto 0);


SIGNAL aux_X1: 	signed(Input_Data_size -1 downto 0);
SIGNAL aux_X2: 	signed(Input_Data_size -1 downto 0);

SIGNAL aux_Y1: 	signed(Input_Data_size -1 downto 0);
SIGNAL aux_Y2: 	signed(Input_Data_size -1 downto 0);

SIGNAL X_out_aux1: signed(Input_Data_size -1 downto 0);
SIGNAL Y_out_aux1: signed(Input_Data_size -1 downto 0);

SIGNAL X_out_aux2: signed(Input_Data_size -1 downto 0);
SIGNAL Y_out_aux2: signed(Input_Data_size -1 downto 0);

begin

	pipeline: process(clk)
         begin 
            if rising_edge(clk) then
		X_out <= X_out_aux2; 
		Y_out <= Y_out_aux2;        
            end if;
	
      	end process;   

	aux_0 <= (others => counter(0));
	aux_not0 <= not(aux_0);

	aux_X1 <= X_in and aux_not0;
	aux_X2 <= Y_in and aux_0;
	
	X_out_aux1 <= (aux_X1 or aux_X2);
	
	with counter(0) xor counter(1) select
	    X_out_aux2 <= not(X_out_aux1) + 1  when '1',
			 X_out_aux1 when others;
	
	aux_Y1 <= X_in and aux_0;
	aux_Y2 <= Y_in and aux_not0;

	Y_out_aux1 <= (aux_Y1 or aux_Y2);

	with counter(1) select
	    Y_out_aux2 <= not(Y_out_aux1) + 1  when '1',
			 Y_out_aux1 when others;

end Rotator_W4_norm_arch;