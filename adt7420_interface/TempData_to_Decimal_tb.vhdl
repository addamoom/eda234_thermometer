library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TempData_to_Decimal_tb is
end entity TempData_to_Decimal_tb;

architecture test of TempData_to_Decimal_tb is
    component TempData_to_Decimal is
        port (
            temp_data : in STD_LOGIC_VECTOR (12 downto 0);
            temp_dec : out STD_LOGIC_VECTOR (20 downto 0)
        );
    end component;

    signal temp_data_tb : STD_LOGIC_VECTOR (12 downto 0);
    signal temp_dec_tb : STD_LOGIC_VECTOR (20 downto 0);
begin

    UUT: component TempData_to_Decimal
        port map(
            temp_data => temp_data_tb,
            temp_dec => temp_dec_tb
        );


    --temp_data_tb <= b"0000001111110",
    --           b"0101010101010" after 10 ns;


    test: process 
    constant period: time := 20 ns;
    begin
        temp_data_tb <= "0000000000001";
        wait for period;
        temp_data_tb <= "0000000000010";
        wait for period;
        temp_data_tb <= "0000000000100";
        wait for period;
        temp_data_tb <= "0000000001000";
        wait for period;
        temp_data_tb <= '0' & x"111";
        wait for period;

        -- temp specified on datasheet
        wait for period;
        temp_data_tb <= '1' & x"D80"; -- -40 
        wait for period;
        temp_data_tb <= '1' & x"E70"; -- -25
        wait for period; 
        temp_data_tb <= '1' & x"FFF"; -- -0.06
        wait for period;
        temp_data_tb <= '0' & x"000"; -- 0
        wait for period;
        temp_data_tb <= '0' & x"001"; -- +0.06
        wait for period;
        temp_data_tb <= '0' & x"190"; -- +25
        wait for period;
        temp_data_tb <= '0' & x"690"; -- +105
        wait for period;
        temp_data_tb <= '0' & x"7D0"; -- +125
        wait for period;
        temp_data_tb <= '0' & x"960"; -- +150

        -- bug this one won't view, needed to be here...
        wait for period;
        temp_data_tb <= "0000000000010";

        ASSERT false report "END of test" severity FAILURE;
        wait;
    end process test;
        
    
end architecture test;