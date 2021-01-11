
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity clk_and_timer_dig is port(
			CLOCK_50 		: in std_logic;
			rst      		: in std_logic;
			SW		   		: in std_logic_vector(2 downto 0);
			KEY            : in std_logic_vector(2 downto 0);
		
			--outputs
			cntr59 			: out integer;
			cntr59_min 		: out integer;
			cntr59_hour    : out integer;
			buzzer_en      : out std_logic);
end entity;


architecture clk_and_timer_dig of clk_and_timer_dig is

signal cntr59_sig 	: integer;		
signal cntr59_min_sig : integer;
signal cntr59_hour_sig : integer;
signal buzzer_en_sig : std_logic;     

signal clk_1hz : std_logic;
signal enable : std_logic;
signal cntr59_hour_sig_bef : integer;

--##############################################################################################################
begin

	--get 1Hz clock
	process(CLOCK_50)
	variable cnt : integer;
   begin
		if rising_edge(CLOCK_50) then
			if SW(1) = '0' then
				 if (cnt<1000000) then
					 cnt:=cnt+1;
				 else
					 clk_1hz <= NOT(clk_1hz);
					 cnt:=0;
			    end if;
			else
				if (cnt=24999999) then
					 clk_1hz <= NOT(clk_1hz);
					 cnt:=0;
				 else
               cnt:=cnt+1;
			    end if;
			end if;
     end if;
	end process;
	

	--0 to 59 counter
	process(clk_1hz,SW(0),KEY(0),KEY(1),rst) 
		variable holder : integer := 0;
	begin
		if rst = '0' then
			cntr59_sig <= 0;
			cntr59_min_sig <= 0;
			cntr59_hour_sig <= 0;
			cntr59_hour_sig_bef <= 0;
			holder := 0;
		elsif rising_edge(clk_1hz) then
	
				if SW(0) = '1' then
					if enable = '1' then
						
						if SW(2) = '1' then
							if cntr59_sig < 59 then
								cntr59_sig <= cntr59_sig + 1;
							else
								cntr59_sig <= 0;
								cntr59_min_sig <= cntr59_min_sig + 1;
								if cntr59_min_sig = 59 then
									cntr59_min_sig <= 0;
									cntr59_hour_sig <= cntr59_hour_sig +1;
									
--									if ((cntr59_hour_sig) mod 5 = 0) then
--										cntr59_hour_sig_bef <= cntr59_hour_sig_bef + 1;
--										if cntr59_hour_sig_bef = 11 then
--											cntr59_hour_sig_bef <= 0;
--										end if;
--									end if;
									
									if cntr59_hour_sig = 11 then  -- buraası degisik
										cntr59_hour_sig <= 0;
									end if;
								end if;
							end if;
						else
						
							if cntr59_sig > 0 then
								cntr59_sig <= cntr59_sig  - 1;
							else
								cntr59_sig <= 59;
								cntr59_min_sig <= cntr59_min_sig - 1;
								if cntr59_min_sig = 0 then
									cntr59_min_sig <= 59;
									cntr59_hour_sig <= cntr59_hour_sig - 1;
									
									if cntr59_hour_sig  = 0 then   -- burası degisik
										cntr59_hour_sig <= 0;
										cntr59_min_sig <= 0;
										cntr59_sig <= 0;
										enable <= '0';
										buzzer_en_sig <= '1';
									end if;
								end if;
							end if;
						
						end if;
						
					end if;
					
				else
					if KEY(0)='0' then
						enable <= '1';
						buzzer_en_sig <= '0';
						if cntr59_sig < 59 then
							cntr59_sig <= cntr59_sig  + 1;
						else
							cntr59_sig <= 0;
						end if;
						
					elsif KEY(1)='0' then
						enable <= '1';
						buzzer_en_sig <= '0';  --assign to gpio_1(0) output pin 
						cntr59_min_sig <= cntr59_min_sig + 1;
						if cntr59_min_sig = 59 then
							cntr59_min_sig <= 0;
						end if;
					
					elsif KEY(2)='0' then
						if holder = 4 then
							holder := 0;
							cntr59_hour_sig <= cntr59_hour_sig + 1;
						else
							holder := holder + 1;
						end if;
						
						if cntr59_hour_sig = 11 then  -- burası degisik
							cntr59_hour_sig <= 0;
						end if;
						
						
						
--						if cntr59_hour_sig > 0 then
--							if ((cntr59_hour_sig mod 5) = 0) then
--								cntr59_hour_sig_bef <= cntr59_hour_sig_bef + 1;
--								if cntr59_hour_sig_bef = 11 then
--									cntr59_hour_sig_bef <= 0;
--								end if;
--							end if;
--						end if;
									
						
					end if;
				end if;
			end if;	
	end process;
	
	cntr59 <= cntr59_sig;			
	cntr59_min <= cntr59_min_sig;	
	cntr59_hour <= cntr59_hour_sig;   
	buzzer_en <= buzzer_en_sig;     
	
	
end architecture;