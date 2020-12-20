----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/20/2020 07:31:11 PM
-- Design Name: 
-- Module Name: sensor_to_chip - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sensor_to_chip is
   PORT( 
      clk                : IN     std_logic;
      input_d            : IN     std_logic_vector(20 downto 0);
      copy               : IN     std_logic;
      output_d           : OUT     std_logic_vector(20 downto 0);
      no_veto           : OUT     std_logic
      );
end sensor_to_chip;

architecture Behavioral of sensor_to_chip is
signal input_static				 : std_logic_vector(20 downto 0);


type state_type is (copy_state,inter,hold);

signal state : state_type;

begin
process (clk)
begin
if rising_edge(clk) then

case state is

    when copy_state =>
        if(input_d(0)='1') then
            output_d(0) <= '1';
            else
            output_d(0) <= '0';
        end if;
        if(input_d(1)='1') then
            output_d(1) <= '1';
            else
            output_d(1) <= '0';
        end if;
        if(input_d(2)='1') then
            output_d(2) <= '1';
            else
            output_d(2) <= '0';
        end if;
        if(input_d(3)='1') then
            output_d(3) <= '1';
            else
            output_d(3) <= '0';
        end if;
        if(input_d(4)='1') then
            output_d(4) <= '1';
            else
            output_d(4) <= '0';
        end if;
        if(input_d(5)='1') then
            output_d(5) <= '1';
            else
            output_d(5) <= '0';
        end if;
        if(input_d(6)='1') then
            output_d(6) <= '1';
            else
            output_d(6) <= '0';
        end if;
        if(input_d(7)='1') then
            output_d(7) <= '1';
            else
            output_d(7) <= '0';
        end if;
        if(input_d(8)='1') then
            output_d(8) <= '1';
            else
            output_d(8) <= '0';
        end if;
        if(input_d(9)='1') then
            output_d(9) <= '1';
            else
            output_d(9) <= '0';
        end if;
        if(input_d(10)='1') then
            output_d(10) <= '1';
            else
            output_d(10) <= '0';
        end if;
        if(input_d(11)='1') then
            output_d(11) <= '1';
            else
            output_d(11) <= '0';
        end if;
        if(input_d(12)='1') then
            output_d(12) <= '1';
            else
            output_d(12) <= '0';
        end if;
        if(input_d(13)='1') then
            output_d(13) <= '1';
            else
            output_d(13) <= '0';
        end if;
        if(input_d(14)='1') then
            output_d(14) <= '1';
            else
            output_d(14) <= '0';
        end if;
        if(input_d(15)='1') then
            output_d(15) <= '1';
            else
            output_d(15) <= '0';
        end if;
        if(input_d(16)='1') then
            output_d(16) <= '1';
            else
            output_d(16) <= '0';
        end if;
    
        if(input_d(17)='1') then
            output_d(17) <= '1';
            else
            output_d(17) <= '0';
        end if;
    
        if(input_d(18)='1') then
            output_d(18) <= '1';
            else
            output_d(18) <= '0';
        end if;
        
        if(input_d(19)='1') then
            output_d(19) <= '1';
            else
            output_d(19) <= '0';
        end if;
        
        if(input_d(20)='1') then
            output_d(20) <= '1';
            else
            output_d(20) <= '0';
        end if;
    state <= inter;
    no_veto <= '1';
    when inter =>
        if (copy='0') then
            state <= hold;
        end if;
    
    when hold =>
        if (copy='1') then
            state <= copy_state;
            no_veto <= '0';
        end if;
    end case;
end if;
end process;
end Behavioral;