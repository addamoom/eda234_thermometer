library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--use std.env.finish;

entity EX_tb is
end EX_tb;

architecture behave of EX_tb is
component GPIO_demo is
    Port ( SW 			: in  STD_LOGIC_VECTOR (15 downto 0);
           BTN 			: in  STD_LOGIC_VECTOR (4 downto 0);
           CLK 			: in  STD_LOGIC;
           LED 			: out  STD_LOGIC_VECTOR (15 downto 0);
           SSEG_CA 		: out  STD_LOGIC_VECTOR (7 downto 0);
           SSEG_AN 		: out  STD_LOGIC_VECTOR (7 downto 0);
           UART_TXD 	: out  STD_LOGIC;
           RGB1_Red		: out  STD_LOGIC;
           RGB1_Green	: out  STD_LOGIC;
           RGB1_Blue	: out  STD_LOGIC;	
           RGB2_Red		: out  STD_LOGIC;
           RGB2_Green	: out  STD_LOGIC;
           RGB2_Blue	: out  STD_LOGIC;
           micClk       : out STD_LOGIC;
           micLRSel     : out STD_LOGIC;
           micData      : in STD_LOGIC;
           ampPWM       : out STD_LOGIC;
           ampSD        : out STD_LOGIC			  
			  );  
end component;
signal tb_SW : STD_LOGIC_VECTOR (15 downto 0) := b"0000000000000000";
signal tb_BTN : STD_LOGIC_VECTOR (4 downto 0) := b"00000";
signal tb_CLK : STD_LOGIC := '0';
signal tb_LED : STD_LOGIC_VECTOR (15 downto 0) := x"0000";
signal tb_SSEG_CA : STD_LOGIC_VECTOR (7 downto 0) := x"00";
signal tb_SSEG_AN : STD_LOGIC_VECTOR (7 downto 0) := x"00";
signal tb_UART_TXD : STD_LOGIC;
signal tb_RGB1_Red : STD_LOGIC := '0';
signal tb_RGB1_Green : STD_LOGIC := '0';
signal tb_RGB1_Blue : STD_LOGIC := '0';
signal tb_RGB2_Red : STD_LOGIC := '0';
signal tb_RGB2_Green : STD_LOGIC := '0';
signal tb_RGB2_Blue : STD_LOGIC := '0';
signal tb_micClk : STD_LOGIC := '0';
signal tb_micLRSel : STD_LOGIC := '0';
signal tb_micData : STD_LOGIC := '0';
signal tb_ampPWM : STD_LOGIC := '0';
signal tb_ampSD : STD_LOGIC := '0';

signal RESET_N_tb : STD_LOGIC;
signal counter_period_out_tb, counter_data_out_tb : integer;
begin

    UUT : component GPIO_demo 
        port map ( 
            SW          => tb_SW,
            BTN 		=> tb_BTN,
            CLK 		=> tb_CLK,
            LED 		=> tb_LED,
            SSEG_CA 	=> tb_SSEG_CA,
            SSEG_AN 	=> tb_SSEG_AN,
            UART_TXD 	=> tb_UART_TXD,
            RGB1_Red	=> tb_RGB1_Red,
            RGB1_Green	=> tb_RGB1_Green,
            RGB1_Blue	=> tb_RGB1_Blue,	
            RGB2_Red	=> tb_RGB2_Red,
            RGB2_Green	=> tb_RGB2_Green,
            RGB2_Blue	=> tb_RGB2_Blue,
            micClk      => tb_micClk,
            micLRSel    => tb_micLRSel,
            micData     => tb_micData,
            ampPWM      => tb_ampPWM,
            ampSD       => tb_ampSD			  
        );

    RESET_N_tb <= '0',
                '1' after 10 ns;

    tb_CLK <= NOT tb_CLK after 5 ns; -- 100 Mhz
    
    test_proc : process
    begin
        wait for 15 ms;
        report "RUNNING";
        ASSERT false report "END of test" severity FAILURE;
        --wait;
        tb_BTN(4) <= '1';
        tb_BTN(3) <= '1';
        wait for 10 ms;
        tb_BTN(3) <= '0';
        

        wait for 10 ms;
        wait for 10 ms;

        ASSERT false report "END of test" severity FAILURE;
        wait;
    end process test_proc;

end architecture behave;