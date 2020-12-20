LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY max_min_tb IS

END max_min_tb;

ARCHITECTURE arch OF max_min_tb IS
  COMPONENT LCD_DISPLAY_nty IS

   
   PORT( 
      reset              : IN     std_logic; 
      clk                : IN     std_logic;  -- Using the DE2 50Mhz Clk, in order to Genreate the 400Hz signal... clk_count_400hz reset count value must be set to:  <= x"0F424" (62500)   x"07A12"--- (31250) for 100Mhz 
      input_d            : IN     STD_LOGIC_VECTOR (20 downto 0);
      switch_1           : IN     std_logic;

      lcd_rs             : OUT    std_logic;
      lcd_e              : OUT    std_logic;
      lcd_rw             : OUT    std_logic;      
      
      data_bus_0         : INOUT  STD_LOGIC;
      data_bus_1         : INOUT  STD_LOGIC;
      data_bus_2         : INOUT  STD_LOGIC;
      data_bus_3         : INOUT  STD_LOGIC;
      data_bus_4         : INOUT  STD_LOGIC;
      data_bus_5         : INOUT  STD_LOGIC;
      data_bus_6         : INOUT  STD_LOGIC;
      data_bus_7         : INOUT  STD_LOGIC                
   );
  END COMPONENT LCD_DISPLAY_nty;

   SIGNAL clk_tb_signal:STD_LOGIC:='0';
   SIGNAL reset_tb_signal:STD_LOGIC:='0';
   SIGNAL input_d_signal: STD_LOGIC_VECTOR (20 downto 0):=(others => '0');
   SIGNAL switch_1_signal:STD_LOGIC:='0';
   SIGNAL lcd_rs_tb_signal:STD_LOGIC:='0';
   SIGNAL lcd_e_tb_signal:STD_LOGIC:='0';
   SIGNAL lcd_rw_tb_signal:STD_LOGIC:='0';

   SIGNAL data_bus_0_tb_signal:STD_LOGIC:='0';
   SIGNAL data_bus_1_tb_signal:STD_LOGIC:='0';
   SIGNAL data_bus_2_tb_signal:STD_LOGIC:='0';
   SIGNAL data_bus_3_tb_signal:STD_LOGIC:='0';
   SIGNAL data_bus_4_tb_signal:STD_LOGIC:='0';
   SIGNAL data_bus_5_tb_signal:STD_LOGIC:='0';
   SIGNAL data_bus_6_tb_signal:STD_LOGIC:='0';
   SIGNAL data_bus_7_tb_signal:STD_LOGIC:='0';


BEGIN
   lcd_display_comp:
   COMPONENT LCD_DISPLAY_nty
	PORT MAP(
		  clk =>clk_tb_signal,
		  reset =>reset_tb_signal,
                  input_d => input_d_signal,
		  switch_1=>switch_1_signal,
		  lcd_rs =>lcd_rs_tb_signal,
		  lcd_e =>lcd_e_tb_signal,
		  lcd_rw =>lcd_rw_tb_signal,
		  data_bus_0 =>data_bus_0_tb_signal,
		  data_bus_1 =>data_bus_1_tb_signal,
		  data_bus_2 =>data_bus_2_tb_signal,
		  data_bus_3 =>data_bus_3_tb_signal,
		  data_bus_4 =>data_bus_4_tb_signal,
		  data_bus_5 =>data_bus_5_tb_signal,
		  data_bus_6 =>data_bus_6_tb_signal,
		  data_bus_7 =>data_bus_7_tb_signal);

   reset_tb_signal <='0',
		     '1' AFTER 100 ns;

   switch_1_signal <='1';
--   input_d_signal <= "000000000000000000000",  ---0
--                       "000000000000000000001" after 120 ns,  --- +000.01
--                       "000000001000100100001" after 210 ns,  --- +011.21
--                       "100110011001100001001" after 340 ns,  --- -33.09
--                       "000000101000100100001" after 540 ns,  --- +051.21
--                       "000000011000100100001" after 740 ns,  --- +031.21
--                       "101010101001100001001" after 940 ns,  --- -53.09
--                       "101010010001100001001" after 1140 ns,  --- -23.09
--                       "000000100000100100001" after 1340 ns,  --- +041.21
--                       "101010100001100001001" after 1540 ns;  --- -43.09

input_d_signal <= "000000010001000110001",               --- +022.31
		  "000000010000100100001" after 120 ns,  --- +021.21
		  "000000010001100110001" after 220 ns,  --- +023.31
		  "000000010010001010001" after 320 ns,  --- +024.51
		  "000000011000000110001" after 420 ns,  --- +030.31
		  "100000011000000010001" after 520 ns,  --- -030.11
		  "000000011000101100001" after 620 ns,  --- +031.61
		  "000000011000000110001" after 720 ns,  --- +030.31
		  "000000011001001110001" after 820 ns,  --- +032.71
		  "100000001000000010001" after 920 ns,  --- -010.11
		  "000000010000100100001" after 1020 ns,  --- +021.21
		  "000000010001100010001" after 1120 ns,  --- +023.11
		  "000000010000000000001" after 1220 ns;  --- +020.01
   clk_proc:
   PROCESS
   BEGIN
     WAIT FOR 5 ns;
     clk_tb_signal <=NOT(clk_tb_signal);
     END PROCESS clk_proc;



END arch;
