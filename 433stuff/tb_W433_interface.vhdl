LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tb_W433_interface IS

END tb_W433_interface;

ARCHITECTURE ett OF tb_W433_interface IS
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

    SIGNAL tb_Clk_10us    : STD_LOGIC := '0';
    SIGNAL tb_Reset_n     : STD_LOGIC;
    SIGNAL tb_get_sample  : STD_LOGIC;
    SIGNAL tb_data_in     : STD_LOGIC;
    SIGNAL tb_Temp_out    : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL tb_sample_done : STD_LOGIC;
BEGIN
    DUT : COMPONENT W433_interface PORT MAP(
        Clk_10us    => tb_Clk_10us,
        Reset_n     => tb_Reset_n,
        get_sample  => tb_get_sample,
        data_in     => tb_data_in,
        Temp_out    => tb_Temp_out,
        sample_done => tb_sample_done
    );
    clk_proc : PROCESS
    BEGIN
        WAIT FOR 1 ns;
        tb_Clk_10us <= NOT(tb_Clk_10us);
    END PROCESS clk_proc;

    test_proc :
    PROCESS
    BEGIN
        --Start-- 
        tb_Reset_n <= '0';
        WAIT FOR 1 ns; 
        tb_Reset_n <= '1';
        WAIT FOR 5 ns; 
        tb_data_in <= '1';
        WAIT FOR 5000 ns;
        tb_data_in <= '0';
        WAIT FOR 5000 ns;
        tb_data_in <= '1';
        WAIT FOR 5000 ns;
        tb_data_in <= '0';
        WAIT FOR 20000 ns;
        tb_data_in <= '1';
        WAIT FOR 10000 ns;
        tb_data_in <= '0';
        WAIT FOR 5000 ns;
        tb_data_in <= '1';
        WAIT FOR 100000 ns;
    END PROCESS;
END;