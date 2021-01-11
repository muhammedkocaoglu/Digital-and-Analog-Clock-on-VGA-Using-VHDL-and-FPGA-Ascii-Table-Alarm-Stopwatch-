
--NAME			: MUHAMMED KOCAOGLU
--INSTITUTION	: ESKISEHIR OSMANGAZI UNIVERSITY
--DEPARTMENT	: ELECTRICAL ELECTRONICS ENGINEERING
--PROJECT NAME : DIGITAL AND ANALOG CLOCKS ON VGA
--DATE			: 22/01/2021
--E-MAIL			: mdkocaoglu@gmail.com


--TOP LEVEL ENTITY 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity vga_clock is port(
			CLOCK_50				: in std_logic;
			KEY         		: in std_logic_vector(2 downto 0);
			KEY_an_dig_sel		: in std_logic;
			SW 					: in std_logic_vector(2 downto 0);
			GPIO_0_an_dig_sel	: in std_logic;
			rst         		: in std_logic;  --key[3]
			GPIO_0      		: in std_logic_vector(3 downto 0);   --shift the clock on VGA bit [0 1 2 3]
		
			--Outputs
			buzzer_en   		: out std_logic;  --gpio_1[1] is for buzzer.  
			VGA_CLK     		: out std_logic;
			VGA_BLANK   		: out std_logic;
			VGA_HS,VGA_VS 		: inout std_logic;
			VGA_R,VGA_G,VGA_B : out std_logic_vector(9 downto 0));
end entity;


architecture vga_clock of vga_clock is
	signal reset			: std_logic:='0';
	signal clk_40			: std_logic;
	signal cntr59			: integer:=0; 
	signal cntr59_min		: integer:=0;
	signal cntr59_hour	: integer:=0;
	signal clk_low 		: std_logic;
	signal cntr 			: std_logic_vector(20 downto 0);
	
	
	signal VGA_R_dig 		: std_logic_vector(9 downto 0);
	signal VGA_G_dig 		: std_logic_vector(9 downto 0);
	signal VGA_B_dig 		: std_logic_vector(9 downto 0);
	
	signal VGA_R_analog 	: std_logic_vector(9 downto 0);
	signal VGA_G_analog 	: std_logic_vector(9 downto 0);
	signal VGA_B_analog 	: std_logic_vector(9 downto 0);
	
	signal VGA_R_ascii 	: std_logic_vector(9 downto 0);
	signal VGA_G_ascii 	: std_logic_vector(9 downto 0);
	signal VGA_B_ascii 	: std_logic_vector(9 downto 0);
	
	
---------------------------------------------------------------
	component clk_analog is port (
					clk_40 			: in std_logic;
					hpos    			: in integer;
					vpos				: in integer;
					videoOn			: in std_logic;
					GPIO_0         : in std_logic_vector(3 downto 0);
					clk_low        : in std_logic;
					cntr59         : in integer;
					cntr59_min     : in integer;
					cntr59_hour    : in integer;
				
					--outputs
					VGA_R          : out std_logic_vector(9 downto 0);
					VGA_G          : out std_logic_vector(9 downto 0);
					VGA_B          : out std_logic_vector(9 downto 0));
	end component;

---------------------------------------------------------------
	component clk_digital is port(
					clk_40 			: in std_logic;
					hpos    			: in integer;
					vpos				: in integer;
					videoOn			: in std_logic;
					GPIO_0         : in std_logic_vector(3 downto 0);
					clk_low        : in std_logic;
					cntr59         : in integer;
					cntr59_min     : in integer;
					cntr59_hour    : in integer;
		
					--outputs
					VGA_R          : out std_logic_vector(9 downto 0);
					VGA_G          : out std_logic_vector(9 downto 0);
					VGA_B          : out std_logic_vector(9 downto 0));
	end component;
	
---------------------------------------------------------------
	-- timer for analog-- hour-> 0-59
	component clk_and_timer is port(
				CLOCK_50 		: in std_logic;
				rst      		: in std_logic;
				SW		   		: in std_logic_vector(2 downto 0);
				KEY            : in std_logic_vector(2 downto 0);
		
				--alarm inputs
				cntr59_sec_alarm	: in integer;
				cntr59_min_alarm	: in integer;
				cntr59_hour_alarm	: in integer;
		
				--outputs
				cntr59 			: out integer;
				cntr59_min 		: out integer;
				cntr59_hour    : out integer;
				buzzer_en      : out std_logic);
	end component;

-----------------------------------------------------------------
	-- timer for analog-- hour-> 0-11
	component clk_and_timer_dig is port(
				CLOCK_50 		: in std_logic;
				rst      		: in std_logic;
				SW		   		: in std_logic_vector(2 downto 0);
				KEY            : in std_logic_vector(2 downto 0);
		
				--outputs
				cntr59 			: out integer;
				cntr59_min 		: out integer;
				cntr59_hour    : out integer;
				buzzer_en      : out std_logic);
	end component;
	
----------------------------------------------------------------
   -- get 40 MHZ clock
   component PLL is port (
            clk_in_clk  : in  std_logic := 'X'; -- clk
            reset_reset : in  std_logic := 'X'; -- reset
            clk_out_clk : out std_logic);         -- clk
    end component PLL;
-----------------------------------------------------------------
	-- alarm feature
	component clk_alarm is port(
				CLOCK_50 		: in std_logic;
				rst      		: in std_logic;
				SW		   		: in std_logic_vector(2 downto 0);
				KEY            : in std_logic_vector(2 downto 0);
		
				--outputs
				cntr59 			: out integer;
				cntr59_min 		: out integer;
				cntr59_hour    : out integer);
	end component;
-----------------------------------------------------------------
   -- Ascii
	component quartus_console is port (
		clk_40		: in std_logic;
		xcoord		: in integer;
		ycoord		: in integer;
		VGA_R 		: out std_logic_vector(9 downto 0);
		VGA_G			: out std_logic_vector(9 downto 0);
		VGA_B 		: out std_logic_vector(9 downto 0));
	end component;
-----------------------------------------------------------------
	--800x600 VGA Monitor Signals 
	constant HD : integer  := 799;        --   799   Horizontal Display (800)
	constant HFP : integer := 40;         --   40    Right border (front porch)
	constant HSP : integer := 128;        --   128   Sync pulse (Retrace)
	constant HBP : integer := 88;         --   88    Left boarder (back porch)
	
	constant VD : integer  := 599;        --   599   Vertical Display (480)
	constant VFP : integer := 1;       	  --   1     Right border (front porch)
	constant VSP : integer := 4;			  --   4     Sync pulse (Retrace)
	constant VBP : integer := 23;         --   23   Left boarder (back porch)
	
	signal hPos : integer  := 0;          -- Horızantal position
	signal vPos : integer  := 0;          -- Vertıcal position
	
	
	signal videoOn : std_logic := '0';
--------------------------------------------
	signal cntr59_sec_dig	: integer:=0; 
	signal cntr59_min_dig	: integer:=0;
	signal cntr59_hour_dig	: integer:=0;
	signal buzzer_en_dig    : std_logic;
	signal KEY_analog			: std_logic_vector(2 downto 0);
	signal KEY_digital		: std_logic_vector(2 downto 0);
	signal GPIO_0_analog		: std_logic_vector(3 downto 0);
	signal GPIO_0_digital	: std_logic_vector(3 downto 0);
	
	--alarm signals
	signal cntr59_sec_alarm			: integer:=0;
	signal cntr59_min_alarm			: integer:=0;
	signal cntr59_hour_alarm		: integer:=0;
	
begin

	--select to make clocks senkron or not
	sync_a_d: process(KEY_an_dig_sel)
	begin
		if KEY_an_dig_sel = '1' then
			KEY_analog <= KEY;
			KEY_digital <= "111";
		else	
			KEY_analog <= "111";
			KEY_digital <= KEY;
		end if;
	end process;
	
	-- sw 16-- float analog and digital clock on the vga seperately.
	float_s: process(GPIO_0_an_dig_sel)
	begin
		if GPIO_0_an_dig_sel = '1' then
			GPIO_0_analog <= GPIO_0;
			GPIO_0_digital <= "1111";
		else
			GPIO_0_analog <= "1111";
			GPIO_0_digital <= GPIO_0;
		end if;
	end process;
	

	--get 40Mhz clock -- CLOCK MANAGER--	
	c1_pll2: PLL port map(
					clk_in_clk=>CLOCK_50, 
					reset_reset=>reset,
					clk_out_clk=>clk_40);
					
	


-----------------------------------------------------------------------------------------
	-- this inputs are used only for Altera Board. Other boards do not need this outputs. 
	--(as far as I know)
	VGA_CLK<=clk_40;
	VGA_BLANK <= (VGA_HS and VGA_VS);                                                      
-----------------------------------------------------------------------------------------


	
	Horizontal_position_counter:process(clk_40)
	begin
		if(clk_40'event and clk_40 = '1')then
			if (hPos = (HD + HFP + HSP + HBP)) then
				hPos <= 0;
			else
				hPos <= hPos + 1;
			end if;
		end if;
	end process;


	Vertical_position_counter:process(clk_40, hPos)
	begin
		if(clk_40'event and clk_40 = '1')then
			if(hPos = (HD + HFP + HSP + HBP))then
				if (vPos = (VD + VFP + VSP + VBP)) then
					vPos <= 0;
				else
					vPos <= vPos + 1;
				end if;
			end if;
		end if;
	end process;
	
	Horizontal_Synchronisation:process(clk_40, hPos)
	begin
		if(clk_40'event and clk_40 = '1')then
			if((hPos <= (HD + HFP)) OR (hPos > HD + HFP + HSP))then
				VGA_HS <= '1';
			else
				VGA_HS <= '0';
			end if;
		end if;
	end process;


	Vertical_Synchronisation:process(clk_40, vPos)
	begin
		if(clk_40'event and clk_40 = '1')then
			if((vPos <= (VD + VFP)) OR (vPos > VD + VFP + VSP))then
				VGA_VS <= '1';
			else
				VGA_VS <= '0';
			end if;
		end if;
	end process;


	video_on:process(clk_40, hPos, vPos)
	begin
		if(clk_40'event and clk_40 = '1')then
			if(hPos <= HD and vPos <= VD)then
				videoOn <= '1';
			else
				videoOn <= '0';
			end if;
		end if;
	end process;
------------------------------------------------------------------------------

	--get low freq. to use in shifting the clock on vga.
	process(clk_40)
	begin
		if rising_edge(clk_40) then
			cntr<=cntr+1;
		end if;
	end process;
	clk_low <= cntr(16);

	
	timer_clk: clk_and_timer port map(
	                        CLOCK_50 	=> CLOCK_50,	
	                        rst      	=> rst,	
	                        SW		   	=> SW,
	                        KEY         => KEY_analog,
									
									--alarm inputs
									cntr59_sec_alarm	   => cntr59_sec_alarm,
									cntr59_min_alarm	   => cntr59_min_alarm,
									cntr59_hour_alarm    => cntr59_hour_alarm,
									
	                        --outputs
	                        cntr59 		=> cntr59,
	                        cntr59_min 	=> cntr59_min,
	                        cntr59_hour => cntr59_hour,
	                        buzzer_en   => buzzer_en ); 


	
	timer_clk_digital: clk_and_timer_dig port map(
	                        CLOCK_50 	=> CLOCK_50,	
	                        rst      	=> rst,	
	                        SW		   	=> SW,
	                        KEY         => KEY_digital,
								
	                        --outputs
	                        cntr59 		=> cntr59_sec_dig,
	                        cntr59_min 	=> cntr59_min_dig,
	                        cntr59_hour => cntr59_hour_dig,
	                        buzzer_en   => buzzer_en_dig );
									
									
	-- Alarm process
	alarm_p: clk_alarm port map(
						CLOCK_50   	=>	CLOCK_50,
						rst      	=> rst,
						SW		   	=> SW,
	               KEY         => KEY,
	               
	               --outputs
	               cntr59 		=> cntr59_sec_alarm,
	               cntr59_min 	=> cntr59_min_alarm,
	               cntr59_hour => cntr59_hour_alarm   );
				


----get digital clock, when alarm feature is disabled uncomment this.-------------
	digital_Clock: clk_digital port map(
									clk_40 => clk_40, 
									hpos => hpos, 
									vpos => vpos, 
									videoOn => videoOn,
									GPIO_0 => GPIO_0_digital, 
									clk_low => clk_low, 
									cntr59 => cntr59_sec_dig, 
									cntr59_min => cntr59_min_dig, 
									cntr59_hour => cntr59_hour_dig, 
									VGA_R => VGA_R_dig, 
									VGA_G => VGA_G_dig, 
									VGA_B => VGA_B_dig );
									
									
									
	--get digital clock for alarm feature-- comment this to disable this feature-------
--	digital_Clock: clk_digital port map(
--									clk_40 			=> clk_40, 
--									hpos 				=> hpos, 
--									vpos 				=> vpos, 
--									videoOn 			=> videoOn,
--									GPIO_0 			=> GPIO_0_digital, 
--									clk_low		   => clk_low, 
--									cntr59 			=> cntr59_sec_alarm, 
--									cntr59_min 		=> cntr59_min_alarm, 
--									cntr59_hour 	=> cntr59_hour_alarm, 
--									VGA_R 			=> VGA_R_dig, 
--									VGA_G 			=> VGA_G_dig, 
--									VGA_B 			=> VGA_B_dig );

	--get analog clock to display on VGA 
	AnalogClock: clk_analog port map(
								clk_40 				=> clk_40, 
                        hpos 					=> hpos, 
                        vpos 					=> vpos, 
                        videoOn 				=> videoOn,
                        GPIO_0 				=> GPIO_0_analog, 
                        clk_low 				=> clk_low, 
                        cntr59 				=> cntr59, 
                        cntr59_min 			=> cntr59_min, 
                        cntr59_hour 		=> cntr59_hour, 

                        VGA_R 				=> VGA_R_analog, 
                        VGA_G 				=> VGA_G_analog, 
                        VGA_B 				=> VGA_B_analog );
								
	quartus_console_int: quartus_console port map (
								clk_40	=> clk_40,	
	                     xcoord	=> hpos,	
	                     ycoord	=> vpos,	
	                     VGA_R 	=> VGA_R_ascii,	
	                     VGA_G		=> VGA_G_ascii,	
	                     VGA_B 	=> VGA_B_ascii 	);
     

	-- see both analog and digital clock on VGA 
	--also my name, my school name, my depatment, my project name
	VGA_R <= VGA_R_analog xor VGA_R_dig xor VGA_R_ascii;
	VGA_G <= VGA_G_analog xor VGA_G_dig xor VGA_G_ascii;
	VGA_B <= VGA_B_analog xor VGA_B_dig xor VGA_B_ascii;


end architecture;