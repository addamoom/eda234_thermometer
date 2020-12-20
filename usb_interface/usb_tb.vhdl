library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--use std.env.finish;

entity usb_tb is
end usb_tb;

architecture behave of usb_tb is
component USB_send is
    port(
        CLK         : in STD_LOGIC;
        RESET_N     : in STD_LOGIC;
        UART_TXD    : out STD_LOGIC; -- Line in board
        USB_select  : in STD_LOGIC;
        USB_done    : out STD_LOGIC;
        USB_s_data  : in STD_LOGIC_VECTOR(39 downto 0) -- 5 ascii values
    );

end component;

signal tb_CLK : STD_LOGIC := '0';
signal tb_RESET_N : STD_LOGIC;
signal tb_UART_TXD : STD_LOGIC;
signal tb_USB_select : STD_LOGIC := '0';
signal tb_USB_done : STD_LOGIC;
signal tb_USB_s_data : STD_LOGIC_VECTOR (39 downto 0);

signal counter_period_out_tb, counter_data_out_tb : integer;
begin

    UUT : component USB_send 
        port map ( 
            CLK         => tb_CLK,
            RESET_N     => tb_RESET_N,
            UART_TXD    => tb_UART_TXD,
            USB_select  => tb_USB_select,
            USB_done    => tb_USB_done,
            USB_s_data  => tb_USB_s_data
        );

    tb_RESET_N <= '0',
                '1' after 1 ms;

    tb_CLK <= NOT tb_CLK after 5 ns; -- 100 Mhz
    
    test_proc : process
    begin
        wait for 2 ms;

        -- start transmission
        tb_USB_s_data <= x"A3FF2030AA";
        tb_USB_select <= '1';
        wait for 1 ms;

        tb_USB_select <= '0';

        wait for 10 ms;
        wait for 100 ns;

        ASSERT false report "END of test" severity FAILURE;
        wait;
    end process test_proc;

end architecture behave;