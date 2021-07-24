
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;



entity ROM_32 is
generic (
	  constant WL: 	   integer:= 11;			  -- Word Length	
	  constant BL_exp:  integer:= 5);		   -- Power of 2 size of memory
	port(
	  control:  in  std_logic_vector(BL_exp - 1 downto 0);
	  C:    out std_logic_vector(WL - 1 downto 0);
	  S:    out std_logic_vector(WL - 1 downto 0));
end ROM_32;


architecture ROM_32_arch of ROM_32 is
 
 
 
      type C_memory is array ((2**BL_exp) -1 downto 0) of std_logic_vector(WL -1 downto 0);
	  type S_memory is array ((2**BL_exp) -1 downto 0) of std_logic_vector(WL -1 downto 0);
	  
	  
	  constant ROM_content_C: C_memory :=(0=>"01111111111",1=>"01111111111",2=>"01111111111",3=>"01111111111",4=>"01111111111",5=>"01111111111",6=>"01111111111",7=>"01111111111",
																   8=>"01111111111",9=>std_logic_vector(to_signed(1003,11)),10=>std_logic_vector(to_signed(945,11)),11=>std_logic_vector(to_signed(851,11)),12=>std_logic_vector(to_signed(723,11)),13=>std_logic_vector(to_signed(568,11)),14=>std_logic_vector(to_signed(391,11)),15=>std_logic_vector(to_signed(200,11)),
																   
																   16=>"01111111111",17=>std_logic_vector(to_signed(945,11)),18=>std_logic_vector(to_signed(723,11)),19=>std_logic_vector(to_signed(391,11)),20=>std_logic_vector(to_signed(0,11)),21=>std_logic_vector(to_signed(-391,11)),22=>std_logic_vector(to_signed(-723,11)), 23=>std_logic_vector(to_signed(-945,11)),
																   24=>"01111111111",25=>std_logic_vector(to_signed(851,11)),26=>std_logic_vector(to_signed(391,11)),27=>std_logic_vector(to_signed(-200,11)),28=>std_logic_vector(to_signed(-723,11)),29=>std_logic_vector(to_signed(-1003,11)),30=>std_logic_vector(to_signed(-945,11)), 31=>std_logic_vector(to_signed(-568,11)) );
	  
	  constant ROM_content_S: S_memory :=(0=>"00000000000",1=>"00000000000",2=>"00000000000",3=>"00000000000",4=>"00000000000",5=>"00000000000",6=>"00000000000",7=>"00000000000",
																   8=>"00000000000",9=>std_logic_vector(to_signed(-200,11)),10=>std_logic_vector(to_signed(-391,11)),11=>std_logic_vector(to_signed(-568,11)),12=>std_logic_vector(to_signed(-723,11)),13=>std_logic_vector(to_signed(-851,11)),14=>std_logic_vector(to_signed(-945,11)),15=>std_logic_vector(to_signed(-1003,11)),
																   
																   16=>"00000000000",17=>std_logic_vector(to_signed(-391,11)),18=>std_logic_vector(to_signed(-723,11)),19=>std_logic_vector(to_signed(-945,11)),20=>std_logic_vector(to_signed(-1023,11)),21=>std_logic_vector(to_signed(-945,11)),22=>std_logic_vector(to_signed(-723,11)), 23=>std_logic_vector(to_signed(-391,11)),
																   24=>"00000000000",25=>std_logic_vector(to_signed(-568,11)),26=>std_logic_vector(to_signed(-945,11)),27=>std_logic_vector(to_signed(	-1003,11)),28=>std_logic_vector(to_signed(-723,11)),29=>std_logic_vector(to_signed(-200,11)),30=>std_logic_vector(to_signed(391,11)), 31=>std_logic_vector(to_signed(851,11)) );
begin 
          
      C <= ROM_content_C(to_integer(unsigned(control)));               
	  S <= ROM_content_S(to_integer(unsigned(control)));  

end ROM_32_arch;


