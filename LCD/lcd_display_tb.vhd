LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY lcd_display_tb IS

END lcd_display_tb;

ARCHITECTURE arc_lcd_display_tb OF lcd_display_tb IS
  COMPONENT LCD_DISPLAY_nty IS

   
   PORT( 
      reset              : IN     std_logic; 
      clk              : IN     std_logic;  -- Using the DE2 50Mhz Clk, in order to Genreate the 400Hz signal... clk_count_400hz reset count value must be set to:  <= x"0F424" (62500)   x"07A12"--- (31250) for 100Mhz 
      temp_dec_in        : IN     STD_LOGIC_VECTOR (20 downto 0);

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
   SIGNAL temp_dec_in_signal: STD_LOGIC_VECTOR (20 downto 0):=(others => '0');

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
                  temp_dec_in => temp_dec_in_signal,
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
   temp_dec_in_signal <= "000010010001101000101",
                         "000100011010001010110" AFTER 1000ns;

   clk_proc:
   PROCESS
   BEGIN
     WAIT FOR 5 ns;
     clk_tb_signal <=NOT(clk_tb_signal);
     END PROCESS clk_proc;



END arc_lcd_display_tb;
