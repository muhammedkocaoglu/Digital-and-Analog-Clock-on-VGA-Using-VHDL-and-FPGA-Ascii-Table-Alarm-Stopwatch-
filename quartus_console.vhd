library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity quartus_console is port (
		clk_40		: in std_logic;
		xcoord		: in integer;
		ycoord		: in integer;
		VGA_R 		: out std_logic_vector(9 downto 0);
		VGA_G			: out std_logic_vector(9 downto 0);
		VGA_B 		: out std_logic_vector(9 downto 0));
end entity;

architecture Behavioral of quartus_console is
	
	component CHRLUT3 IS PORT (
		clock		: IN STD_LOGIC  := '1';
		Ascii    : in  STD_LOGIC_VECTOR (6 downto 0);
		chrow    : in  STD_LOGIC_VECTOR (3 downto 0);
		q		   : OUT STD_LOGIC_VECTOR (7 DOWNTO 0) );
	end component;
	
	component CharBuffer is port(
		clk		: in std_logic;
		Addr		: in std_logic_vector(12 downto 0);
		Ascii		: out std_logic_vector(6 downto 0));
	end component;

	
	signal Addr 		: std_LOGIC_vector(12 downto 0);
	signal xcoord_sig : std_LOGIC_vector(9 downto 0);
	signal ycoord_sig : std_LOGIC_vector(9 downto 0);
	signal Dout    	: std_LOGIC_VECTOR(7 downto 0);
	signal VGA_R_sig 	: std_logic_vector(9 downto 0);
	signal VGA_G_sig 	: std_logic_vector(9 downto 0);
	signal VGA_B_sig 	: std_logic_vector(9 downto 0);
	signal xyvalid    : std_LOGIC;
	
	signal chcol_d1 : STD_LOGIC_VECTOR(2 downto 0);
	signal chrow: STD_LOGIC_VECTOR(3 downto 0);
   signal chcol: STD_LOGIC_VECTOR(2 downto 0);
   signal Row: STD_LOGIC_VECTOR(5 downto 0);
   signal Col: STD_LOGIC_VECTOR(6 downto 0);
	signal pixdata : STD_LOGIC_VECTOR(7 downto 0);
	signal Ascii   : STD_LOGIC_VECTOR(6 downto 0);
	
	signal clk_low : std_LOGIC;
	signal cntr    : std_LOGIC_vector(39 downto 0) := "0000000000000001111111111111111111111111";
	signal enable  : std_LOGIC;
		
begin
   xcoord_sig <= std_logic_vector(to_unsigned(xcoord,10));
	ycoord_sig <= std_logic_vector(to_unsigned(ycoord,10));

	chrow <=ycoord_sig(3 downto 0); Row <= ycoord_sig(9 downto 4);
	chcol <= chcol_d1; Col <= xcoord_sig(9 downto 3);
	        
	Addr <= "1100100" * Row + Col; -- "01100100" = 100
	
	
	process(clk_40)
	begin
		if rising_edge(clk_40) then
			chcol_d1 <= xcoord_sig(2 downto 0) - 1;
		end if;
	end process;
		
	
	CHARBUF: CharBuffer port map(CLK => clk_40, Addr => Addr(12 downto 0), Ascii => Ascii);

	CHRLUT3_ins: CHRLUT3 port map(clock	=> clk_40, Ascii => Ascii, chrow => chrow,	q	=> pixdata);

	
	process(clk_40)
	variable counter : integer:=0;
	begin
		if (rising_edge(clk_40)) then
			if counter = 700000 then
				clk_low <= not clk_low;
				counter := 0;
			else
				counter := counter + 1;
			end if;
		end if;	
	end process;
	
	process(clk_low)
	begin
		if rising_edge(clk_low) then
			cntr <= cntr(0) & cntr(39 downto 1);
		end if;
	end process;

	process(clk_40, pixdata) 
	begin
		if rising_edge(clk_40) then
			 if((pixdata(to_integer(unsigned(chcol)))='1')) then
				VGA_R_sig <= cntr(9 downto 0);
				VGA_G_sig <= cntr(15 downto 6);
				VGA_B_sig <= cntr(20 downto 11);
			else
				VGA_R_sig <= "0000000000";
				VGA_G_sig <= "0000000000";
				VGA_B_sig <= "0000000000";
				
			end if;
		end if;
	end process;
	VGA_R <= VGA_R_sig;
	VGA_G <= VGA_G_sig;
	VGA_B <= VGA_B_sig;

end Behavioral;