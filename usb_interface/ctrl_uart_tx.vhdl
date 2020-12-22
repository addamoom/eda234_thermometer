-- Written By Ivar

-- Control for UART transmission protocol
-- Transmit 8 bit data with a start and stop byte

-- _Start ___ ___ ___ ___ ___ ___ ___ ___ ___ Start ___ ___ ___ ___ ___ ___ ___ ___ ___
--  \___/ D1  D2  D3  D4  D5  D6  D7  D8  Stop\___/ D1  D2  D3  D4  D5  D6  D7  D8  Stop

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity ctrl_uart_tx is
    port(   send    : in STD_LOGIC;
            data    : in STD_LOGIC_VECTOR (7 downto 0);
            clk     : in STD_LOGIC;
            ready   : out STD_LOGIC;
            uart_tx : out STD_LOGIC
        );
end ctrl_uart_tx;

architecture behave of ctrl_uart_tx is

-- State machine
-- RDY - Wait for selected with send signal
--      Set ready signal
-- LD - Load bit to send, 1 Clk cycle
-- SD - Send bit
type tx_type is (RDY, LD_BIT, SD_BIT);
signal tx_state : tx_type := RDY;

-- Data to be sent with start and stop bit
signal send_data : STD_LOGIC_VECTOR (9 downto 0);

-- The bit actually transmitted
signal bit_TX : STD_LOGIC := '1';

-- Index for which bit to transmit
signal index_bit : natural; 

-- Baud rate 9600
-- Timing
signal bit_Tmr : std_logic_vector(13 downto 0) := (others => '0');
--10416 = (round(100MHz / 9600)) - 1
constant BIT_TMR_MAX : std_logic_vector(13 downto 0) := "10100010110000"; 
signal bitDone : STD_LOGIC := '0';

begin

-- Set 0 for start bit and 1 for stop bit
send_data <= '1' & data & '0'; 
 
state_proc : process (clk)
begin
    if (rising_edge(clk)) then
        case tx_state is
        when RDY =>
            if (send = '1') then -- When send is given start sending!
                tx_state <= LD_BIT;
                ready <= '0';
            else
                ready <= '1'; 
            end if;
            
        when LD_BIT =>
            -- when last bit, reset for next send
            if index_bit = 9 then
                index_bit <= 0;
            else 
                index_bit <= index_bit + 1;
            end if;
            --ready <= '0';
            -- Only one clock cycle
            tx_state <= SD_BIT;

        when SD_BIT =>
            --ready <= '0';
            if (bitDone = '1') then -- keep 9600 baud rate
                if index_bit = 9 then -- Last one, go back to rdy
                    tx_state <= RDY;
                else
                    tx_state <= LD_BIT;
                end if;
            end if;

        when others => -- should never happen
            tx_state <= RDY;
        end case;
    end if;
end process state_proc;

-- Baud Rate
-- Hold the baud rate when going into SD state
-- LD state only for one clock cycle
time_bit_proc : process (clk)
begin
    if (rising_edge(clk)) then
        if (tx_state = RDY) then
            bit_Tmr <= (others => '0');
        else
            if (bitDone = '1') then
                bit_Tmr <= (others => '0');
            else
                bit_Tmr <= bit_Tmr + 1;
            end if;
        end if;
    end if;
end process;

bitDone <= '1' when (bit_Tmr = BIT_TMR_MAX) else
            '0';

-- When LD state load the bit to be transmitted
-- during the SD state.
-- While RDY keep the line high
send_correct_proc : process (clk)
begin
    if rising_edge(clk) then
        if (tx_state = RDY) then
            bit_TX <= '1';
        elsif (tx_state = LD_BIT) then
            bit_TX <= send_data(index_bit);
        end if;
    end if;
end process send_correct_proc;
    
uart_tx <= bit_TX; -- Send out data.
    
end architecture behave;
