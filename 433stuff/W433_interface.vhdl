-- W433_interface.vhdl
-- 
-- This module detects and stores a message received from a AM-HRR30 receiver
-- 
-- Signal protocol is as follows: 
--      Bits are transmitted with no delay between eacthother, each 10 ms long
--      The transacition is initialized by sending a 1.
--      The one is followed by a key, that is used to filter out transmissions and noise on the 433Mhz band not meant for this device
--      The key is 4 bits long, set to "1101"
--      After the key the 16 bit message is received.
--      A typical transmission may therefore look something like this:
--      "111010000000000000001"
--       |start bit
--        |  |key
--            |              |message
--            
-- The message is  expected to be a 16 bit 2 complement integer representing the current temperature
--     
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
    SIGNAL bit_counter : INTEGER RANGE 0 TO 20;
    TYPE Receiver_states IS (wait_for_start, wait_10_ms, Receive_bit, delay_for_skew,wait_for_zero);
    SIGNAL Receiver_state : Receiver_states;
    SIGNAL temp_reg       : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL key_reg        : STD_LOGIC_VECTOR(3 DOWNTO 0);
    CONSTANT PSK          : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1101";
BEGIN

    receiver : PROCESS (Clk_10us, Reset_n)
    BEGIN
        IF reset_n = '0' THEN
            bit_counter    <= 0;
            clock_counter  <= 0;
            Receiver_state <= wait_for_zero;
        ELSIF rising_edge(Clk_10us) THEN
            CASE Receiver_state IS
                WHEN wait_for_zero => --We want to find a posetive edge, so first we have to wait for zero
                IF data_in = '0' THEN
                    Receiver_state <= wait_for_start;
                END IF;
                WHEN wait_for_start => --Find a high edge of the data pin
                    IF data_in = '1' THEN
                        Receiver_state <= delay_for_skew;
                    END IF;
                WHEN delay_for_skew => -- Wait a few cycles so that we are not right on the edge of the transmission, to protect against skew.
                    clock_counter <= clock_counter + 1;
                    IF clock_counter = 100 THEN
                        Receiver_state <= wait_10_ms;
                        clock_counter  <= 0;
                    END IF;
                WHEN wait_10_ms => -- Wait 10 ms for the next bit
                    clock_counter <= clock_counter + 1;
                    IF clock_counter = 1000 THEN
                        Receiver_state <= Receive_bit;
                        clock_counter  <= 0;
                    END IF;
                WHEN Receive_bit =>      -- Store a bit into the appropriate register and goto the wait state again
                    IF bit_counter = 20 THEN                -- Transmission over
                        Receiver_state <= wait_for_start;
                        bit_counter    <= 0;
                        clock_counter  <= 0;
                        sample_done    <= '1';
                        Temp_out       <= temp_reg;
                    ELSE                                    -- Transmission still active
                        IF bit_counter < 4 THEN                    --the first 4 bits is the key
                            key_reg <= key_reg(2 DOWNTO 0) & data_in;
                            Receiver_state            <= wait_10_ms;
                            IF (bit_counter = 3) and ((data_in & key_reg(2 downto 0)) /= PSK) THEN
                                Receiver_state <= wait_for_start;
                            END IF;
                        ELSE -- recived bit 4 - 19 is the 16 bit message
                            temp_reg(19-bit_counter) <= data_in;
                            Receiver_state            <= wait_10_ms;
                        END IF;
                        bit_counter               <= bit_counter + 1;
                    END IF;
            END CASE;
        END IF;
    END PROCESS;
END ett;