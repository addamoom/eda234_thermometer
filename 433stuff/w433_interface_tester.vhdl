LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY W433_interface_tester IS
    PORT (
        JB1       : IN STD_LOGIC;
        BTNU      : IN STD_LOGIC;
        CLK100MHZ : IN STD_LOGIC;
        LED       : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END W433_interface_tester;

ARCHITECTURE ett OF W433_interface_tester IS
    COMPONENT W433_interface IS
        PORT (
            Clk_10us    : IN STD_LOGIC;
            Reset_n     : IN STD_LOGIC;
            get_sample  : IN STD_LOGIC;
            data_in     : IN STD_LOGIC;
            Temp_out    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            sample_done : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT freq_divisor IS
        GENERIC (N : INTEGER := 10);
        PORT (
            clk     : IN STD_LOGIC;
            reset_n : IN STD_LOGIC;
            clk_out : OUT STD_LOGIC
        );
    END COMPONENT freq_divisor;

    SIGNAL Reset_n  : STD_LOGIC;
    SIGNAL Clk_10us : STD_LOGIC;
    SIGNAL Temp_out : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN

    Reset_n <= NOT BTNU;
    LED <= Temp_out;

    d100khz : freq_divisor GENERIC MAP(N => 1000) --1000 on actual hardware, 1 for simulation with testbench 
    PORT MAP
    (
        clk     => CLK100MHZ,
        reset_n => Reset_n,
        clk_out => Clk_10us
    );

    DUT : W433_interface
    PORT MAP(
        Clk_10us    => Clk_10us,
        Reset_n     => Reset_n,
        get_sample  => '0',
        data_in     => JB1,
        Temp_out    => Temp_out,
        sample_done => OPEN
    );
END;