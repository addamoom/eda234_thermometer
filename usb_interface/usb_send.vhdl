library IEEE;
use IEEE.std_logic_1164.all;

entity USB_send is
    port(
        CLK         : in STD_LOGIC;
        RESET_N     : in STD_LOGIC;
        UART_TXD    : out STD_LOGIC; -- Line in board
        USB_select  : in STD_LOGIC;
        USB_done    : out STD_LOGIC;
        USB_s_data  : in STD_LOGIC_VECTOR(39 downto 0) -- 5 ascii values
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

signal readyUART    : STD_LOGIC;
signal sendUART     : STD_LOGIC := '0';
signal dataUART     : STD_LOGIC_VECTOR (7 downto 0) := "00000000";

-- State-machine:
-- wait - wait on USB_select signal before starting
-- rst - reset all registers for a new send
-- ld_string -- load string to be sent and set
        -- str index to 0
-- send_char
--

type state_uart_type is (wait_select, wait_rdy, send_char, wait_rdy_low, wait_char_rdy);
signal uart_state : state_uart_type := wait_select;


type CHAR_ARRAY is array (integer range<>) of std_logic_vector(7 downto 0);
constant message_len : integer := 5; -- 5 ascii values = 5*8 = 40 bits
signal sendStr : CHAR_ARRAY(0 to (message_len-1));

signal strindex_sign : integer := 0;

signal selected : STD_LOGIC := '0';

signal USB_done_sign : STD_LOGIC := '0';

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
sendStr(0 to (message_len-1)) <= (
    USB_s_data(39 downto 32),
    USB_s_data(31 downto 24),
    USB_s_data(23 downto 16),
    USB_s_data(15 downto 8),
    USB_s_data(7 downto 0)
);
--sendStr() <= USB_s_data( to )

-- When selected start over sending process.
rst_process : process (USB_select)
begin
    if rising_edge(USB_select) and RESET_N = '1' then
        selected <= '1';
    else
        selected <= '0';
    end if;
end process rst_process;



uart_state_process : process (CLK)
variable strindex : integer := 0;
variable new_start : STD_LOGIC := '1'; -- so strindex count first after first one
begin
    strindex_sign <= strindex;
    if RESET_N = '1' then
        if rising_edge(CLK) then
            case uart_state is
            when wait_select =>
                if selected = '1' then
                    uart_state <= wait_rdy;
                    
                end if;
                sendUART <= '0';
                new_start := '1'; -- YES new start
            when wait_rdy => -- keep waiting
                if readyUART = '0' then
                    uart_state <= wait_rdy; 
                else 
                    uart_state <= send_char;
                end if;
                strindex := 0;
                sendUART <= '0';
                USB_done_sign <= '0';
            when send_char =>
                if strindex = message_len then
                    uart_state <= wait_select; -- Finished with full word!
                    USB_done_sign <= '1';
                else
                    sendUART <= '1';
                    dataUART <= sendStr(strindex);
                    uart_state <= wait_rdy_low;
                    strindex := strindex + 1;
                    --if new_start = '1' then
                    --    strindex := 0;
                    --    new_start := '0';
                    --else
                    --    strindex := strindex + 1;
                    --end if;
                end if;

            when wait_rdy_low =>
                if readyUART = '0' then
                    uart_state <= wait_char_rdy;
                else
                    uart_state <= wait_rdy_low;
                end if;

            when wait_char_rdy =>
                if (readyUART = '1') then
                    uart_state <= send_char;
                else
                    uart_state <= wait_char_rdy;
                end if;
                sendUART <= '0';
            
            when others => -- Should never happen
                uart_state <= wait_select;
            end case;         
        end if;
    else
        uart_state <= wait_select;
    end if;
end process uart_state_process;

end architecture behave;