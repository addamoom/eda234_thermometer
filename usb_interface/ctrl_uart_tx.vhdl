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

    type tx_type is (RDY, LD_BIT, SD_BIT, SD_LAST_BIT);
    signal tx_state : tx_type := RDY;

    signal send_data : STD_LOGIC_VECTOR (9 downto 0);

    signal bit_TX : STD_LOGIC := '1';

    -- Index for which bit to transmit
    signal index_bit : natural; 

    -- Timing
    signal bit_Tmr : std_logic_vector(13 downto 0) := (others => '0');
    --10416 = (round(100MHz / 9600)) - 1
    constant BIT_TMR_MAX : std_logic_vector(13 downto 0) := "10100010110000"; 
    signal bitDone : STD_LOGIC := '0';

    --signal bit_send : STD_LOGIC;
begin

send_data <= '1' & data & '0'; -- last one dummy.
 
state_proc : process (clk)
variable new_start : STD_LOGIC := '0'; -- Check if new start so count proper
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
            --index_bit <= 0; 
            --new_start := '1';

            --index_bit <= 0;
        when LD_BIT =>
            --if new_start = '1' then
             --   index_bit <= 0;
            --    new_start := '0'; 
            --else
                if index_bit = 9 then
                    index_bit <= 0;
                else 
                    index_bit <= index_bit + 1;
                end if;
            --end if;
            ready <= '0';
            tx_state <= SD_BIT;

        when SD_BIT =>
            --bit_TX <= send_data(index_bit);
            ready <= '0';
            if (bitDone = '1') then -- keep 9600 baud rate
                if index_bit = 9 then -- Last one, go back to rdy
                    tx_state <= RDY;--SD_LAST_BIT;
                else
                    tx_state <= LD_BIT;
                end if;
            end if;
            
        when SD_LAST_BIT =>
            if bitDone = '1' then
                tx_state <= RDY;
            else 
                tx_state <= SD_LAST_BIT;
            end if;

        when others => -- should never happen
            tx_state <= RDY;
        end case;
    end if;
end process state_proc;

-- Copied from EXAMPLE! ----
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
------------------------

send_correct_proc : process (clk)
begin
    if rising_edge(clk) then
        if (tx_state = RDY) then
            bit_TX <= '1';
        elsif (tx_state = LD_BIT) then
            bit_TX <= send_data(index_bit);
        end if;
        --if (tx_state = LD_BIT) then
        --    bit_TX <= send_data(index_bit);
        --end if;
    end if;
end process send_correct_proc;
    

uart_tx <= bit_TX;
    
end architecture behave;
