LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY temp_switcher_tester IS
END temp_switcher_tester;

ARCHITECTURE test OF temp_switcher_tester IS
    COMPONENT temp_switcher IS
        PORT (
            Clk              : IN STD_LOGIC;                     -- 100 khz clock
            Reset_n          : IN STD_LOGIC;                     -- Active low reset
            interal_temp_in  : IN STD_LOGIC_VECTOR(20 DOWNTO 0); -- 
            External_temp_in : IN STD_LOGIC_VECTOR(20 DOWNTO 0); --
            Toggle           : IN STD_LOGIC;                     -- switch output between the two inputs
            Temp_to_lcd      : OUT STD_LOGIC_VECTOR(20 DOWNTO 0) -- Temperature output to lcd
        );
    END COMPONENT temp_switcher;
    SIGNAL Clk, Reset_n, Toggle                     : STD_LOGIC := '0';
    SIGNAL Interal_temp, External_temp, Temp_to_lcd : STD_LOGIC_VECTOR(20 DOWNTO 0);

BEGIN
    DUT : COMPONENT temp_switcher PORT MAP(
        Clk              => Clk,
        Reset_n          => Reset_n,
        interal_temp_in  => Interal_temp,
        External_temp_in => External_temp,
        Toggle           => Toggle,
        Temp_to_lcd      => Temp_to_lcd
    );

    clk_proc :
    PROCESS
    BEGIN
        WAIT FOR 0.5 us;
        Clk <= NOT(Clk);
    END PROCESS clk_proc;

    test_proc :
    PROCESS
    BEGIN
        Reset_n       <= '0';
        Interal_temp  <= (OTHERS => '1');
        External_temp <= (OTHERS => '0');
        Toggle        <= '0';
        WAIT FOR 5 us;
        Reset_n <= '1';
        WAIT FOR 5 us;
        Toggle <= '1';
        WAIT FOR 2 us;
        Toggle <= '0';
        WAIT FOR 25 us;
        Toggle <= '1';
    END PROCESS;

END ARCHITECTURE test;