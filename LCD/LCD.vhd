----------------------------------------------------------------------------------------
-- function: to display the current temp, and can be switched to display max/min temp---
----------------------------------------------------------------------------------------

LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;


ENTITY LCD_DISPLAY_nty IS
  generic(N: NATURAL :=4);   
   PORT( 
      reset              : IN     std_logic;  
      clk                : IN     std_logic;             -- to Genreate the 400Hz signal, clk_count_400hz reset count value: x"0F424" (62500)   x"1E848"--- (125000), x"3D090" ---(250000) for 100Mhz 
      input_d            : IN     std_logic_vector(20 downto 0);              -- input temp data
      switch_1           : IN     std_logic;             --when switch_1 = 1, display the max/min temp

      lcd_rs             : OUT    std_logic;
      lcd_e              : OUT    std_logic;
      lcd_rw             : OUT    std_logic;   
      
      
      no_veto            : in     std_logic;             -- enable signal from sensor_to_chip, that is turned off during copying state for a fraction of LCD clock cycle
      copy               : out    std_logic;             -- control signal to sensor_to_chip, enable the sensor_to_chip to process next signal
      
      data_bus_0         : INOUT  STD_LOGIC;             --output databus
      data_bus_1         : INOUT  STD_LOGIC;
      data_bus_2         : INOUT  STD_LOGIC;
      data_bus_3         : INOUT  STD_LOGIC;
      data_bus_4         : INOUT  STD_LOGIC;
      data_bus_5         : INOUT  STD_LOGIC;
      data_bus_6         : INOUT  STD_LOGIC;
      data_bus_7         : INOUT  STD_LOGIC                
   );

-- Declarations

END LCD_DISPLAY_nty ;

ARCHITECTURE LCD_DISPLAY_arch OF LCD_DISPLAY_nty IS
  type character_string is array ( 0 to 15 ) of STD_LOGIC_VECTOR( 7 downto 0 );
  type input_digit is array ( 0 to 4 ) of STD_LOGIC_VECTOR( 3 downto 0 );
  type output_ascii is array ( 0 to 4 ) of STD_LOGIC_VECTOR( 7 downto 0 );

  type state_type is (hold, func_set, display_on, mode_set, print_string,
                      line2, return_home, drop_lcd_e, reset1, reset2,
                       reset3, display_off, display_clear);
                       
  signal state, next_command         : state_type;  
  signal temp_digit_decimal          : input_digit;
  signal temp_digit_decimal_max      : input_digit;
  signal temp_digit_decimal_min      : input_digit;
  signal temp_digit_ascii            : output_ascii;
  signal temp_digit_ascii_max        : output_ascii;
  signal temp_digit_ascii_min        : output_ascii;
  signal lcd_display_string_01       : character_string; 
  signal lcd_display_string_02       : character_string; 
  signal sign_ascii                  : std_logic_vector(7 downto 0);
  signal data_bus_value, next_char   : STD_LOGIC_VECTOR(7 downto 0);
  signal clk_count_400hz             : STD_LOGIC_VECTOR(19 downto 0); 
  signal char_count                  : STD_LOGIC_VECTOR(3 downto 0);--16 characters totally, 4bits
  signal clk_400hz_enable,lcd_rw_int : std_logic; 
  signal data_bus                    : STD_LOGIC_VECTOR(7 downto 0);
  signal input_d_signal              : std_logic_vector(20 downto 0);	
  
  signal temp_max					 : std_logic_vector(20 downto 0):= "101011001100100010000";    --  -599.10 temp as the initial value for max register
  signal temp_min					 : std_logic_vector(20 downto 0):= "001011001100100010000";    --  +599.10 temp as the initial value for max register
  
 
  signal flag_max					 : std_logic:='0';                             -- when flag is 1, then we update the max temp data
  signal flag_min					 : std_logic:='0';                             -- when flag is 1, then we update the min temp data
  
  signal sign_ascii_max              : std_logic_vector(7 downto 0);               -- ascii format data of max temp's sign bit
  signal sign_ascii_min              : std_logic_vector(7 downto 0);               -- ascii format data of min temp's sign bit

  

  
  
  COMPONENT decimal_2_ascii IS                                                     -- convert decimal to ascii
   port( 
         input_d : in std_logic_vector(3 downto 0);
             clk : in std_logic;
        output_a : out std_logic_vector(7 downto 0));
  END COMPONENT decimal_2_ascii;


  COMPONENT get_max IS                                                             -- compare current value with max register, if current > max register, then set flag_max = 1
   port(
	clk: in std_logic;
	max_register :in std_logic_vector(20 downto 0);
	current_data :in std_logic_vector(20 downto 0);
	flag_max:out std_logic);
  END COMPONENT get_max ;

  COMPONENT get_min IS                                                             -- compare current value with min register, if current < min register, then set flag_min = 1
   port(
	clk: in std_logic;
	min_register :in std_logic_vector(20 downto 0);
	current_data_min :in std_logic_vector(20 downto 0);
	flag_min:out std_logic);
  END COMPONENT get_min ;



  COMPONENT decimal_2_ascii_max IS                                                -- convert max temp data from decimal to ascii
   port( 
         input_d : in std_logic_vector(3 downto 0);
             clk : in std_logic;
        output_a : out std_logic_vector(7 downto 0));
  END COMPONENT decimal_2_ascii_max;

  COMPONENT decimal_2_ascii_min IS                                                -- convert min temp data from decimal to ascii
   port( 
         input_d : in std_logic_vector(3 downto 0);
             clk : in std_logic;
        output_a : out std_logic_vector(7 downto 0));
  END COMPONENT decimal_2_ascii_min;




BEGIN
  
--===================================================--  
-- compare input data and save the lagest and smallest one
--===================================================--    


input_d_signal <= input_d;


compare_max: get_max
  port map (
		clk =>clk_400hz_enable,
		max_register => temp_max,
		current_data => input_d_signal,
		flag_max=> flag_max);
					
compare_min: get_min
  port map (
		clk =>clk_400hz_enable,
		min_register => temp_min,
		current_data_min => input_d_signal,
		flag_min=> flag_min);



  process(clk_400hz_enable)
  variable copy_signal: integer range 0 to 1;
  begin

if (rising_edge(clk_400hz_enable)) then                                               

   if (reset='1') then
       if (copy_signal=1) then                                                     -- to synchronize copy with LCD clock
           copy <= '0';
           copy_signal := 0;
       else
           copy <= '1';
           copy_signal :=1;
       end if ;
  

       if (no_veto = '1') then                                                     -- the updataion will only be processed when no_veto is 1
		    if (flag_max = '1') then                                               -- when flag_max = 1, then update the max temp
				    temp_max <= input_d_signal;
		    else
				    temp_max <= temp_max;
		    end if;
		
		    if (flag_min ='1') then                                                -- when flag_min = 1, then update the min temp
				    temp_min <= input_d_signal;				
		    else 
				    temp_min <= temp_min;
				
		    end if;	
	    end if;
	
   else
	temp_max <= "101011001100100010000";                                             -- when reset = 0, then we reset the max register to -599.10
	temp_min <= "001011001100100010000";                                             -- when reset = 0, then we reset the min register to +599.10
	end if;
    end if;
end process;









--===================================================--  
-- connect decimal to ascii conversion block 
--===================================================-- 

G0:  for i in 0 to N generate
    temp_digit_decimal(i) <= input_d_signal((4*i)+3 downto 4*i);
     decimal_2_ascii_proc: decimal_2_ascii
	PORT MAP(
		  input_d =>temp_digit_decimal(i),
		  output_a =>temp_digit_ascii(i),
                  clk=> clk_400hz_enable);

end generate;




--===================================================--  
-- connect decimal to ascii conversion block for max value
--===================================================-- 

G1:  for i in 0 to N generate
    temp_digit_decimal_max(i) <= temp_max((4*i)+3 downto 4*i);
     decimal_2_ascii_proc_max: decimal_2_ascii_max
	PORT MAP(
		  input_d =>temp_digit_decimal_max(i),
		  output_a =>temp_digit_ascii_max(i),
                  clk=> clk_400hz_enable);

end generate;



--===================================================--  
-- connect decimal to ascii conversion block for min value
--===================================================-- 

G2:  for i in 0 to N generate
    temp_digit_decimal_min(i) <= temp_min((4*i)+3 downto 4*i);
     decimal_2_ascii_proc_min: decimal_2_ascii_min
	PORT MAP(
		  input_d =>temp_digit_decimal_min(i),
		  output_a =>temp_digit_ascii_min(i),
                  clk=> clk_400hz_enable);

end generate;












--===================================================--  
-- SIGNAL STD_LOGIC_VECTORS assigned to OUTPUT PORTS 
--===================================================--    
data_bus_0 <= data_bus(0);
data_bus_1 <= data_bus(1);
data_bus_2 <= data_bus(2);
data_bus_3 <= data_bus(3);
data_bus_4 <= data_bus(4);
data_bus_5 <= data_bus(5);
data_bus_6 <= data_bus(6);
data_bus_7 <= data_bus(7);

 
-- ASCII hex values for LCD Display

--   = x"20",
-- ! = x"21",
-- " = x"22",
-- # = x"23",
-- $ = x"24",
-- % = x"25",
-- & = x"26",
-- ' = x"27",
-- ( = x"28",
-- ) = x"29",
-- * = x"2A",
-- + = x"2B",
-- , = x"2C",
-- - = x"2D",
-- . = x"2E",
-- / = x"2F",



-- 0 = x"30",
-- 1 = x"31",
-- 2 = x"32",
-- 3 = x"33",
-- 4 = x"34",
-- 5 = x"35",
-- 6 = x"36",
-- 7 = x"37",
-- 8 = x"38",
-- 9 = x"39",
-- : = x"3A",
-- ; = x"3B",
-- < = x"3C",
-- = = x"3D",
-- > = x"3E",
-- ? = x"3F",




-- Q = x"40",
-- A = x"41",
-- B = x"42",
-- C = x"43",
-- D = x"44",
-- E = x"45",
-- F = x"46",
-- G = x"47",
-- H = x"48",
-- I = x"49",
-- J = x"4A",
-- K = x"4B",
-- L = x"4C",
-- M = x"4D",
-- N = x"4E",
-- O = x"4F",



-- P = x"50",
-- Q = x"51",
-- R = x"52",
-- S = x"53",
-- T = x"54",
-- U = x"55",
-- V = x"56",
-- W = x"57",
-- X = x"58",
-- Y = x"59",
-- Z = x"5A",
-- [ = x"5B",
-- Y! = x"5C",
-- ] = x"5D",
-- ^ = x"5E",
-- _ = x"5F",



-- \ = x"60",
-- a = x"61",
-- b = x"62",
-- c = x"63",
-- d = x"64",
-- e = x"65",
-- f = x"66",
-- g = x"67",
-- h = x"68",
-- i = x"69",
-- j = x"6A",
-- k = x"6B",
-- l = x"6C",
-- m = x"6D",
-- n = x"6E",
-- o = x"6F",



-- p = x"70",
-- q = x"71",
-- r = x"72",
-- s = x"73",
-- t = x"74",
-- u = x"75",
-- v = x"76",
-- w = x"77",
-- x = x"78",
-- y = x"79",
-- z = x"7A",
-- { = x"7B",
-- | = x"7C",
-- } = x"7D",
-- -> = x"7E",
-- <- = x"7F",


--===================================================--  
-- set the sign bit 
--===================================================--    
sign_ascii<= x"20" when input_d(20)='0' else
             x"2D" when input_d(20)='1' else
             x"3F";


--===================================================--  
-- set the sign bit for max temp
--===================================================--    
sign_ascii_max<= x"20" when temp_max(20)='0' else         
                 x"2D" when temp_max(20)='1' else
                 x"3F";



--===================================================--  
-- set the sign bit for min temp
--===================================================--    
sign_ascii_min<= x"20" when temp_min(20)='0' else         
                 x"2D" when temp_min(20)='1' else
                 x"3F";





--===================================================--  
-- set characters in LCD 
--===================================================--    

 lcd_display_string_01 <=                        -- display characters for current temp
  (
---     2nd-MSB integer digit 3rd-MSB integer digit  .   MSB fraction digit  2nd-MSB fraction digit                  ||  T     E     M     P     :   sign bit   MSB integer digit
          temp_digit_ascii(3),temp_digit_ascii(2),x"2E",temp_digit_ascii(1),temp_digit_ascii(0),x"20",x"20",x"20",x"20",x"54",x"45",x"4D",x"50",x"3A",sign_ascii,temp_digit_ascii(4)
   
   );



 lcd_display_string_02 <=                   --- display characters for max temp and min temp
  (
---        M    I     N    sign bit           MSB integer digit   second MSB integer digit   .   MSB fraction digit  ||  M    A     X       sign bit   MSB integer digit      second MSB integer digit     .      MSB fraction digit
        x"4D",x"49",x"4E",sign_ascii_min,temp_digit_ascii_min(3),temp_digit_ascii_min(2),x"2E",temp_digit_ascii_min(1),x"4D",x"41",x"58",sign_ascii_max,temp_digit_ascii_max(3),temp_digit_ascii_max(2), x"2E", temp_digit_ascii_max(1)
   
   );




-------------------------------------------------------------------------------------------------------
-- BIDIRECTIONAL TRI STATE LCD DATA BUS
   data_bus <= data_bus_value when lcd_rw_int = '0' else "ZZZZZZZZ";
   
-- LCD_RW PORT is assigned to it matching SIGNAL 
   lcd_rw <= lcd_rw_int;
 
 

------------------------------------ STATE MACHINE FOR LCD SCREEN MESSAGE SELECT -----------------------------
---------------------------------------------------------------------------------------------------------------
         
 
 next_char <= lcd_display_string_01(CONV_INTEGER(char_count))  when switch_1 = '0' else      -- display current temp       
              lcd_display_string_02(CONV_INTEGER(char_count))  when switch_1 = '1' else      -- display max and min temp
	          lcd_display_string_01(CONV_INTEGER(char_count))  ;




process(clk)
begin
      if (rising_edge(clk)) then
            if (clk_count_400hz <= x"0F424") then         -- correct count number for LCD display: x"0F424"; x"00014" for testbench using
                   clk_count_400hz <= clk_count_400hz + 1;                                   
                   clk_400hz_enable <= '0';                
            else
                   clk_count_400hz <= x"00000";
                   clk_400hz_enable <= '1';
            end if;
      end if;
end process;  

--==================================================================--    
  --======================== LCD DRIVER CORE ==============================--   
--                     STATE MACHINE WITH RESET                          -- 
--===================================================-----===============--  
process (clk, reset)
begin
 
  
  
        
    
    
        if(rising_edge(clk)) then
	      if reset = '0' then
           state <= reset1;
           data_bus_value <= x"01"; -- RESET
           next_command <= reset2;
           lcd_e <= '1';
           lcd_rs <= '0';
           lcd_rw_int <= '0';  
	else
             if clk_400hz_enable = '1' then  
                 
 
              --========================================================--                 
              -- State Machine to send commands and data to LCD DISPLAY
              --========================================================--
                 case state is
                 -- Set Function to 8-bit transfer and 2 line display with 5x8 Font size
                      
--======================= INITIALIZATION START ============================--
                       when reset1 =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"38"; -- RESET
                            state <= drop_lcd_e;
                            next_command <= reset2;
                            char_count <= "0000";
  
                       when reset2 =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"38"; -- RESET
                            state <= drop_lcd_e;
                            next_command <= reset3;
                            
                       when reset3 =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"38"; -- RESET
                            state <= drop_lcd_e;
                            next_command <= func_set;
            
			
                       -- Function Set
                       --==============--
                       when func_set =>                
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"38";  -- **Set Function to 8-bit transfer, 2-line display
                            state <= drop_lcd_e;
                            next_command <= display_off;
                            
                                                  
                       -- Turn off Display
                       --==============-- 
                       when display_off =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"08"; -- Turns OFF the Display, Cursor OFF and Blinking Cursor Position OFF.......
                            state <= drop_lcd_e;
                            next_command <= display_clear;
                           
                           
                       -- Clear Display 
                       --==============--
                       when display_clear =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"01"; -- Clears the Display    
                            state <= drop_lcd_e;
                            next_command <= display_on;
                                                     
                           
                       -- Turn on Display and Turn off cursor
                       --===================================--
                       when display_on =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"0C"; -- Turns on the Display 
                            state <= drop_lcd_e;
                            next_command <= mode_set;
                          
                          
                       -- Set write mode to auto increment address and move cursor to the right
                       --====================================================================--
                       when mode_set =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"06"; -- Auto increment address and move cursor to the right
                            state <= drop_lcd_e;
                            next_command <= print_string; 
                            
                                
--======================= INITIALIZATION END ============================--                          
                          
                          
                          
                          
--=======================================================================--                           
--               Write ASCII hex character Data to the LCD
--=======================================================================--
                       when print_string =>          
                            state <= drop_lcd_e;
                            lcd_e <= '1';
                            lcd_rs <= '1';
                            lcd_rw_int <= '0';
                            data_bus_value <= next_char;
                              
                            state <= drop_lcd_e; 
                          
                          
                            -- Loop to send out 16 characters to LCD Display (16 by 2 lines)
                               if (char_count < 15) then
                                   char_count <= char_count +1;                           
                               else
                                   char_count <= "0000";
                               end if;
                               
                               -- Jump to second line
                               if char_count = 7 then 
                                  next_command <= line2;
                                 
                            -- Return to first line
                              elsif (char_count = 15)  then
                                     next_command <= return_home;
                               else
                                     next_command <= print_string; 
                               end if; 
                      
                        -- Set address for line 2
                       --====================================================================--                    
                       when line2 =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"80";
                            state <= drop_lcd_e;
                            next_command <= print_string; 
 
                        -- Set address for returning home
                       --====================================================================--     
                       when return_home =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"c0";
                            state <= drop_lcd_e;
                            next_command <= print_string; 
                    
                    
                       -- Drop LCD E line - falling edge loads inst/data to LCD controller
                       --============================================================================--
                       when drop_lcd_e =>
                            lcd_e <= '0';
                            state <= hold;
                   
                       -- Hold LCD inst/data valid after falling edge of E line
                       --====================================================--
                       when hold =>
                            state <= next_command;     
		
		end case;
end if;
      end if;
end if;
end process;                                                            
  
END ARCHITECTURE LCD_DISPLAY_arch;
