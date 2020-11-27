-- Takes 100MHZ clock as input and uses it to find a positive edge on the wireless receiver 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY W433_interface IS
    PORT (
        Clk_10us    : IN STD_LOGIC;
        Reset_n     : IN STD_LOGIC;
        get_sample  : IN STD_LOGIC;
        data_in     : IN STD_LOGIC;
        Temp_out    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        sample_done : OUT STD_LOGIC
    );
END W433_interface;
ARCHITECTURE ett OF W433_interface IS
    SIGNAL clock_counter : INTEGER RANGE 0 TO 1023;
    SIGNAL bit_counter   : INTEGER RANGE 0 TO 16;
    TYPE Receiver_states IS (wait_for_start, wait_10_ns, Receive_bit);
    SIGNAL Receiver_state : Receiver_states;
    SIGNAL temp_reg       : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN

    receiver : PROCESS (Clk_10us, Reset_n)
    BEGIN
        IF reset_n = '0' THEN
            bit_counter    <= 0;
            clock_counter  <= 0;
            Receiver_state <= wait_for_start;
        ELSIF rising_edge(Clk_10us) THEN
            CASE Receiver_state IS
                WHEN wait_for_start => --might need to add noise protection with a start sequence instead of this
                    IF data_in = '1' THEN
                        Receiver_state <= wait_10_ns;
                    END IF;
                WHEN wait_10_ns =>
                    clock_counter <= clock_counter + 1;
                    IF clock_counter = 1000 THEN
                        Receiver_state <= Receive_bit;
                        clock_counter  <= 0;
                    END IF;
                WHEN Receive_bit =>
                    IF bit_counter = 16 THEN
                        Receiver_state <= wait_for_start;
                        bit_counter    <= 0;
                        clock_counter  <= 0;
                        sample_done <= '1';
                        Temp_out <= temp_reg;
                    ELSE
                        IF clock_counter < 50 THEN --try to find a 1 for 500us
                            IF data_in = '1' THEN
                                temp_reg(bit_counter) <= '1';
                                bit_counter <= bit_counter + 1;
                                clock_counter         <= 0;
                                Receiver_state        <= wait_10_ns;
                            ELSE
                                clock_counter <= clock_counter + 1;
                            END IF;
                        ELSE --no 1 found, interpret as a 0 and move on
                            temp_reg(bit_counter) <= '0';
                            bit_counter <= bit_counter + 1;
                            clock_counter         <= 0;
                            Receiver_state        <= wait_10_ns;
                        END IF;
                    END IF;
            END CASE;
        END IF;
    END PROCESS;
END ett;