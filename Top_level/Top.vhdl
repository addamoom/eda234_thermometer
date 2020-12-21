LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


ENTITY toplevel IS
    PORT (

        BTNL                : IN STD_LOGIC;    -- Reset button
        BTNR                : IN STD_LOGIC;    -- Toggles displays
        CLK100MHZ           : IN STD_LOGIC;    -- 100MHZ clock
        Toggle_minmax       : IN STD_LOGIC;    -- Toggle Lcd mode. 0 - display current temp, 1 - display new temp
        SDA                 : INOUT STD_LOGIC; -- Temp Sensor I2C data 
        SCL                 : OUT STD_LOGIC;   -- Temp Sensor I2C clock
        
        toplevel_lcd_rs     : OUT STD_LOGIC;   -- LCD connection
        toplevel_lcd_e      : OUT STD_LOGIC;   -- LCD connection
        toplevel_lcd_rw     : OUT STD_LOGIC;   -- LCD connection
        toplevel_data_bus_0 : INOUT STD_LOGIC; -- LCD connection
        toplevel_data_bus_1 : INOUT STD_LOGIC; -- LCD connection
        toplevel_data_bus_2 : INOUT STD_LOGIC; -- LCD connection
        toplevel_data_bus_3 : INOUT STD_LOGIC; -- LCD connection
        toplevel_data_bus_4 : INOUT STD_LOGIC; -- LCD connection
        toplevel_data_bus_5 : INOUT STD_LOGIC; -- LCD connection
        toplevel_data_bus_6 : INOUT STD_LOGIC; -- LCD connection
        toplevel_data_bus_7 : INOUT STD_LOGIC; -- LCD connection

        data_433            : IN STD_LOGIC;  -- Data pin on 433 receiver
        
        AN : OUT STD_LOGIC_VECTOR (7 downto 0);
        SEG : OUT STD_LOGIC_VECTOR (7 downto 0)

    );
END toplevel;

ARCHITECTURE arc_toplevel OF toplevel IS

    SIGNAL temp_indoor,temp_outdoor,temp_to_lcd,Temp_out_433 : STD_LOGIC_VECTOR (20 DOWNTO 0); 
    SIGNAL temp_indoor_raw : STD_LOGIC_VECTOR (12 DOWNTO 0);

    SIGNAL Reset_n,Clk_10us : STD_LOGIC;

    COMPONENT temp_sens
        PORT (
            CLK                : IN STD_LOGIC; -- 100 Mhz clock
            RESET_N            : IN STD_LOGIC;
            temp               : OUT STD_LOGIC_VECTOR (12 DOWNTO 0); -- 13 bit vector
            SDA                : INOUT STD_LOGIC;
            SCL                : OUT STD_LOGIC;
            counter_period_out : OUT INTEGER; -- For debugging
            counter_data_out   : OUT INTEGER
        );

    END COMPONENT temp_sens;
    
    COMPONENT main is --this is the hex top level
        Port ( AN : out STD_LOGIC_VECTOR (7 downto 0);
               SEG : out STD_LOGIC_VECTOR (7 downto 0);
               CLK100MHZ : in STD_LOGIC;
               temp_in : in STD_LOGIC_VECTOR (20 downto 0);
               CPU_RESETN : IN STD_LOGIC
        );
    end COMPONENT main;
    

    COMPONENT LCD_DISPLAY_nty
        GENERIC (N : NATURAL := 4);
        PORT (
            reset      : IN STD_LOGIC;
            clk        : IN STD_LOGIC; 
            input_d    : IN STD_LOGIC_VECTOR(20 DOWNTO 0);
            
            switch_1           : IN     std_logic;             --when switch_1 = 1, sdisplay the max/min temp
            no_veto            : in     std_logic;
            copy               : out    std_logic;

            lcd_rs     : OUT STD_LOGIC;
            lcd_e      : OUT STD_LOGIC;
            lcd_rw     : OUT STD_LOGIC;
            data_bus_0 : INOUT STD_LOGIC;
            data_bus_1 : INOUT STD_LOGIC;
            data_bus_2 : INOUT STD_LOGIC;
            data_bus_3 : INOUT STD_LOGIC;
            data_bus_4 : INOUT STD_LOGIC;
            data_bus_5 : INOUT STD_LOGIC;
            data_bus_6 : INOUT STD_LOGIC;
            data_bus_7 : INOUT STD_LOGIC);
    END COMPONENT LCD_DISPLAY_nty;
    
    COMPONENT sensor_to_chip is
       PORT( 
          clk                : IN     std_logic;
          input_d            : IN     std_logic_vector(20 downto 0); -- sensor input
          copy               : IN     std_logic;                     -- functions as state machine clock from LCD code
          output_d           : OUT     std_logic_vector(20 downto 0); -- copied input that will be static while checked and displayed until copy cycle complete
          no_veto           : OUT     std_logic                      -- enable signal that is turned off during copying state for a fraction of LCD clock cycle
          );
    end COMPONENT sensor_to_chip;
    

    COMPONENT TempData_to_Decimal
        PORT (

            temp_data : IN STD_LOGIC_VECTOR (12 DOWNTO 0);

            temp_dec  : OUT STD_LOGIC_VECTOR (20 DOWNTO 0)

        );

    END COMPONENT TempData_to_Decimal;

    COMPONENT W433_interface IS
        PORT (
            Clk_10us    : IN STD_LOGIC;
            Reset_n     : IN STD_LOGIC;
            get_sample  : IN STD_LOGIC;
            data_in     : IN STD_LOGIC;
            Temp_out    : OUT STD_LOGIC_VECTOR(20 DOWNTO 0);
            sample_done : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT freq_divisor IS
        GENERIC (N : INTEGER := 10);
        PORT (
            clk     : IN STD_LOGIC;
            reset_n : IN STD_LOGIC;
            clk_out : OUT STD_LOGIC
        );
    END COMPONENT freq_divisor;

    COMPONENT temp_switcher IS
    PORT (
        Clk              : IN STD_LOGIC;                     -- 100 khz clock
        Reset_n          : IN STD_LOGIC;                     -- Active low reset
        interal_temp_in  : IN STD_LOGIC_VECTOR(20 DOWNTO 0); -- 
        External_temp_in : IN STD_LOGIC_VECTOR(20 DOWNTO 0); --
        Toggle           : IN STD_LOGIC;                     -- switch output between the two inputs
        Temp_to_lcd      : OUT STD_LOGIC_VECTOR(20 DOWNTO 0) -- Temperature output to lcd
    );
END COMPONENT temp_switcher;
SIGNAL temp_to_lcd_after : STD_LOGIC_VECTOR(20 DOWNTO 0);
SIGNAL copy, no_veto : STD_LOGIC;

BEGIN

    Reset_n <= NOT BTNL;

    temp_sens_comp : temp_sens
    PORT MAP(
        RESET_N => Reset_n,
        CLK     => CLK100MHZ,
        SDA     => SDA,
        SCL     => SCL,
        temp    => temp_indoor_raw);

    temp_sense_to_decimal_comp : TempData_to_Decimal
    PORT MAP(
        temp_data => temp_indoor_raw,
        temp_dec  => temp_indoor
    );

    LCD_DISPLAY_nty_comp : LCD_DISPLAY_nty
    PORT MAP(
        reset      => Reset_n,
        clk        => CLK100MHZ,
        input_d    => temp_to_lcd_after,
        
        switch_1 => Toggle_minmax,
        no_veto => no_veto,
        copy => copy,
        
        lcd_rs     => toplevel_lcd_rs,
        lcd_e      => toplevel_lcd_e,
        lcd_rw     => toplevel_lcd_rw,
        data_bus_0 => toplevel_data_bus_0,
        data_bus_1 => toplevel_data_bus_1,
        data_bus_2 => toplevel_data_bus_2,
        data_bus_3 => toplevel_data_bus_3,
        data_bus_4 => toplevel_data_bus_4,
        data_bus_5 => toplevel_data_bus_5,
        data_bus_6 => toplevel_data_bus_6,
        data_bus_7 => toplevel_data_bus_7);
        
      sensor_to_chip_comp : sensor_to_chip
      PORT MAP( 
                 clk    => CLK100MHZ,         
                 input_d => temp_to_lcd  ,    
                 copy  => copy,             
                 output_d => temp_to_lcd_after ,          
                 no_veto => no_veto      
                 );

    -- Clock generator for 433 MHZ communication
    d100khz : freq_divisor GENERIC MAP(N => 1000) 
    PORT MAP
    (
        clk     => CLK100MHZ,
        reset_n => Reset_n,
        clk_out => Clk_10us
    );

    W433 : W433_interface
    PORT MAP(
        Clk_10us    => Clk_10us,
        Reset_n     => Reset_n,
        get_sample  => '0',
        data_in     => data_433,
        Temp_out    => temp_outdoor,
        sample_done => OPEN
    );

    Tswitch : COMPONENT temp_switcher PORT MAP(
        Clk              => CLK100MHZ,
        Reset_n          => Reset_n,
        interal_temp_in  => temp_indoor,
        External_temp_in => temp_outdoor,
        Toggle           => BTNR,
        Temp_to_lcd      => temp_to_lcd
    );
    
        hexdisp : main PORT MAP(
               AN  => AN,
               SEG => SEG,
               CLK100MHZ => CLK100MHZ,
               temp_in => temp_to_lcd,
               CPU_RESETN =>Reset_n
        );

END arc_toplevel;