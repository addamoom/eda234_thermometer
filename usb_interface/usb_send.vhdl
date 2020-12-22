-- Written By Ivar

-- Takes in 5 ASCII values and send them over UART USB
-- to computer, PUTTY used to check.
-- Sending when selected.
-- Writing TEMP: XXX:XX /newline

library IEEE;
use IEEE.std_logic_1164.all;

entity USB_send is
    port(
        CLK         : in STD_LOGIC;
        RESET_N     : in STD_LOGIC;
        UART_TXD    : out STD_LOGIC; -- Line in board
        USB_select  : in STD_LOGIC;
        USB_done    : out STD_LOGIC;
        USB_s_data  : in STD_LOGIC_VECTOR(39 downto 0); -- 5 ascii values
        
        test_state : out STD_LOGIC_VECTOR(3 downto 0)--;
        --test_RESETN : out STD_LOGIC 
        
    );
end USB_send;

architecture behave of USB_send is

component ctrl_uart_tx
    port(   
        send    : in STD_LOGIC;
        data    : in STD_LOGIC_VECTOR (7 downto 0);
        clk     : in STD_LOGIC;
        ready   : out STD_LOGIC;
        uart_tx : out STD_LOGIC
    );
end component;

-- Signals to send into ctrl_uart_tx
signal readyUART    : STD_LOGIC;
signal sendUART     : STD_LOGIC := '0';
signal dataUART     : STD_LOGIC_VECTOR (7 downto 0) := "00000000";

-- Dont set this to a new value until the last send is completed!
signal USB_s_data_latest : STD_LOGIC_VECTOR (39 downto 0);

-- State-machine:
-- wait_select - wait on USB_select signal before starting
-- wait_rdy - wait on ctr_uart_tx to be ready to transmit
-- send char - send over the byte to be sent, 1 ASCII
-- wait_rdy_low - wait for first low bit of UART to be sent
-- wait_char_rdy - wait for the sending of one byte to finsih

type state_uart_type is (wait_select, wait_rdy, send_char, wait_rdy_low, wait_char_rdy);
signal uart_state : state_uart_type := wait_select;


type CHAR_ARRAY is array (integer range<>) of std_logic_vector(7 downto 0);
-- 5 ascii values = 5*8 = 40 bits + 2 last bits for new line
-- + 6 TEMP IND.:<space>
-- + 1 .
constant message_len    : integer := 5 + 2 + 11 + 1; 
signal sendStr          : CHAR_ARRAY(0 to (message_len-1));

--signal strindex_sign    : integer := 0;
signal selected         : STD_LOGIC := '0';
signal USB_done_sign    : STD_LOGIC := '0';

begin

USB_done <= USB_done_sign;

-- Sending bytes over UART line:
UART_TX_CTRL: ctrl_uart_tx port map(
    send    => sendUART,
    data    => dataUART,
    clk     => CLK, -- Same 100 Mhz clock
    ready   => readyUART,
    uart_tx => UART_TXD
);

-- Message to send into array:
-- Message TEMP IND.: XXX.XX /n
sendStr(0 to (message_len-1)) <= (
    x"54", -- T
    x"45", -- E
    x"4D", -- M
    x"50", -- P
    x"20", -- <space>
    x"49", -- I
    x"4E", -- N
    x"44", -- D
    x"2E", -- .
    x"3A", -- :
    x"20", -- <space>
    USB_s_data_latest(39 downto 32),
    USB_s_data_latest(31 downto 24),
    USB_s_data_latest(23 downto 16),
    x"2E", -- .
    USB_s_data_latest(15 downto 8),
    USB_s_data_latest(7 downto 0),
    x"0A", -- \n
    x"0D"  -- \r
);

uart_state_process : process (CLK)
variable strindex : integer := 0;
begin
    --strindex_sign <= strindex; --
    if RESET_N = '0' then -- Error if inverting if statement
        uart_state <= wait_select;
        --test_state <= "0000";
    else
        --test_state <= "1111";
        if rising_edge(CLK) then
            case uart_state is
            when wait_select =>
                --test_state <= b"0001";
                if USB_select = '1' then
                    -- Set only value to transmit when selected!
                    USB_s_data_latest <= USB_s_data; 
                    uart_state <= wait_rdy;
                    
                end if;
                sendUART <= '0';
            when wait_rdy => -- Wait until ctrl_UART rdy
                if readyUART = '0' then
                    uart_state <= wait_rdy; 
                else 
                    uart_state <= send_char;
                end if;
                strindex := 0;
                sendUART <= '0';
                USB_done_sign <= '0';
                --test_state <= b"0010";
            when send_char =>
                --test_state <= b"0011";
                if strindex = message_len then
                    uart_state <= wait_select; -- Finished with full word!
                    USB_done_sign <= '1';
                else
                    sendUART <= '1';
                    dataUART <= sendStr(strindex);
                    uart_state <= wait_rdy_low;
                    strindex := strindex + 1;
                end if;

            when wait_rdy_low =>
                --test_state <= b"0100";
                if readyUART = '0' then
                    uart_state <= wait_char_rdy;
                else
                    uart_state <= wait_rdy_low;
                end if;

            when wait_char_rdy =>
                --test_state <= b"0101";
                if (readyUART = '1') then
                    uart_state <= send_char;
                else
                    uart_state <= wait_char_rdy;
                end if;
                sendUART <= '0';
            
            when others => -- Should never happen
                --test_state <= b"0110";
                --uart_state <= wait_select;
            end case; 
        end if;
    end if; -- RESETN
end process uart_state_process;

end architecture behave;