LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY adt7420_tb IS

END adt7420_tb;

ARCHITECTURE ett OF adt7420_tb IS
	COMPONENT adt7420 IS
	PORT (
		clk     : IN STD_LOGIC; 
		reset_n : IN STD_LOGIC;
		temp: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		sample_temp: IN STD_LOGIC;
		sample_done: OUT STD_LOGIC;
		ADT7420_SDA : INOUT STD_LOGIC;
		ADT7420_SCL : OUT STD_LOGIC
	);
	END COMPONENT;
	SIGNAL tb_clk : STD_LOGIC := '0';
	signal tb_ADT7420_SDA: STD_LOGIC := 'Z';
	SIGNAL tb_reset_n,tb_sample_temp,tb_sample_done,tb_ADT7420_SCL: STD_LOGIC;
	SIGNAL tb_temp : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN
	DUT : COMPONENT ADT7420 PORT MAP(
	clk        => tb_clk,
	reset_n    => tb_reset_n,
	temp       => tb_temp,       
	sample_temp=> tb_sample_temp,
	sample_done=> tb_sample_done,
	ADT7420_SDA=> tb_ADT7420_SDA,
	ADT7420_SCL=> tb_ADT7420_SCL
	);
	
	    tb_reset_n <= '0',
        '1' AFTER 100 ns;
		tb_sample_temp <= '0',
        '1' AFTER 200 ns;
		
	clk_proc : PROCESS
	BEGIN
        WAIT FOR 50 ns;
        tb_clk <= NOT(tb_clk);
    END PROCESS clk_proc;
	
	 test_proc:
    PROCESS
    BEGIN
    --Start
       WAIT FOR 360 ns; -- First slave address bit should now be on bus
       ASSERT tb_ADT7420_SDA = '1'
       REPORT "First slave address wrong"
       SEVERITY ERROR;
	   
	   WAIT FOR 100 ns; -- Second slave address bit should now be on bus
       ASSERT tb_ADT7420_SDA = '0'
       REPORT "Second slave address wrong"
       SEVERITY ERROR;
	   
	   WAIT FOR 600 ns; -- RW bit should now be on bus
       ASSERT tb_ADT7420_SDA = '1'
       REPORT "RW Bit wrong"
       SEVERITY ERROR;
	   
	   WAIT FOR 100 ns; -- Bus should be released
	   
	   WAIT FOR 50 ns; -- make all MSBs one
	   tb_ADT7420_SDA <= '1';
	   
	   WAIT FOR 800 ns; -- make all LSBs zero
	   tb_ADT7420_SDA <= '0';
	   
	   WAIT FOR 1000 ns; -- wait until transfer done
	   ASSERT tb_temp =  "1111111100000000"
       REPORT "Temp wrong"
       SEVERITY ERROR;
	END PROCESS;
	   
END;

	