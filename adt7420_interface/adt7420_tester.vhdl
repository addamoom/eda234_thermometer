LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY adt7420_tester IS
	PORT (
	BTNU      : IN STD_LOGIC;                    -- Button used as reset
	BTNC      : IN STD_LOGIC;                    -- Button used as sample starter
    CLK100MHZ : IN STD_LOGIC;                    -- Clock input
	LED	: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
	TMP_SCL : OUT STD_LOGIC;
	TMP_SDA : INOUT STD_LOGIC;
	JA1 : OUT STD_LOGIC;
	JA2 : OUT STD_LOGIC
	);
END adt7420_tester;

ARCHITECTURE ett OF adt7420_tester IS
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
	SIGNAL reset_n: STD_LOGIC;
	SIGNAL SDA, SCL : STD_LOGIC;
BEGIN
	DUT : COMPONENT ADT7420 PORT MAP(
	clk        => CLK100MHZ,
	reset_n    => reset_n,
	temp       => LED,       
	sample_temp=> BTNC,
	sample_done=> OPEN,
	ADT7420_SDA=> SDA,
	ADT7420_SCL=> SCL
	);
	-- Use BTNU as the reset signal
    reset_n <= NOT BTNU;
	JA1 <= SCL;
	TMP_SCL <= SCL;
	JA2 <=  SDA;
	TMP_SDA <= SDA;
	
	
END;

	