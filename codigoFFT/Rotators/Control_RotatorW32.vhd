library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.Components.ALL;

entity Control_Rotator_W32 is
	generic(	 
		Input_Data_size:	integer:=16			-- Size of the signal data to be processed
		);			
	port(
	  	account: 		 in std_logic_vector(4 downto 0);
		control: 		 out std_logic_vector(4 downto 0)
		);
end Control_Rotator_W32;


architecture Control_Rotator_W32_arch of Control_Rotator_W32 is

begin

control_match: process(account)
	begin
		if account(4 downto 3) = "00" or account(2 downto 0) = "000" then
			control <= "00000";	--0º
		elsif account = "01001" then
			control <= "00001";	-- -11.25º
		elsif account = "01010" or account = "10001" then
			control <= "00010";	-- -22.5º
		elsif account = "01011" or account = "11001" then
			control <= "00011";	-- -33.75º
		elsif account = "01100" or account = "10010" then
			control <= "00100";	-- -45º
			
		elsif account = "01101" then
			control <= "00101";	-- -56.65º
		elsif account = "01110" or account = "10011" or account = "11010" then
			control <= "00110";	-- -67.5º
		elsif account = "01111" then
			control <= "00111";	-- -78.75º
		elsif account = "10100" then
			control <= "01000";	-- -90º
			
		elsif account = "11011" then
			control <= "01001";	-- -101.25º
		elsif account = "10101" then
			control <= "01010";	-- -112.5º
		elsif account = "10110" or account = "11100" then
			control <= "11100";	-- -135º
			
		elsif account = "10111"  then
			control <= "01110";	-- -157.5º
		elsif account = "11101"  then
			control <= "01111";	-- -168.75º
		elsif account = "11110"  then
			control <= "10010";	-- -202.5º
		elsif account = "11111"  then
			control <= "10101";	-- -236.25º
			
		end if;
		
		
end process;

end Control_Rotator_W32_arch;