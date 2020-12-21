---------------------------------------------------------------------------------------
------function: get two input (max_register and current_data),then compare them,-------
----if current_data > max_register, then output flag_max = 1, otherwise flag_max = 0 --
---------------------------------------------------------------------------------------


LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;
use  ieee.std_logic_arith.UNSIGNED;

entity get_max is 
port(
       clk                        : in std_logic;
       max_register               : in std_logic_vector(20 downto 0);
       current_data               : in std_logic_vector(20 downto 0);
       flag_max                   : out std_logic);                -- when flag_max = 1, max_register <= current_data; when flag_max = 0, max_register <= max_register
end get_max;


architecture arch of get_max is

signal sign_bit_Register                     : std_logic;
signal d1_Register                           : unsigned(3 downto 0);
signal d2_Register                           : unsigned(3 downto 0);
signal d3_Register                           : unsigned(3 downto 0);
signal d4_Register                           : unsigned(3 downto 0);
signal d5_Register                           : unsigned(3 downto 0);

signal sign_bit_current                      : std_logic;
signal d1_current                            : unsigned(3 downto 0);
signal d2_current                            : unsigned(3 downto 0);
signal d3_current                            : unsigned(3 downto 0);
signal d4_current                            : unsigned(3 downto 0);
signal d5_current                            : unsigned(3 downto 0);

signal sign_combination                      : std_logic_vector(1 downto 0);         -- sign_combination = sign_bit_current & sign_bit_register
signal compare_flag_d1                       : boolean;
signal compare_flag_d2                       : boolean;
signal compare_flag_d3                       : boolean;
signal compare_flag_d4                       : boolean;
signal compare_flag_d5                       : boolean;

signal compare_flag_d1eq                     : boolean;
signal compare_flag_d2eq                     : boolean;
signal compare_flag_d3eq                     : boolean;
signal compare_flag_d4eq                     : boolean;
signal compare_flag_d5eq                     : boolean;


begin

sign_bit_Register <= max_register(20);
     d1_Register  <= unsigned(max_register(19 downto 16));
     d2_Register  <= unsigned(max_register(15 downto 12));
     d3_Register  <= unsigned(max_register(11 downto 8));
     d4_Register  <= unsigned(max_register(7  downto 4));
     d5_Register  <= unsigned(max_register(3  downto 0));

sign_bit_current <= current_data(20);
     d1_current  <= unsigned(current_data(19 downto 16));
     d2_current  <= unsigned(current_data(15 downto 12));
     d3_current  <= unsigned(current_data(11 downto 8));
     d4_current  <= unsigned(current_data(7  downto 4));
     d5_current  <= unsigned(current_data(3  downto 0));

sign_combination <= sign_bit_current & sign_bit_register;

 compare_flag_d1 <= (d1_current  > d1_Register);
 compare_flag_d2 <= (d2_current  > d2_Register);
 compare_flag_d3 <= (d3_current  > d3_Register);
 compare_flag_d4 <= (d4_current  > d4_Register);
 compare_flag_d5 <= (d5_current  > d5_Register);
 
 
 compare_flag_d1eq <= (d1_current  = d1_Register);
 compare_flag_d2eq <= (d2_current  = d2_Register);
 compare_flag_d3eq <= (d3_current  = d3_Register);
 compare_flag_d4eq <= (d4_current  = d4_Register);
 compare_flag_d5eq <= (d5_current  = d5_Register);


 
process(clk)
variable enabled : integer range 0 to 1;
begin
     if(rising_edge(clk)) then
	if (enabled=1) then                  -- reset the flag_max to 0 
		flag_max <= '0';	
		enabled:=0;
	else
         case sign_combination is
   
              when "01" =>               -- current_data > 0, register_data < 0, so current_data > register_data
              flag_max <= '1';           -- max_register <= current_data
		enabled:=1;


              when "10" =>               -- current_data < 0, register_data > 0, so current_data < register_data
              flag_max <= '0';           -- max_register <= max_register


              when "11" =>               -- current_data < 0, register_data < 0

              if (compare_flag_d1) then
              flag_max <= '0'; 
                elsif (compare_flag_d1eq and compare_flag_d2) then
                  flag_max <= '0'; 
                      elsif (compare_flag_d1eq and compare_flag_d2eq and compare_flag_d3) then
                        flag_max <= '0';       
                           elsif (compare_flag_d1eq and compare_flag_d2eq and compare_flag_d3eq and compare_flag_d4) then
                             flag_max <= '0';        
                                elsif (compare_flag_d1eq and compare_flag_d2eq and compare_flag_d3eq and compare_flag_d4eq and compare_flag_d5) then
                                  flag_max <= '0';
                                    elsif (compare_flag_d1eq and compare_flag_d2eq and compare_flag_d3eq and compare_flag_d4eq and compare_flag_d5eq) then
                                      flag_max <= '0';     
              else 
              flag_max <= '1'; 
		enabled:=1;     
              end if;


              when "00" =>               -- current_data > 0, register_data > 0
		enabled:=1;
              if (compare_flag_d1) then
              flag_max <= '1'; 
                elsif (compare_flag_d1eq and compare_flag_d2) then
                  flag_max <= '1'; 
                      elsif (compare_flag_d1eq and compare_flag_d2eq and compare_flag_d3) then
                        flag_max <= '1';       
                           elsif (compare_flag_d1eq and compare_flag_d2eq and compare_flag_d3eq and compare_flag_d4) then
                             flag_max <= '1';        
                                elsif (compare_flag_d1eq and compare_flag_d2eq and compare_flag_d3eq and compare_flag_d4eq and compare_flag_d5) then
                                  flag_max <= '1';
                                    elsif (compare_flag_d1eq and compare_flag_d2eq and compare_flag_d3eq and compare_flag_d4eq and compare_flag_d5eq) then
                                      flag_max <= '0';
					enabled:=0;   
              else 
              flag_max <= '0';     		
		enabled:=0; 
              end if;


              when others =>
              flag_max <= '0';             
        end case;
	end if;
     end if;

end process;

end arch;