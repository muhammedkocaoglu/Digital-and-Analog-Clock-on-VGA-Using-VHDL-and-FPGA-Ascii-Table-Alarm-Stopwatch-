library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity CharBuffer is port(
	clk		: in std_logic := '1';
	Addr		: in std_logic_vector(12 downto 0);
	Ascii		: out std_logic_vector(6 downto 0));
end entity;


architecture CharBuffer of CharBuffer is

	type BufType is array (0 to 3800) of std_logic_vector(0 to 7);
	signal BF : BufType := (
205=>x"4D", 206=>x"55", 207=>x"48", 208=>x"41", 209=>x"4D", 210=>x"4D", 211=>x"45", 212=>x"44", 213=>x"20", --MUHAMMED
214=>x"4B", 215=>x"4F", 216=>x"43", 217=>x"41", 218=>x"4F", 219=>x"47", 220=>x"4c", 221=>x"55",  --KOCAOGLU
									
305=>X"45" , 306=>X"53" , 307=>X"4B" , 308=>X"49" , 309=>X"53" , 310=>X"45" , 311=>X"48" , 312=>X"49" , 313=>X"52", 314=>X"20", --ESKISEHIR		
315=>X"4F" , 316=>X"53" , 317=>X"4D" , 318=>X"41" , 319=>X"4E" , 320=>X"47" , 321=>X"41" , 322=>X"5A" , 323=>X"49", 324=>X"20", --OSMANGAZI 	
325=>X"55" , 326=>X"4E" , 327=>X"49" , 328=>X"56" , 329=>X"45" , 330=>X"52" , 331=>X"53" , 332=>X"49" , 333=>X"54", 334=>X"59", --UNIVERSITY 	

405=>X"45" , 406=>X"4C" , 407=>X"45" , 408=>X"43" , 409=>X"54" , 410=>X"52" , 411=>X"49" , 412=>X"43" , 413=>X"41" , 414=>X"4C" , 415=>X"20" , 416=>X"26" , 417=>X"20",  --ELECTRICAL &
418=>X"45" , 419=>X"4C" , 420=>X"45" , 421=>X"43" , 422=>X"54" , 423=>X"52" , 424=>X"4F" , 425=>X"4E" , 426=>X"49" , 427=>X"43" , 428=>X"53" , 429=>X"20" ,	--ELECTRONICS
430=>X"45"  , 431=>X"4E" , 432=>X"47" , 433=>X"49" , 434=>X"4E" , 435=>X"45" , 436=>X"45" , 437=>X"52" , 438=>X"49" , 439=>X"4E" , 440=>X"47",

605=>x"44", 606=>x"49", 607=>x"47", 608=>x"49", 609=>x"54",	610=>x"41", 611=>x"4c", 612=>x"20", 613=>X"26" , 614=>X"20",	--DIGITAL &
615=>x"41", 616=>x"4e", 617=>x"41", 618=>x"4c", 619=>x"4f", 620=>x"47", 621=>x"20", --ANALOG
622=>x"43", 623=>x"4c", 624=>x"4f", 625=>x"43", 626=>x"4b", --CLOCK

805=>X"56" , 806=>X"48" , 807=>X"44" , 808=>X"4c" , 809=>X"20" , 810=>X"26" , 811=>X"20" , 812=>X"46" , 813=>X"50" , 814=>X"47" , 815=>X"41" , 816=>X"20" ,-- VHDL & FPGA
817=>X"50" , 818=>X"52" , 819=>X"4F" , 820=>X"4A" , 821=>X"45" , 822=>X"43" , 823=>X"54" ,
		 			
others=>x"20");
--&-26			
--SPACE-20
--A-41  B-42  C-43  D-44  E-45  F-46  G-47
--H-48  I-49  J-4A  K-4B  L-4C  M-4D  N-4E
--O-4F  P-50  Q-51  R-52  S-53  T-54  U-55
--V-56  W-57  X-58  Y-59  Z-5A

--45 53 4b 49 53 45 48 49 52 20  --ESKISEHIR
--4f 53 4D 41 4E 47 41 5A 49 20  --OSMANGAZI
--55 4E 49 56 45 52 53 49 54 45 53 49	 --UNIVERSITY
--
--45 4C 45 43 54 52 49 43 41 4C 20 26 20 --ELECTRICAL & 
--45 4C 45 43 54 52	4f 4e 49 43 53 --ELECTRONICS
--45 4E 47 49 4E 45 45 52 49 4E 47 --ENGINEERING	 
begin

	CHRPROC: process(clk, Addr, BF) is
		variable Data: std_logic_vector(7 downto 0);
	begin
		if rising_edge(clk) then
			Data := BF(to_integer(unsigned(Addr)));
			Ascii <= Data(6 downto 0);
		end if;
	end process;
	

end architecture;