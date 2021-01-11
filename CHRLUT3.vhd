LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY altera_mf;
USE altera_mf.all;

ENTITY CHRLUT3 IS PORT (
		clock		: IN STD_LOGIC  := '1';
		Ascii   : in  STD_LOGIC_VECTOR (6 downto 0);
		chrow   : in  STD_LOGIC_VECTOR (3 downto 0);
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0) );
END CHRLUT3;


ARCHITECTURE SYN OF chrlut3 IS

	--SIGNAL sub_wire0	: STD_LOGIC_VECTOR (7 DOWNTO 0);
	-------------------------------------------------------
	signal address    : STD_LOGIC_VECTOR (10 DOWNTO 0);
	signal Dout : STD_LOGIC_VECTOR(7 downto 0);



	COMPONENT altsyncram
	GENERIC (
		clock_enable_input_a		: STRING;
		clock_enable_output_a		: STRING;
		init_file		: STRING;
		intended_device_family		: STRING;
		lpm_hint		: STRING;
		lpm_type		: STRING;
		numwords_a		: NATURAL;
		operation_mode		: STRING;
		outdata_aclr_a		: STRING;
		outdata_reg_a		: STRING;
		widthad_a		: NATURAL;
		width_a		: NATURAL;
		width_byteena_a		: NATURAL
	);
	PORT (
			address_a	: IN STD_LOGIC_VECTOR (10 DOWNTO 0);
			clock0	: IN STD_LOGIC ;
			q_a	: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
	END COMPONENT;

BEGIN
	--q    <= sub_wire0(7 DOWNTO 0);
	
	APR: process(clock,Ascii,chrow,Dout) is begin
		--address <= Ascii(6 downto 1) & not(Ascii(0) & chrow);
		address <= Ascii & ( chrow);
		--q <= Dout;
		q <= Dout(0)&Dout(1)&Dout(2)&Dout(3)&Dout(4)&Dout(5)&Dout(6)&Dout(7);
	end process;

	altsyncram_component : altsyncram
	GENERIC MAP (
		clock_enable_input_a => "BYPASS",
		clock_enable_output_a => "BYPASS",
		init_file => "Hex2.hex",
		intended_device_family => "Cyclone II",
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		lpm_type => "altsyncram",
		numwords_a => 2048,
		operation_mode => "ROM",
		outdata_aclr_a => "NONE",
		outdata_reg_a => "CLOCK0",
		widthad_a => 11,
		width_a => 8,
		width_byteena_a => 1
	)
	PORT MAP (
		address_a => address,
		clock0 => clock,
		q_a => Dout
	);


END SYN;