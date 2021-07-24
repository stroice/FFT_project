library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;



entity ROM_8 is
generic (
	  constant WL: 	   integer:= 11;			  -- Word Length	
	  constant BL_exp:  integer:= 2);		   -- Power of 2 size of memory
	port(
	  control:  in  std_logic_vector(BL_exp - 1 downto 0);
	  C:    out std_logic_vector(WL - 1 downto 0);
	  S:    out std_logic_vector(WL - 1 downto 0));
end ROM_8;


architecture ROM_8_arch of ROM_8 is
 
 
 
      type C_memory is array ((2**BL_exp) -1 downto 0) of std_logic_vector(WL -1 downto 0);
	  type S_memory is array ((2**BL_exp) -1 downto 0) of std_logic_vector(WL -1 downto 0);
	  
	  constant ROM_content_C: C_memory :=(0=>"01111111111",1=>"01011010011",2=>"00000000000",3=>"10100101101");
	  constant ROM_content_S: S_memory :=(0=>"00000000000",1=>"10100101101",2=>"10000000001",3=>"10100101101");
begin 
          
      C <= ROM_content_C(to_integer(unsigned(control)));               
	  S <= ROM_content_S(to_integer(unsigned(control)));  

end ROM_8_arch;


