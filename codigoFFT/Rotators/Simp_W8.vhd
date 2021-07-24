

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Simp_W8 is
	generic(	 
		Input_Data_size:	integer:=16			-- Size of the signal data to be processed
		);			
	port(
		control: 	 in  std_logic_vector(1 downto 0);
	  	X_in:  		 in  signed(Input_Data_size -1 downto 0);
		Y_in:  		 in  signed(Input_Data_size -1 downto 0); 
	  	X_out: 		 out signed(Input_Data_size +9 downto 0);
		Y_out: 		 out signed(Input_Data_size +9 downto 0)
		);
end Simp_W8 ;

architecture Simp_W8_arch of Simp_W8 is

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

SIGNAL X_90: 	signed(Input_Data_size -1 downto 0);
SIGNAL Y_90: 	signed(Input_Data_size -1 downto 0);

SIGNAL aux_X1: 	signed(Input_Data_size +3 downto 0);
SIGNAL aux_Y1: 	signed(Input_Data_size +3 downto 0);

SIGNAL X_out_aux: 	signed(Input_Data_size +4 downto 0);
SIGNAL Y_out_aux: 	signed(Input_Data_size +4 downto 0);

-------------------------------------------------------------------------

SIGNAL aux_X2: 	signed(Input_Data_size +9 downto 0);
SIGNAL aux_Y2: 	signed(Input_Data_size +9 downto 0);

SIGNAL X_add_aux: signed(Input_Data_size +9 downto 0);
SIGNAL Y_add_aux: signed(Input_Data_size +9 downto 0);

begin

--W4

		W4:Simp_Rotator_W4 generic map(Input_Data_size =>(Input_Data_size))	
		port map(control => control(1), X_in => X_in, Y_in => Y_in, X_out => X_90, Y_out => Y_90);


 	with control(0) select
	    aux_X1 <= 	(resize(X_90 & "0",Input_Data_size +4)) when '1',
			(X_90 & "0000") when others;

	with control(0) select
	    aux_Y1 <= 	(resize(Y_90 & "0",Input_Data_size +4)) when '1',
			(Y_90 & "0000") when others;

	X_out_aux <= (resize(aux_X1,Input_Data_size +5) + resize(X_90,Input_Data_size +5));
	Y_out_aux <= (resize(aux_Y1,Input_Data_size +5) + resize(Y_90,Input_Data_size +5));

	    --Second part of the pipeline

	with control(0) select
	    aux_X2 <= 	(X_out_aux(Input_Data_size +2 downto 0) & "0000000") when '1',
			(X_out_aux & "00000") when others;

	with control(0) select
	    aux_Y2 <= 	(Y_out_aux(Input_Data_size +2 downto 0) & "0000000") when '1',
			(Y_out_aux & "00000") when others;

	with control(0) select
	    X_add_aux <= aux_Y2 when '1',
			 resize(X_90, Input_Data_size +10) when others;

	with control(0) select
	    Y_add_aux <= aux_X2  when '1',
			 resize(Y_90, Input_Data_size +10) when others;

	Y_out <= aux_Y2 - Y_add_aux;

	with control(0) select
	    X_out <=  (aux_X2 + X_add_aux)when '1',
			(aux_X2 - X_add_aux) when others;


end Simp_W8_arch;