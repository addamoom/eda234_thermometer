-- W433_interface.vhdl
-- 
-- This module detects and stores a message received from a AM-HRR30 receiver
-- 
-- Signal protocol is as follows: 
--      Bits are transmitted with no delay between each other, each 1 ms long
--      The transaction is initialized by sending a 1.
--      The one is followed by a key, that is used to filter out transmissions and noise on the 433Mhz band not meant for this device
--      The key is 4 bits long, set to "1101"
--      After the key the 20 bit message is received. message has the form: "sddd.dd" s - sign, d - 4 bit digit, . just signifies whre to put the . in the final number
--      A typical transmission may therefore look something like this:
--      "11101000000000000000100000"
--       |start bit
--        |  |key
--            |              |message
--            
-- T
--     
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY W433_interface IS
    PORT (
        Clk_10us    : IN STD_LOGIC;         -- 100 khz clock
        Reset_n     : IN STD_LOGIC;         -- Active low reset
        get_sample  : IN STD_LOGIC;         -- Not currently in use, placeholder for later
        data_in     : IN STD_LOGIC;         -- 433 receeiver data pin
        Temp_out    : OUT STD_LOGIC_VECTOR(20 DOWNTO 0); --Latest received temperature
        sample_done : OUT STD_LOGIC         -- Is low when the sensor is receiving a new sample, will be used later with get_sample
    );
END W433_interface;
ARCHITECTURE ett OF W433_interface IS

    SIGNAL clock_counter : INTEGER RANGE 0 TO 1023;
    SIGNAL bit_counter : INTEGER RANGE 0 TO 25;
    TYPE Receiver_states IS (wait_for_start, wait_1_ms, Receive_bit, delay_for_skew,wait_for_zero);
    SIGNAL Receiver_state : Receiver_states;
    SIGNAL temp_reg       : STD_LOGIC_VECTOR(20 DOWNTO 0);
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
                WHEN wait_for_zero => --We want to find a positive edge, so first we have to wait for zero
                IF data_in = '0' THEN
                    Receiver_state <= wait_for_start;
                    bit_counter    <= 0;
                    clock_counter  <= 0;
                END IF;
                WHEN wait_for_start => --Find a high edge of the data pin
                    IF data_in = '1' THEN
                        Receiver_state <= delay_for_skew;
                        sample_done    <= '0';
                    END IF;
                WHEN delay_for_skew => -- Wait a few cycles so that we are not right on the edge of the transmission, to protect against skew.
                    clock_counter <= clock_counter + 1;
                    IF clock_counter = 10 THEN
                        Receiver_state <= wait_1_ms;
                        clock_counter  <= 0;
                    END IF;
                WHEN wait_1_ms => -- Wait 1 ms for the next bit
                    clock_counter <= clock_counter + 1;
                    IF clock_counter = 100 THEN
                        Receiver_state <= Receive_bit;
                        clock_counter  <= 0;
                    END IF;
                WHEN Receive_bit =>      -- Store a bit into the appropriate register and goto the wait state again
                    IF bit_counter = 25 THEN                -- Transmission over
                        Receiver_state <= wait_for_zero;
                        sample_done    <= '1';
                        Temp_out       <= temp_reg;
                    ELSE                                    -- Transmission still active
                        IF bit_counter < 4 THEN                    --the first 4 bits is the key
                            key_reg(3-bit_counter) <= data_in;
                            Receiver_state            <= wait_1_ms;
                            IF (bit_counter = 3) and ((key_reg(3 downto 1) & data_in ) /= PSK) THEN
                                Receiver_state <= wait_for_zero;   
                            END IF;
                        ELSE -- received bit 4 - 19 is the 16 bit message
                            temp_reg(24-bit_counter) <= data_in;
                            Receiver_state            <= wait_1_ms;
                        END IF;
                        bit_counter               <= bit_counter + 1;
                    END IF;
            END CASE;
        END IF;
    END PROCESS;
END ett;