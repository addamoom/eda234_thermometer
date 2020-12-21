library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity main is
    Port ( AN : out STD_LOGIC_VECTOR (7 downto 0);
           SEG : out STD_LOGIC_VECTOR (7 downto 0);
           CLK100MHZ : in STD_LOGIC;
           temp_in : in STD_LOGIC_VECTOR (20 downto 0);
           CPU_RESETN : IN STD_LOGIC
    );
end main;

architecture Behavioral of main is

component decimal_2_ascii is
    port(
        input_d : in std_logic_vector(3 downto 0);
            clk : in std_logic;
       output_a : out std_logic_vector(7 downto 0));
end component;

component hexdisp is
    port(
            AN : out STD_LOGIC_VECTOR (7 downto 0); -- NEXYS
            SEG : out STD_LOGIC_VECTOR (7 downto 0); -- NEXYS
            CLK100MHZ : in STD_LOGIC; -- NEXYS
            ASCII : in STD_LOGIC_VECTOR (63 downto 0)); -- Message in exactly as it should be dsiplayed.
end component;

signal ascii_message : STD_LOGIC_VECTOR (63 downto 0);
signal counter_out : integer;

--signal temp_data_sign : STD_LOGIC_VECTOR (12 downto 0);
signal temp_dec_sign : STD_LOGIC_VECTOR (20 downto 0);
signal temp_ascii_sign : STD_LOGIC_VECTOR (39 downto 0);
signal temp_ascii : STD_LOGIC_VECTOR (63 downto 0) := x"40_40_40_40_40_40_40_40";

begin
            
           
                    
        D2A0 : decimal_2_ascii port map (
                input_d => temp_in(3 downto 0),
                clk => CLK100MHZ, 
                output_a => temp_ascii_sign(7 downto 0) 
                );
                
        D2A1 : decimal_2_ascii port map (
                input_d => temp_in(7 downto 4),
                clk => CLK100MHZ, 
                output_a => temp_ascii_sign(15 downto 8) 
                );
                
        D2A2 : decimal_2_ascii port map (
                input_d => temp_in(11 downto 8),
                clk => CLK100MHZ, 
                output_a => temp_ascii_sign(23 downto 16) 
                );
                
        D2A3 : decimal_2_ascii port map (
                input_d => temp_in(15 downto 12),
                clk => CLK100MHZ, 
                output_a => temp_ascii_sign(31 downto 24) 
                );
                
        D2A4 : decimal_2_ascii port map (
                input_d => temp_in(19 downto 16),
                clk => CLK100MHZ, 
                output_a => temp_ascii_sign(39 downto 32) 
                );
            
    hex_disp : hexdisp port map
            (
            AN => AN,
            SEG => SEG,
            CLK100MHZ => CLK100MHZ,
            ASCII => ascii_message
            );
    
    hex_proc : process (temp_ascii_sign, temp_in)
    variable ascii_1 : STD_LOGIC_VECTOR(7 downto 0);
    variable ascii_2 : STD_LOGIC_VECTOR(7 downto 0);
    variable ascii_3 : STD_LOGIC_VECTOR(7 downto 0);
    begin
        ascii_1 := temp_ascii_sign(31 downto 24);
        ascii_2 := temp_ascii_sign(23 downto 16);
        ascii_3 := temp_ascii_sign(15 downto 8);
        if temp_in(20) = '1' then
            ascii_message <= x"54_45_4D_50" & x"00" & ascii_1 & ascii_2 & ascii_3;  -- TEMP-25.6
        else
            ascii_message <= x"54_45_4D_50" & x"00" & ascii_1 & ascii_2 & ascii_3;  -- TEMP 25.6
        end if;
    end process hex_proc;
    
    --JA(4) <= SW(0);

end Behavioral;