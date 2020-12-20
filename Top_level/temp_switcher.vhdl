-- This component debounces a button press and uses it to
-- to toggle between outputting one of the two inputs.

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY temp_switcher IS
    PORT (
        Clk              : IN STD_LOGIC;                      -- 100 khz clock
        Reset_n          : IN STD_LOGIC;                      -- Active low reset
        interal_temp_in  : IN STD_LOGIC_VECTOR(20 DOWNTO 0);  -- 
        External_temp_in : IN STD_LOGIC_VECTOR(20 DOWNTO 0);  --
        Toggle           : IN STD_LOGIC;                      -- switch output between the two inputs
        Temp_to_lcd      : OUT STD_LOGIC_VECTOR(20 DOWNTO 0)  -- Temperature output to lcd
    );

END temp_switcher;

ARCHITECTURE ett OF temp_switcher IS
    SIGNAL debounce_counter : INTEGER RANGE 0 TO 2000001; -- Probably ugly to use such a huge counter, but it was quick
    SIGNAL internal_toggle, wait_for_debounce : STD_LOGIC;
BEGIN
    proc_name : PROCESS (Clk, Reset_n)
    BEGIN
        IF Reset_n = '0' THEN
            internal_toggle  <= '0';
            debounce_counter <= 0;
        ELSIF rising_edge(Clk) THEN
            IF wait_for_debounce = '1' THEN
                debounce_counter <= debounce_counter + 1;
                IF debounce_counter = 2000000 THEN -- change to 2000000 in hardware
                    wait_for_debounce <= '0';
                    debounce_counter  <= 0;
                END IF;
            ELSE
                IF Toggle = '1' then
                    wait_for_debounce <= '1';
                    internal_toggle <= NOT internal_toggle;
                end if;
            END IF;
        END IF;
    END PROCESS proc_name;

    Temp_to_lcd <= interal_temp_in when internal_toggle = '0' else External_temp_in;
END;