library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--use std.env.finish;

entity temp_sens_tb is
end temp_sens_tb;

architecture behave of temp_sens_tb is
component temp_sens is
    port (
        CLK : in STD_LOGIC; -- 100 Mhz clock
        RESET_N : in STD_LOGIC; 
        temp : out STD_LOGIC_VECTOR (12 downto 0); -- 13 bit vector
        SDA : inout STD_LOGIC;
        SCL : out STD_LOGIC;
        counter_out : out integer
        );   
end component;
signal CLK_tb : STD_LOGIC := '0';
signal RESET_N_tb : STD_LOGIC;
signal SDA_tb : STD_LOGIC;
signal SCL_tb : STD_LOGIC;
signal temp_out_tb : std_logic_vector(12 downto 0);
signal counter_out_tb : integer;
begin

    UUT : component temp_sens 
        port map (
            CLK => CLK_tb,
            RESET_N => RESET_N_tb,
            temp => temp_out_tb,
            SDA => SDA_tb,
            SCL => SCL_tb,
            counter_out => counter_out_tb
        );

    RESET_N_tb <= '0',
                '1' after 10 ns;

    CLK_tb <= NOT CLK_tb after 5 ns; -- 100 Mhz
    
    test_proc : process
    begin
        wait for 600 ns;
        report "RUNNING";

        ASSERT false report "END of test" severity FAILURE;
        wait;
    end process test_proc;

end architecture behave;