-- Written by Ivar
-- Design assumed to have 100MHZ clock freq
-- If not correct value shows check values in ASCII_to_HEXDISP

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity hexdisp is 
	port(
		AN : out STD_LOGIC_VECTOR (7 downto 0); -- NEXYS
		SEG : out STD_LOGIC_VECTOR (7 downto 0); -- NEXYS
		CLK100MHZ : in STD_LOGIC; -- NEXYS
		ASCII : in STD_LOGIC_VECTOR (63 downto 0)); -- Message in exactly as it should be dsiplayed.
end hexdisp;

architecture behavioral of hexdisp is
signal refresh_counter : STD_LOGIC_VECTOR (19 downto 0); --1048576 * 10ns, enogh for 8 ms
signal anode : STD_LOGIC_VECTOR (2 downto 0);
signal DISP : STD_LOGIC_VECTOR (63 downto 0);

function ASCII_to_HEXDISP (
	ascii_in : STD_LOGIC_VECTOR(7 downto 0))
	return STD_LOGIC_VECTOR is
	variable hex_out : STD_LOGIC_VECTOR(7 downto 0);
	begin
		case ascii_in is
			when x"41" | x"61" => hex_out := "10001000"; -- A a
            when x"42" | x"62" | x"32" => hex_out := "10000000"; -- B b 8
            when x"43" | x"63" => hex_out := "11000110"; -- C c
            when x"44" | x"64" => hex_out := "11100000"; -- D d
            when x"45" | x"65" => hex_out := "10000110"; -- E e
            when x"46" | x"66" => hex_out := "10001110"; -- F f
            when x"47" | x"67" => hex_out := "11000010"; -- G g
            when x"48" | x"68" => hex_out := "10001001"; -- H h
            when x"49" | x"69" => hex_out := "11001111"; -- I i
            when x"4A" | x"6A" => hex_out := "11110001"; -- J j
            when x"4B" | x"6B" => hex_out := "11110101"; -- K k
            when x"4C" | x"6C" => hex_out := "11000111"; -- L l
            when x"4D" | x"6D" => hex_out := "11010100"; -- M m
            when x"4E" | x"6E" => hex_out := "10110111"; -- N n
            when x"4F" | x"6F" | x"30" => hex_out := "11000000"; -- O o 0
            when x"50" | x"70" => hex_out := "10001100"; -- P p
            when x"51" | x"71" => hex_out := "10010100"; -- Q q
            when x"52" | x"72" => hex_out := "10000100"; -- R r
            when x"53" | x"73" | x"35" => hex_out := "10010010"; -- S s 5
            when x"54" | x"74" => hex_out := "11001110"; -- T t
            when x"55" | x"75" => hex_out := "11000001"; -- U u
            when x"56" | x"76" => hex_out := "11010001"; -- V v
            when x"57" | x"77" => hex_out := "11100010"; -- W w
            when x"58" | x"78" => hex_out := "10110110"; -- X x
            when x"59" | x"79" => hex_out := "10010101"; -- Y y
            when x"5A" | x"7A" | x"32" => hex_out := "10100100"; -- Z z 2
            when x"31" => hex_out := "10000110"; -- 1
            when x"33" => hex_out := "10110000"; -- 3
            when x"34" => hex_out := "10011000"; -- 4
            when x"36" => hex_out := "10000011"; -- 6
            when x"37" => hex_out := "11111000"; -- 7
            when x"39" => hex_out := "10011000"; -- 9
            -- when x"" => hex_out := ""; --
			when others => hex_out := "11111111";
		end case;
	return STD_LOGIC_VECTOR(hex_out);
end function;

begin
    
    -- Convert from ASCII to the coding of display
    DISP(7 downto 0) <= ASCII_to_HEXDISP(ASCII(7 downto 0));
    DISP(15 downto 8) <= ASCII_to_HEXDISP(ASCII(15 downto 8));
    DISP(23 downto 16) <= ASCII_to_HEXDISP(ASCII(23 downto 16));
    DISP(31 downto 24) <= ASCII_to_HEXDISP(ASCII(31 downto 24));
    DISP(39 downto 32) <= ASCII_to_HEXDISP(ASCII(39 downto 32));
    DISP(47 downto 40) <= ASCII_to_HEXDISP(ASCII(47 downto 40));
    DISP(55 downto 48) <= ASCII_to_HEXDISP(ASCII(55 downto 48));
    DISP(63 downto 56) <= ASCII_to_HEXDISP(ASCII(63 downto 56));
    
    
    -- Debugging
	-- DISP <= x"1122334455667788";
	-- DISP(7 downto 0) <= ASCII_to_HEXDISP(x"4C");
	-- DISP(15 downto 8) <= ASCII_to_HEXDISP(x"4C");
	-- DISP(23 downto 16) <= ASCII_to_HEXDISP(x"41");
	-- DISP(31 downto 24) <= ASCII_to_HEXDISP(x"00"); 
	-- DISP(39 downto 32) <= ASCII_to_HEXDISP(x"4F"); 
	-- DISP(47 downto 40) <= ASCII_to_HEXDISP(x"4C"); 
	-- DISP(55 downto 48) <= ASCII_to_HEXDISP(x"45"); 
	-- DISP(63 downto 56) <= ASCII_to_HEXDISP(x"48");  
	-- DISP(63 downto 24) <= x"0000000000";
	

	count: process(CLK100MHZ)
	begin
		if(rising_edge(CLK100MHZ)) then
			refresh_counter <= refresh_counter + x"00001";
		end if;
	end process count;

	anode <= refresh_counter(19 downto 17); -- Decide which anode to be ON
	anode_light: process(anode)
	begin
		case anode is
			when "000" => 
				AN <= "11111110";
				SEG <= DISP(7 downto 0);
			when "001" => 
				AN <= "11111101";
				SEG <= DISP(15 downto 8);
			when "010" => 
				AN <= "11111011";
				SEG <= DISP(23 downto 16);
			when "011" => 
				AN <= "11110111";
				SEG <= DISP(31 downto 24);
			when "100" => 
				AN <= "11101111";
				SEG <= DISP(39 downto 32);
			when "101" => 
				AN <= "11011111";
				SEG <= DISP(47 downto 40); 
			when "110" => 
				AN <= "10111111";
				SEG <= DISP(55 downto 48);
			when "111" => 
				AN <= "01111111";
				SEG <= DISP(63 downto 56);
			when others => 
				AN <= "11111111"; -- Disable
				SEG <= x"0000000000000000"; -- Disable
		end case;
	end process anode_light;

end behavioral;


