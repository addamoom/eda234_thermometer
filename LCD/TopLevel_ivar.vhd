LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY toplevel IS
PORT(

	toplevel_reset      :    IN     std_logic;  
	toplevel_clk        :    IN     std_logic;  
	SDA                 :    inout  STD_LOGIC;
    SCL                 :    out    STD_LOGIC;
    switch_1            :    IN     std_logic;

      toplevel_lcd_rs             : OUT    std_logic;
      toplevel_lcd_e              : OUT    std_logic;
      toplevel_lcd_rw             : OUT    std_logic;   
    
      flag_max_out       : out    std_logic;
      flag_min_out       : out    std_logic;
            
      toplevel_data_bus_0         : INOUT  STD_LOGIC;
      toplevel_data_bus_1         : INOUT  STD_LOGIC;
      toplevel_data_bus_2         : INOUT  STD_LOGIC;
      toplevel_data_bus_3         : INOUT  STD_LOGIC;
      toplevel_data_bus_4         : INOUT  STD_LOGIC;
      toplevel_data_bus_5         : INOUT  STD_LOGIC;
      toplevel_data_bus_6         : INOUT  STD_LOGIC;
      toplevel_data_bus_7         : INOUT  STD_LOGIC   	
);
END toplevel;

ARCHITECTURE arc_toplevel OF toplevel IS

signal temp1: STD_LOGIC_VECTOR (20 downto 0); --connect to decimal component and LCD component
signal temp2: STD_LOGIC_VECTOR (12 downto 0);
signal temp3: STD_LOGIC_VECTOR (20 downto 0);
signal temp4: STD_LOGIC;
signal temp_veto: STD_LOGIC;

COMPONENT temp_sens
 port (

        CLK : in STD_LOGIC; -- 100 Mhz clock

        RESET_N : in STD_LOGIC; 

        temp : out STD_LOGIC_VECTOR (12 downto 0); -- 13 bit vector

        SDA : inout STD_LOGIC;

        SCL : out STD_LOGIC;

        counter_period_out : out integer; -- For debugging

        counter_data_out : out integer

    );
  
END COMPONENT temp_sens;

COMPONENT LCD_DISPLAY_nty
  generic(N: NATURAL :=4);   
	PORT(
      reset              : IN     std_logic;  
      clk                : IN     std_logic;  -- in order to Genreate the 400Hz signal... clk_count_400hz reset count value must be set to:  <= x"0F424" (62500)   x"1E848"--- (125000), x"3D090" ---(250000) for 100Mhz 
      input_d            : IN     std_logic_vector(20 downto 0);
      switch_1           : IN     std_logic;
      no_veto            : in     std_logic;
      lcd_rs             : OUT    std_logic;
      lcd_e              : OUT    std_logic;
      lcd_rw             : OUT    std_logic; 
      copy               : out    std_logic;      
        
      flag_max_out       : out    std_logic;
      flag_min_out       : out    std_logic;     
      
      data_bus_0         : INOUT  STD_LOGIC;
      data_bus_1         : INOUT  STD_LOGIC;
      data_bus_2         : INOUT  STD_LOGIC;
      data_bus_3         : INOUT  STD_LOGIC;
      data_bus_4         : INOUT  STD_LOGIC;
      data_bus_5         : INOUT  STD_LOGIC;
      data_bus_6         : INOUT  STD_LOGIC;
      data_bus_7         : INOUT  STD_LOGIC    );
END COMPONENT LCD_DISPLAY_nty;


COMPONENT TempData_to_Decimal
    port (

        temp_data : in STD_LOGIC_VECTOR (12 downto 0);

        temp_dec : out STD_LOGIC_VECTOR (20 downto 0)

    );

END COMPONENT TempData_to_Decimal;

COMPONENT sensor_to_chip 
   PORT( 
      clk                : IN     std_logic;
      input_d            : IN     std_logic_vector(20 downto 0);
      copy               : IN     std_logic;
      no_veto            : out    std_logic;
      output_d           : OUT     std_logic_vector(20 downto 0)
      );
END COMPONENT sensor_to_chip;





BEGIN
temp_sens_comp: temp_sens
 PORT MAP (
							RESET_N  =>toplevel_reset,
							CLK =>toplevel_clk,
							SDA =>SDA,
							SCL =>SCL,
							temp =>temp2 );
														
							
							
temp_sense_to_decimal_comp: TempData_to_Decimal	
   PORT MAP (

        
                            temp_data => temp2  , 
                            temp_dec => temp1
    );	 				
    
 sensor_to_chip_comp:  sensor_to_chip
     PORT MAP( 
      clk        =>       toplevel_clk, 
      input_d     =>      temp1,
      copy => temp4,
      output_d    => temp3,
      no_veto => temp_veto 
      ); 
							
							
							
							
							
							
							

LCD_DISPLAY_nty_comp : LCD_DISPLAY_nty 
PORT MAP(
						reset =>toplevel_reset,
						switch_1=> switch_1,
					    clk =>toplevel_clk,
						input_d =>temp3,
						copy=>temp4,
						no_veto => temp_veto,
						lcd_rs => toplevel_lcd_rs,
						lcd_e =>toplevel_lcd_e ,
						lcd_rw =>toplevel_lcd_rw,
						flag_max_out=> flag_max_out,
						flag_min_out=> flag_min_out,
						data_bus_0 =>toplevel_data_bus_0,
						data_bus_1 =>toplevel_data_bus_1,
						data_bus_2 =>toplevel_data_bus_2,
						data_bus_3 =>toplevel_data_bus_3,
						data_bus_4 =>toplevel_data_bus_4,
						data_bus_5 =>toplevel_data_bus_5,
						data_bus_6 =>toplevel_data_bus_6, 
						data_bus_7=>toplevel_data_bus_7);

END arc_toplevel;
