library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity temp_sens is
    port (
        CLK : in STD_LOGIC; -- 100 Mhz clock
        RESET_N : in STD_LOGIC; 
        temp : out STD-; -- 13 bit vector
        SDA : inout STD_LOGIC;
        SCL : out STD_LOGIC;
        counter_period_out : out integer; -- For debugging
        counter_data_out : out integer;
        temp_select : in STD_LOGIC; -- When rising edge start.
        temp_ready ; out STD_LOGIC; -- High when a value can be read. 
    );
end temp_sens;

-- Read 2 byte from addr 0x4B -> I2C -> S10010111_xxxxxxxx_xxxxxxxx_P
	--     ____    __    __    __    __    __    __    __    __    __    __    __    __    __    __    __    __    __
	-- SCL     \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \
	--     __    ______            ______      ________________   |     |     |     |     |     |     |     |     |
	-- SDA   \__/  1   \_0_____0__/  1   \_0__/  1     1     1 \--A-|--7X-|--6X-|--5X-|--4X-|--3X-|--2X-|--1X-|--0X-|
	--          |                     addr                          |                          dataHi                     |

architecture behave of temp_sens is
COMPONENT freq_divisor IS
GENERIC (N : INTEGER := 10);
PORT (
    clk     : IN STD_LOGIC;
    reset_n : IN STD_LOGIC;
    clk_out : OUT STD_LOGIC
);
END COMPONENT freq_divisor;
type state_type is (
    wait_on_select,
    pre_start,
    do_a_start,
    write_dev_add_R,
    dev_ack_bit,
    read_MSB_data,
    read_LSB_data,
    Finish
);
signal state: state_type;
signal quarter_pulse: STD_LOGIC;
signal data_reg : STD_LOGIC_VECTOR (15 downto 0); --MSB and LSB regs

constant dev_add : STD_LOGIC_VECTOR (7 downto 1) := b"1001011"; 
constant MSB_add : STD_LOGIC_VECTOR (7 downto 0) := x"00";

signal ACK_bit : STD_LOGIC;

begin
    -- One clock cycle 4 pulses in a 10 khz signal => T = 4 * 100 us = 400 us
    --                   __                        __
    --  ________________/  \______________________/  \_______________
    pulse_4 : freq_divisor GENERIC MAP(N => 10000) -- 100M / 10k = 10^4
    port map
        (
        clk     => CLK,
        reset_n => RESET_N,
        clk_out => quarter_pulse
    );

    wait_start_proc : process(temp_select) 
    begin
        if rising_edge(temp_select) then
            state <= pre_start; -- start the reading
            temp_ready <= '0'; -- Not OK to read temp data
        end if;
    end process wait_start_proc;

    read_proc : process (quarter_pulse)
    variable counter_period : integer := 0; -- counts a full period
    variable counter_data : integer;
    constant dev_add_r : STD_LOGIC_VECTOR (7 downto 0) := dev_add & "1";
    begin  
        counter_period_out <= counter_period;
        counter_data_out <= counter_data;
        if RESET_N = '0'  then
            state <= wait_on_select; -- State waiting for select.
            counter_period := 1;
            counter_data := 2; --
            temp_ready <= '0'; -- Not OK to read temp data
        else 
            if rising_edge(quarter_pulse) then
                -- Count, 1 falling edge, 3 rising edge of correct pulse
                if counter_period = 4 then
                    counter_period := 1;
                    counter_data := counter_data - 1; -- MSB first!
                else
                    counter_period := counter_period + 1; 
                end if;

                if (state /= do_a_start) and (state/=pre_start) then
                    case counter_period is
                        when 1 | 2 => SCL <= '0';
                        when 3 | 4 => SCL <= '1';
                        when others => SCL <= '1';
                    end case;
                end if;

                case state is
                    when pre_start =>
                        SCL <= '1';
                        SDA <= '1';
                        if counter_data = 0 and counter_period = 2 then
                            state <= do_a_start;
                        end if;
                    when do_a_start =>
                        case counter_period is
                            when 2 | 3 => 
                                SDA <= '1';
                                SCL <= '1';
                            when 4 => 
                                SDA <= '0';
                                SCL <= '1';
                            when 1 =>
                                SDA <= '0';   
                                SCL <= '0';                         
                                state <= write_dev_add_R;
                                counter_data := 8; -- can I really do this? counter_data already set above
                            when others => SDA <= '1';
                        end case;
                        
                    when write_dev_add_R =>
                        case counter_period is
                            when 1 =>
                                SDA <= dev_add_r(counter_data);
                            when 2 => 
                                if counter_data = 0 then
                                    SDA <= 'Z';
                                    state <= dev_ack_bit;
                                else 
                                    SDA <= dev_add_r(counter_data - 1);
                                end if;
                            when 3 =>
                                SDA <= dev_add_r(counter_data - 1);
                            when 4 =>
                                SDA <= dev_add_r(counter_data - 1);
                            when others =>
                        end case; -- counter_period
                    
                    when dev_ack_bit =>
                        -- counter per
                        --SDA <= 'Z'; -- Or do I need to always set it to 'Z'
                        if counter_period = 3 then
                            ACK_bit <= SDA;
                        end if;
                        if counter_period = 1 then 
                            state <= read_MSB_data;
                            counter_data := 15;
                        end if;

                    when read_MSB_data =>
                        
                        case counter_period is
                            when 1 => 
                            if counter_data = 6 then
                                SDA <= '0'; -- Write ack-bit
                                state <= read_LSB_data;
                                counter_data := 7;
                            end if;
                            when 2 =>
                                if counter_data = 7 then
                                    SDA <= '0'; -- Write ack-bit
                                end if;
                            when 3 =>
                            if counter_data = 7 then
                                SDA <= '0'; -- Write ack-bit
                            end if;
                            when 4 =>
                            if counter_data = 7 then
                                SDA <= '0'; -- Write ack-bit
                            else
                                data_reg(counter_data) <= SDA;
                            end if;
                                
                            when others =>
                        end case;

                    when read_LSB_data =>
                        case counter_period is
                            when 1 => 
                                if counter_data = 6 then
                                    SDA <= '0'; -- Write ack-bit
                                    state <= Finish;
                                end if;
                                SDA <= 'Z';
                            when 2 =>
                                if counter_data = 7 then
                                    SDA <= 'Z';
                                end if;
                                if counter_data = -1 then
                                    state <= pre_start;
                                    counter_data := 2;
                                end if;
                            when 3 =>
                                SDA <= 'Z';
                            when 4 =>
                                data_reg(counter_data) <= SDA;
                            when others =>
                        end case;
                    
                    when Finish =>
                        temp <= data_reg (15 downto 3); -- Not the 3 lowest bits
                        temp_ready <= '1'; -- Now okay to read temp data. 
                    when others =>

                end case; -- state
            end if; -- rising edge
        end if; -- RESET_N
    end process read_proc;
    
end architecture behave;