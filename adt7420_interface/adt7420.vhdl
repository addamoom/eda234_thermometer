LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY adt7420 IS
PORT (
    clk     : IN STD_LOGIC; --100MHZ clock
    reset_n : IN STD_LOGIC;
    temp: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
	sample_temp: IN STD_LOGIC;
	sample_done: OUT STD_LOGIC;
    ADT7420_SDA : INOUT STD_LOGIC;
	ADT7420_SCL : OUT STD_LOGIC
);
END;

ARCHITECTURE ett OF adt7420 IS
	COMPONENT freq_divisor IS
        GENERIC (N : INTEGER := 10);
        PORT (
            clk     : IN STD_LOGIC;
            reset_n : IN STD_LOGIC;
            clk_out : OUT STD_LOGIC
        );
    END COMPONENT freq_divisor;
    SIGNAL counter          : INTEGER RANGE 0 TO 100;
    TYPE state_type IS (wait_for_start_signal,send_slave_address,change_to_receive,receive_MSBs,receive_LSBs,output_temp,start_condition); 
    SIGNAL state : state_type;
	signal clk_100khz,clk_hold: STD_LOGIC;
	signal MSBs_reg, LSBs_reg: STD_LOGIC_VECTOR(7 DOWNTO 0);
	constant slave_address: STD_LOGIC_VECTOR(6 DOWNTO 0) := "1101001";
BEGIN


 --generate 100khz clock
 --d100khz : freq_divisor GENERIC MAP(N => 10000) --1000 on actual hardware, 1 for simulation with testbench 
 --   PORT MAP
 --   (
 --       clk     => clk,
 --       reset_n => reset_n,
 --       clk_out => clk_100khz
 --   );
    clk_100khz <= clk; --for simulation
	
 --send that to sensor
	ADT7420_SCL <= clk_100khz when clk_hold = '0' else '1';
	
    main_fsm : PROCESS (clk_100khz, reset_n,sample_temp) IS
    BEGIN
        IF (reset_n = '0') THEN
            counter <= 0;
	        clk_hold <= '0';
            ADT7420_SDA <= '1';
			state <= wait_for_start_signal;
			sample_done <= '0';
			
        ELSE
            IF rising_edge(clk_100khz) THEN
                CASE state IS
					WHEN wait_for_start_signal => 
						sample_done <= '0';
						if(sample_temp = '1') then
							state <= start_condition;
							clk_hold <= '1';
						end if;
					WHEN start_condition => 
						clk_hold <= '0';
						ADT7420_SDA <= '0'; --sda goes low while scl high
						state <= send_slave_address;
					WHEN send_slave_address => --send 0x4B and then a one to indicate W 
						if counter /= 7 then
							ADT7420_SDA <= slave_address(counter);
							counter <= counter + 1; 
						else
							counter <= 0;
							ADT7420_SDA <= '1';
							state <= change_to_receive;
						end if;
					WHEN change_to_receive => -- waste one cycle for adt ack and release bus
						ADT7420_SDA <= 'Z';
						state <= receive_MSBs;
					WHEN receive_MSBs =>
						counter <= counter + 1;
						MSBs_reg <= MSBs_reg(6 DOWNTO 0) & ADT7420_SDA;
						if counter = 7 then
							state <= receive_LSBs;
							counter <= 0;
						end if;
					WHEN receive_LSBs =>
						counter <= counter + 1;
						LSBs_reg <= LSBs_reg(6 DOWNTO 0) & ADT7420_SDA;
						if counter = 8 then --we go one further since there should be one cycle empty first
							state <= output_temp;
							counter <= 0;
						end if;
					WHEN output_temp =>
						temp <= MSBs_reg & LSBs_reg;
						sample_done <= '1';
						state <= wait_for_start_signal;
						ADT7420_SDA <= '1';
				END CASE;
			end IF;
		end if;
	END PROCESS;
	
END;			
