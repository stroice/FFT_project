library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Rotator_W32 is
	generic(	 
		Input_Data_size:	integer:=16			-- Size of the signal data to be processed
		);			
	port(
		clk: 	 	 in  std_logic;
		control: 	 in  std_logic_vector(4 downto 0);
	  	X_in:  		 in  signed(Input_Data_size -1 downto 0);
		Y_in:  		 in  signed(Input_Data_size -1 downto 0); 
	  	X_out: 		 out signed(Input_Data_size +16 downto 0);
		Y_out: 		 out signed(Input_Data_size +16 downto 0)
		);
end Rotator_W32;

architecture Rotator_W32_norm_arch of Rotator_W32 is

component Rotator_W8
	generic(	 
		Input_Data_size:	integer			-- Size of the signal data to be processed
		);			
	port(
		clk: 	 	 in  std_logic;
		control: 	 in  std_logic_vector(2 downto 0);
	  	X_in:  		 in  signed(Input_Data_size -1 downto 0);
		Y_in:  		 in  signed(Input_Data_size -1 downto 0); 
	  	X_out: 		 out signed(Input_Data_size +9  downto 0);
		Y_out: 		 out signed(Input_Data_size +9  downto 0)
		);
end component;

SIGNAL X_45: signed(Input_Data_size +9 downto 0);
SIGNAL Y_45: signed(Input_Data_size +9 downto 0);

SIGNAL X_Mux_In: signed(Input_Data_size +9 downto 0);
SIGNAL Y_Mux_In: signed(Input_Data_size +9 downto 0);

SIGNAL X_Mux_In_reg: signed(Input_Data_size +9 downto 0);
SIGNAL Y_Mux_In_reg: signed(Input_Data_size +9 downto 0);

SIGNAL X_oposite: signed(Input_Data_size +12 downto 0);
SIGNAL Y_oposite: signed(Input_Data_size +12 downto 0);

SIGNAL X_out_aux: signed(Input_Data_size +12 downto 0);
SIGNAL Y_out_aux: signed(Input_Data_size +12 downto 0);

-------------------------------------------------------------------------

SIGNAL control_reg1: std_logic_vector(1 downto 0);
SIGNAL control_reg2: std_logic_vector(1 downto 0);
SIGNAL control_reg3: std_logic;

SIGNAL X_oposite_reg: signed(Input_Data_size +12 downto 0);
SIGNAL Y_oposite_reg: signed(Input_Data_size +12 downto 0);

SIGNAL X_pip: 	signed(Input_Data_size +12 downto 0);
SIGNAL Y_pip: 	signed(Input_Data_size +12 downto 0);

SIGNAL X2_out: 	signed(Input_Data_size +16 downto 0);
SIGNAL Y2_out: 	signed(Input_Data_size +16 downto 0);

begin

		--W8


	W8_Rot:Rotator_W8 generic map(Input_Data_size => (Input_Data_size))	
		port map(clk => clk,control => control(4 downto 2), X_in => X_in, Y_in => Y_in, X_out => X_45, Y_out => Y_45);


	pipeline: process(clk)
         begin 
            if rising_edge(clk) then
			
			--first pipeline required for the control signals for coordingation with internal pipeline inside the W8 rotator
			
			control_reg1 <=control(1 downto 0);	
			
			control_reg2 <= control_reg1;
			
			control_reg3 <= control_reg2(1);
			
			X_pip <= X_out_aux; 
			Y_pip <= Y_out_aux;
			
			X_Mux_In_reg <= X_Mux_In; 
			Y_Mux_In_reg <= Y_Mux_In;

			X_oposite_reg <= X_oposite; 
			Y_oposite_reg <= Y_oposite;  

            end if;

      	end process;   

 	with control_reg1(1) select
	    X_Mux_In <= Y_45 when '1',
			X_45 when others;

	with control_reg1(1) select
	    Y_Mux_In <= X_45 when '1',
			Y_45 when others;

	with not(control_reg2(0) xor control_reg2(1)) select
	    X_out_aux <= (resize(X_Mux_In_reg & "00",Input_Data_size +13) - resize(Y_Mux_In_reg,Input_Data_size +13))  when '1',
			 resize(X_Mux_In_reg & "00",Input_Data_size +13) when others;

	with not(control_reg2(0) xor control_reg2(1)) select
	    Y_out_aux <=  (resize(Y_Mux_In_reg & "00",Input_Data_size +13) + resize(X_Mux_In_reg,Input_Data_size +13)) when '1',
			  resize(Y_Mux_In_reg & "00",Input_Data_size +13) when others;

	with not(control_reg2(0) xor control_reg2(1)) select
	    X_oposite <=  Y_out_aux when '1',
			  (Y_Mux_In_reg & "000") when others;

	with not(control_reg2(0) xor control_reg2(1)) select
	    Y_oposite <= X_out_aux when '1',
			 (X_Mux_In_reg & "000") when others;

	    --Second part of the pipeline

	
	X2_out <= (X_pip  & "0000") + resize(X_pip  & "00", Input_Data_size +17) - resize(X_oposite_reg, Input_Data_size +17);
	Y2_out <= (Y_pip  & "0000") + resize(Y_pip  & "00", Input_Data_size +17) + resize(Y_oposite_reg, Input_Data_size +17);


 	with control_reg3 select
	    X_Out <= Y2_out when '1',
			 X2_out when others;

	with control_reg3 select
	    Y_Out <= X2_out when '1',
			 Y2_out when others;


end Rotator_W32_norm_arch;