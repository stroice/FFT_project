


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.Components.ALL;

entity Rotator_W32_unoptimized is
	generic(	 
		Input_Data_size:	integer:=16			-- Size of the signal data to be processed
		);			
	port(
		clk: 	 	 in  std_logic;
		counter: 	 in  std_logic_vector(4 downto 0);
	  	X_in:  		 in  signed(Input_Data_size -1 downto 0);
		Y_in:  		 in  signed(Input_Data_size -1 downto 0); 
	  	X_out: 		 out signed(Input_Data_size +16 downto 0);
		Y_out: 		 out signed(Input_Data_size +16 downto 0)
		);
end Rotator_W32_unoptimized;

architecture arch of Rotator_W32_unoptimized is

component Rotator_W8
	generic(	 
		Input_Data_size:	integer			-- Size of the signal data to be processed
		);			
	port(
		clk: 	 	 in  std_logic;
		counter: 	 in  std_logic_vector(2 downto 0);
	  	X_in:  		 in  signed(Input_Data_size +6 downto 0);
		Y_in:  		 in  signed(Input_Data_size +6 downto 0); 
	  	X_out: 		 out signed(Input_Data_size +16 downto 0);
		Y_out: 		 out signed(Input_Data_size +16 downto 0)
		);
end component;

SIGNAL X_Mux_In: signed(Input_Data_size -1 downto 0);
SIGNAL Y_Mux_In: signed(Input_Data_size -1 downto 0);

SIGNAL X_reg: 	signed(Input_Data_size -1 downto 0);
SIGNAL Y_reg: 	signed(Input_Data_size -1 downto 0);

SIGNAL X_oposite: signed(Input_Data_size +1 downto 0);
SIGNAL Y_oposite: signed(Input_Data_size +1 downto 0);

SIGNAL X_out_aux: signed(Input_Data_size +6 downto 0);
SIGNAL Y_out_aux: signed(Input_Data_size +6 downto 0);

-------------------------------------------------------------------------

SIGNAL counter_reg: std_logic_vector(4 downto 0);

SIGNAL X_oposite_reg: signed(Input_Data_size +1 downto 0);
SIGNAL Y_oposite_reg: signed(Input_Data_size +1 downto 0);

SIGNAL X_pip: 	signed(Input_Data_size +6 downto 0);
SIGNAL Y_pip: 	signed(Input_Data_size +6 downto 0);

SIGNAL aux_X2: 	signed(Input_Data_size +6 downto 0);
SIGNAL aux_Y2: 	signed(Input_Data_size +6 downto 0);

SIGNAL X2_out: 	signed(Input_Data_size +6 downto 0);
SIGNAL Y2_out: 	signed(Input_Data_size +6 downto 0);

SIGNAL X_Mux_Out: signed(Input_Data_size +6 downto 0);
SIGNAL Y_Mux_Out: signed(Input_Data_size +6 downto 0);

begin

	pipeline: process(clk)
         begin 
            if rising_edge(clk) then
		X_reg <= X_Mux_In;		
		Y_reg <= Y_Mux_In;

		X_pip <= X_out_aux; 
		Y_pip <= Y_out_aux;

		X_oposite_reg <= X_oposite; 
		Y_oposite_reg <= Y_oposite;  
		
		counter_reg <= counter;

            end if;

      	end process;   

 	with counter(1) select
	    X_Mux_In <= X_in when '1',
			Y_in when others;

	with counter(1) select
	    Y_Mux_In <= Y_in when '1',
			X_in when others;

	X_out_aux <= (resize(X_Mux_In & "00",Input_Data_size +3) + resize(X_Mux_In,Input_Data_size +3)) & "0000";
	Y_out_aux <= (resize(Y_Mux_In & "00",Input_Data_size +3) + resize(Y_Mux_In,Input_Data_size +3)) & "0000";

	with not(counter(0) xor counter(1)) select
	    X_oposite <= (X_Mux_In & "00") -  resize(X_Mux_In,Input_Data_size +2) when '1',
			  resize(X_Mux_In,Input_Data_size +2) when others;

	with not(counter(0) xor counter(1)) select
	    Y_oposite <= (Y_Mux_In & "00") -  resize(Y_Mux_In,Input_Data_size +2) when '1',
			  resize(Y_Mux_In,Input_Data_size +2) when others;

	    --Second part of the pipeline

	with not(counter_reg(0) xor counter_reg(1)) select
	    aux_X2 <= 	X_pip - X_reg when '1',
			X_pip when others;

	with not(counter_reg(0) xor counter_reg(1)) select
	    aux_Y2 <= 	Y_pip - Y_reg when '1',
			Y_pip when others;

	
	X2_out <= aux_X2 - resize((Y_oposite_reg  & "000"),Input_Data_size +7);
	Y2_out <= aux_Y2 + resize((X_oposite_reg  & "000"),Input_Data_size +7);


 	with counter_reg(1) select
	    X_Mux_Out <= X2_out when '1',
			 Y2_out when others;

	with counter_reg(1) select
	    Y_Mux_Out <= Y2_out when '1',
			 X2_out when others;

		--W8


	W8_Rot:Rotator_W8 generic map(Input_Data_size => (Input_Data_size + 7))	
		port map(clk => clk,counter => counter_reg(4 downto 2), X_in => X_Mux_Out, Y_in => Y_Mux_Out, X_out => X_out, Y_out => Y_out);


end arch;