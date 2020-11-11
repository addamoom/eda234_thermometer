LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY ds18s20_interface IS
PORT (
    clk_10us     : IN STD_LOGIC; -- 10 us clock
    reset_n : IN STD_LOGIC;
    temperature_data: OUT STD_LOGIC_VECTOR(7 DOWNTO 0) -- see table 1 in data sheet for what it means
    sensor_line : INOUT STD_LOGIC;
);
END;

ARCHITECTURE ett OF ds18s20_interface IS
    SIGNAL counter          : INTEGER RANGE 0 TO 100;
    TYPE state_type IS (); 
    SIGNAL state : state_type;
BEGIN
    --Master issues reset, pulls buss low for minimum of 480 us then releases it
    --ds18s20 responds with presence pulse, pulling the bus low for 60-240 us and then releasing it, 
    --Master can detect the bus going high again and then issue a ROM command
    --  We want to issue Skip ROM [CCh] (11001100b) since there is only one ds18s20 on the bus
    -- THen we want to send a Convert T [44h] (01000100b)
    --Now we repeat init phase, Master issues reset pulse, ds18s20 responds and master detects that
    -- Again we issue Skip ROM [CCh] (11001100b). should probably make a procedure of that
    -- Master issues Read Scratchpad [BEh] (10111110)
    --  Only need to recive the first 2 bytes, then just leave the ds18s20 hanging, do not send reset
    
    --Init procedure in detail: 
    --Master pull buss low for minimum of 480 us then release it (Z it). 
    --  This will make it high due to pullup resistor  
    -- ds18s20 responds with presence pulse, pulling the bus low for 60-240 us and then releasing it, 
    
    main_fsm : PROCESS (clk_10us, reset_n,sensor_line) IS
    BEGIN
        IF (reset_n = '0') THEN
            counter = 0;
            sensor_line <= 'Z';
        ELSE
            IF rising_edge(clk_10us) THEN
                CASE state IS
                WHEN first_init => --holds sensor_line high for ~500 us
                    if counter = 50 Then 
                        sensor_line <= 'Z';
                        state <= wait_for_precence_low;
                        counter <= 0;
                    else
                        sensor_line <= '0'
                        counter <= counter + 1;
                    end if;
                WHEN wait_for_precence_low  =>
                    if sensor_line = '0' then
                        state <= wait_for_precence_high;
                    end if;
                WHEN wait_for_precence_high  =>
                    if sensor_line = '1' then
                        state <= first_skip_rom_1;
                    end if;
                WHEN first_skip_rom_1  =>     -- transmitt 1100 with LSB first
                    counter <= counter + 1;
                    if counter = 0 then         -- begin transmit a zero 
                        sensor_line <= '0';
                    elsif counter = 10 then     --stop zero transmission
                        sensor_line <= 'Z';
                    elsif counter = 11 then     --begin transmit a zero
                        sensor_line <= '0';
                    elsif counter = 21 then     --stop zero transmission
                        sensor_line <= 'Z';
                    elsif counter = 22 then     --begin transmit a one
                        sensor_line <= '0';
                    elsif counter = 23 then     -- stop one transmission
                        sensor_line <= 'Z';
                    elsif counter = 29 then     -- begin transmit a one
                        sensor_line <= '0';
                    elsif counter = 30 then     -- stop one transmission and proceed to phase 2
                        sensor_line <= '0';
                        state <= first_skip_rom_2;   
                        counter = 0;
                    end if;
                WHEN first_skip_rom_2  =>     -- transmitt 1100 again with LSB first
                    counter <= counter + 1;
                    if counter = 0 then         -- begin transmit a zero 
                        sensor_line <= '0';
                    elsif counter = 10 then     --stop zero transmission
                        sensor_line <= 'Z';
                    elsif counter = 11 then     --begin transmit a zero
                        sensor_line <= '0';
                    elsif counter = 21 then     --stop zero transmission
                        sensor_line <= 'Z';
                    elsif counter = 22 then     --begin transmit a one
                        sensor_line <= '0';
                    elsif counter = 23 then     -- stop one transmission
                        sensor_line <= 'Z';
                    elsif counter = 29 then     -- begin transmit a one
                        sensor_line <= '0';
                    elsif counter = 30 then     -- stop one transmission and proceed to phase 2
                        sensor_line <= '0';
                        state <= first_skip_rom_2;           
                    end if;
                WHEN convert_t_1  =>     -- transmitt 0100 with LSB first
                    if counter = 0 then         -- begin transmit a zero 
                        sensor_line <= '0';
                    elsif counter = 10 then     --stop zero transmission
                        sensor_line <= 'Z';
                    elsif counter = 11 then     --begin transmit a zero
                        sensor_line <= '0';
                    elsif counter = 21 then     --stop zero transmission
                        sensor_line <= 'Z';
                    elsif counter = 22 then     --begin transmit a zero
                        sensor_line <= '0';
                    elsif counter = 32 then     --stop zero transmission
                        sensor_line <= 'Z';
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;


--procedure skip_rom(signal counter: INOUT integer
--                   signal sensor_line:)
--begin
--    CASE skip_rom_state  IS
--        WHEN b_zero =>
--            transmit_one();
--        WHEN b_one =>
--            transmit_one();
--        WHEN b_two =>
--            transmit_zero();
--        WHEN three =>
--            transmit_zero();
--        WHEN four =>
--            transmit_one();
--        WHEN five =>
--            transmit_one();
--        WHEN six =>
--            transmit_zero();
--        WHEN seven =>
--            transmit_zero();
--    end case;   
--end skip_rom;
--
--procedure transmit_one
--begin
--    if counter = x
        