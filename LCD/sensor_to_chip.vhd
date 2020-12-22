-----------------------------------------------------------------------------------------------------
-- Sensor clock frequency is much higher than LCD, this component is to synchronize the clock as LCD
-----------------------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity sensor_to_chip is
   PORT( 
      clk                : IN     std_logic;
      input_d            : IN     std_logic_vector(20 downto 0); -- sensor input
      copy               : IN     std_logic;                     -- functions as state machine clock from LCD code
      output_d           : OUT     std_logic_vector(20 downto 0); -- copied input that will be static while checked and displayed until copy cycle complete
      no_veto            : OUT     std_logic                      -- enable signal that is turned off during copying state for a fraction of LCD clock cycle
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

    when copy_state => -- this is extremely ugly code but we don't know if a for loop would synthesize the same
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
        if (copy='0') then --wait for slowly changing "copy" signal from LCD to go down before proceeding
            state <= hold;
        end if;
    
    when hold =>
        if (copy='1') then --wait for copy signal from LCD to be set to 1 again before proceeding
            state <= copy_state;
            no_veto <= '0'; -- set to 0 to veto check for min/max in LCD code while copying signal
        end if;
    end case;
end if;
end process;
end Behavioral;
