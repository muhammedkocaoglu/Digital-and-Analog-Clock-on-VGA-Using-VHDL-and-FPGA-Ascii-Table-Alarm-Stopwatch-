--clk and timer analog
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity clk_and_timer is port(
	   CLOCK_50 			: in std_logic;
		rst      			: in std_logic;
		SW		   			: in std_logic_vector(2 downto 0);
		KEY            	: in std_logic_vector(2 downto 0);
		--alarm inputs
		cntr59_sec_alarm	: in integer;
		cntr59_min_alarm	: in integer;
		cntr59_hour_alarm	: in integer;
		
		--outputs
		cntr59 				: out integer;
		cntr59_min 			: out integer;
		cntr59_hour    	: out integer;
		buzzer_en      	: out std_logic);
end entity;


architecture clk_and_timer of clk_and_timer is

	signal cntr59_sig 	: integer;		
	signal cntr59_min_sig : integer;
	signal cntr59_hour_sig : integer;
	signal buzzer_en_sig : std_logic;     

	signal clk_1hz : std_logic;
	signal enable : std_logic;

--##############################################################################################################
begin

	--get 1Hz and 25 Hz clock
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
	begin
		if rst = '0' then
			cntr59_sig <= 0;
			cntr59_min_sig <= 0;
			cntr59_hour_sig <= 0;
		elsif rising_edge(clk_1hz) then
		
				-- check if the buzzer_en for alarm should be uncommented
--				if ((cntr59_sig = cntr59_sec_alarm) and (cntr59_min_sig = cntr59_min_alarm)) then
--					if (cntr59_hour_sig < 12 ) then
--						if cntr59_hour_alarm = 0 then
--							buzzer_en_sig <= '1';
--						end if;
--					elsif (cntr59_hour_sig < 24 ) then
--						if cntr59_hour_alarm = 1 then
--							buzzer_en_sig <= '1';
--						end if;
--					elsif (cntr59_hour_sig < 36 ) then
--						if cntr59_hour_alarm = 2 then
--							buzzer_en_sig <= '1';
--						end if;
--					elsif (cntr59_hour_sig < 48 ) then
--						if cntr59_hour_alarm = 3 then
--							buzzer_en_sig <= '1';
--						end if;
--					elsif (cntr59_hour_sig < 60 ) then
--						if cntr59_hour_alarm = 4 then
--							buzzer_en_sig <= '1';
--						end if;
--					end if;
--				end if;
				-- end alarm check
	
				if SW(0) = '1' then
					if enable = '1' then
						
						if SW(2) = '1' then
							if cntr59_sig < 59 then
								cntr59_sig <= cntr59_sig + 1;
							else
								cntr59_sig <= 0;
								cntr59_min_sig <= cntr59_min_sig + 1;
								
								if ( cntr59_min_sig = 11 OR cntr59_min_sig = 23 OR cntr59_min_sig = 35 OR cntr59_min_sig = 48) then
									--cntr59_min_sig <= 0;
									cntr59_hour_sig <= cntr59_hour_sig +1;
								
									
								ELSIF (cntr59_min_sig = 59) then 
									cntr59_min_sig <= 0;
									cntr59_hour_sig <= cntr59_hour_sig +1; --11
									if cntr59_hour_sig = 59 then
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
								
								if ( cntr59_min_sig = 59 OR cntr59_min_sig = 47 OR cntr59_min_sig = 35 OR cntr59_min_sig = 23) then
									cntr59_hour_sig <= cntr59_hour_sig - 1;
								
								elsif cntr59_min_sig = 0 then
									cntr59_min_sig <= 59;
									cntr59_hour_sig <= cntr59_hour_sig - 1;
									if cntr59_hour_sig = 0 then
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
						cntr59_min_sig <= cntr59_min_sig+1;
						if cntr59_min_sig = 59 then
							cntr59_min_sig <= 0;
						end if;
					
					elsif KEY(2)='0' then
						cntr59_hour_sig <= cntr59_hour_sig+1;
						if cntr59_hour_sig = 59 then
							cntr59_hour_sig <= 0;
						end if;
					end if;
				end if;
			end if;	
	end process;
	cntr59 <= cntr59_sig;			
	cntr59_min <= cntr59_min_sig;	
	cntr59_hour <= cntr59_hour_sig;  	
	buzzer_en <= buzzer_en_sig;     
	
	
end architecture;