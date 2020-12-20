-------------------------------------------------------
-------------------------------------------------------
---- decimal to ascii conversion-----------------------
----input: 4-bit vector in unsigned decimal format-----
----output: 8-bit vector in ascii format---------------
-------------------------------------------------------
-------------------------------------------------------

LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;


entity decimal_2_ascii_min is
  port(
           input_d : in std_logic_vector(3 downto 0);
               clk : in std_logic;
          output_a : out std_logic_vector(7 downto 0));

  end decimal_2_ascii_min;


architecture arch of decimal_2_ascii_min is



 signal input_signal : std_logic_vector(3 downto 0):=(others=>'0');
signal output_signal : std_logic_vector(7 downto 0):=(others=>'0');

begin




process(clk)
begin 
 
         case input_signal is 
                  when "0000" => output_signal<= x"30";   --- decimal 0 to ascii x"30"
                  when "0001" => output_signal<= x"31";   --- decimal 1 to ascii x"31"
                  when "0010" => output_signal<= x"32";   --- decimal 2 to ascii x"32"
                  when "0011" => output_signal<= x"33";   --- decimal 3 to ascii x"33"
                  when "0100" => output_signal<= x"34";   --- decimal 4 to ascii x"34"
                  when "0101" => output_signal<= x"35";   --- decimal 5 to ascii x"35"
                  when "0110" => output_signal<= x"36";   --- decimal 6 to ascii x"36"
                  when "0111" => output_signal<= x"37";   --- decimal 7 to ascii x"37"
                  when "1000" => output_signal<= x"38";   --- decimal 8 to ascii x"38"
                  when "1001" => output_signal<= x"39";   --- decimal 9 to ascii x"39"
                  when others => output_signal<= x"3F";   --- ?

        end case;
end process;

input_signal <= input_d;
output_a <= output_signal;

end arch;
