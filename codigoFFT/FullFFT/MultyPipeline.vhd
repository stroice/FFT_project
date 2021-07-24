library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package vpkg is
	type v is array(natural range <>) of std_logic_vector(9 downto 0);
end package;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.Components.ALL;
use work.vpkg.all;


entity MultyPipeline is
	generic(	
	  N:		   natural:=29 ;		  -- Number of pipelines used
	  WL: 	   natural:= 10
	  );		  -- Word Length	
	port(
	  clk: 	 		 in  std_logic;
	  Input:     in  std_logic_vector(WL - 1 downto 0); 
	  Output:    out v (0 to N)
	  );
end MultyPipeline;

architecture MultyPipeline_arch of MultyPipeline is

component Pipeline
	generic(	
	  WL: 	   integer:= 10);		  -- Word Length	
	port(
	  clk: 	 		 in  std_logic;
	  Input:     in  std_logic_vector(WL - 1 downto 0); 
	  Output:    out std_logic_vector(WL - 1 downto 0)
	  );
end component;

SIGNAL rdData:  v (0 to N); 

begin 

	 

	Pipeline_1 : Pipeline
	generic map(	
	  WL => WL)		  -- Word Length	
      port map (
      clk => clk,
	  Input => Input,
	  Output => rdData(0)
        );

    SET_WIDTH : for ii in 1 to N-1 generate
    i_Pipeline : Pipeline
	generic map(	
	  WL => WL)		  -- Word Length	
      port map (
      clk => clk,
	  Input => rdData(ii-1),
	  Output => rdData(ii)
        );
	end generate SET_WIDTH;
   
   Output<= rdData;
   
end MultyPipeline_arch;
