library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity temp_sens is
    port (
        CLK : in STD_LOGIC; -- 100 Mhz clock
        RESET_N : in STD_LOGIC; 
        temp : out STD_LOGIC_VECTOR (12 downto 0); -- 13 bit vector
        SDA : inout STD_LOGIC;
        SCL : out STD_LOGIC;
        counter_out : out integer -- For debugging
    );
end temp_sens;

architecture behave of temp_sens is

type state_type is (
    wait_for_start,
    write_dev_add_W,
    write_MSB_add,
    repeat_start,
    write_dev_add_R,
    read_MSB_data,
    read_LSB_data,
    Finish
);
signal state: state_type;
signal clk100kHz : STD_LOGIC;
signal data_reg : STD_LOGIC_VECTOR (15 downto 0); --MSB and LSB regs

constant dev_add : STD_LOGIC_VECTOR (7 downto 1) := b"1001011"; -- add R/W bit
constant MSB_add : STD_LOGIC_VECTOR (7 downto 0) := x"00";

signal ACK_bit : STD_LOGIC;

begin
    
    clk100kHz <= CLK;

    read_proc : process (clk100khz, RESET_N) is
    variable counter : integer := 0;
    begin
        if RESET_N = '0' then
            state <= wait_for_start;
            counter := 0;
        else
            if falling_edge(clk100khz) then
                counter := counter + 1;
            end if;
        end if;
        counter_out <= counter;    

        case state is
            when wait_for_start =>
                if RESET_N = '1' then
                    if counter < 5 then
                        SCL <= '1';
                        SDA <= '1';
                    elsif counter = 6 then
                        SCL <= '1';
                        SDA <= '0'; 
                    elsif counter = 7 then
                        state <= write_dev_add_W;
                        SCL <= clk100kHz;
                        SDA <= dev_add(7);
                        counter := 0; -- it will be 1 first in next state
                    end if;
                    
                end if;
            when write_dev_add_W =>
                SCL <= clk100kHz;
                if falling_edge(clk100kHz) and counter < 7 then --
                    SDA <= dev_add(7 - counter);
                elsif falling_edge(clk100kHz) and counter = 7 then  
                    SDA <= '0'; -- Write!
                elsif rising_edge(clk100kHz) and counter >= 8 then
                    ACK_bit <= SDA; -- Read sensor sending ack bit.
                    state <= write_MSB_add;
                    counter := 0;
                end if;
            when write_MSB_add =>
                SCL <= clk100kHz;
                if falling_edge(clk100kHz) and counter < 8 then
                    SDA <= MSB_add(8 - counter); -- Counter will start at 1
                elsif rising_edge(clk100kHz) and counter >= 8 then
                    ACK_bit <= SDA; -- Read ack bit
                    state <= repeat_start;
                    counter := 0;
                end if;
            when repeat_start => -- Make a new falling flank on SDA when SCL is high
                -- SCL will stay high from last and clk will be falling edge
                if falling_edge(clk100kHz) then 
                    SDA <= '1';
                elsif rising_edge(clk100kHz) then
                    SDA <= '0';    
                    state <= write_dev_add_R;
                    counter := 0;
                end if;
            when write_dev_add_R =>
                SCL <= clk100kHz;
                if falling_edge(clk100kHz) and counter < 8 then
                    SDA <= dev_add(8 - counter);
                elsif falling_edge(clk100kHz) and counter = 8 then
                    SDA <= '1'; -- READ
                elsif rising_edge(clk100kHz) and counter >8 then
                    ACK_bit <= SDA;
                    state <= read_MSB_data;
                    counter := 0;
                end if;
            when read_MSB_data =>
                SCL <= clk100kHz;
                if rising_edge(clk100kHz) and counter < 9 then
                    data_reg(16 - counter) <= SDA;
                elsif falling_edge(clk100kHz) and counter >= 9 then
                    ACK_bit <= SDA;
                    state <= read_LSB_data;
                    counter := 0;
                end if;
            when read_LSB_data =>
                SCL <= clk100kHz;
                if rising_edge(clk100kHz) and counter < 9 then
                    data_reg(8 - counter) <= SDA;
                elsif falling_edge(clk100kHz) and counter >= 9 then
                    SDA <= '1'; -- Set ack by master. 
                    state <= wait_for_start;
                    counter :=0;
                    
                end if;

            when others =>
        end case;

    end process read_proc;
    
    
    
end architecture behave;