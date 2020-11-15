LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY freq_divisor IS
    GENERIC
        (N : INTEGER := 10);
    PORT (
        clk     : IN STD_LOGIC;
        reset_n : IN STD_LOGIC;
        clk_out : OUT STD_LOGIC
    );
END freq_divisor;


ARCHITECTURE ett OF freq_divisor IS
    SIGNAL counter : INTEGER RANGE 0 TO N;
BEGIN
    a : PROCESS (clk, reset_n)
    BEGIN
        IF (reset_n = '0') THEN
            counter <= 0;
            clk_out <= '0';
        ELSIF (rising_edge(clk)) THEN
            IF counter = N - 1 THEN
                counter <= 0;
            ELSE
                counter <= counter + 1;
            END IF;
            IF counter = 0 THEN
                clk_out <= '1';
            ELSE
                clk_out <= '0';
            END IF;
        END IF;
    END PROCESS;
END ett;