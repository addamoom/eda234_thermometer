-- Controls all other devices
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY controller IS

END ENTITY controller;

ARCHITECTURE controllerarch OF controller IS
    TYPE Controller_state_type IS (get_indoor_temp, get_outdoor_temp, update_displays, Transmitt_to_pc, wait_a_sec);
    TYPE Indoor_temp_state_type IS (request, wait_for_not_valid, wait_for_valid, compare_registers);
    SIGNAL Controller_state: Controller_state_type;
    SIGNAL Indoor_temp_state: Indoor_temp_state_type;
BEGIN
    proc_name : PROCESS (clk, rst)
    BEGIN
        IF reset THEN
            Controller_state <= get_indoor_temp;
            Indoor_temp_state <= request;
        ELSIF rising_edge(clk) THEN
            case Controller_state is
                when get_indoor_temp => 
                    case expression is
                        when request =>
                            -- raise get sample signal of indoor temp module and go to next state
                        when wait_for_not_valid => 
                            -- wait for valid signal to go low, meaning the temp module is working 
                            -- when low, move to next state 

                        when wait_for_valid =>
                        -- wait for valid signal to go high, meaning the temp module is done 
                        -- when its high, save temp to register and move on
                        when compare_registers =>
                            -- replace min or max indoor temperature registers if neccesary
                    end case;
                when get_outdoor_temp =>
                    -- no interfacing neccsary, just save temperature, look at min and max outdoor temp, and move on.
                when update_displays =>
                    -- this part has no need to be syncrounous, could aswell be a simple when statement, but yay, controller
                    if display_selector =  "000" then
                        -- send indoor temp to lcd and "IN TEMP" to hex
                    elsif display_selector =  "001" then
                        -- send indoor max temp to lcd and "IN MAX" to hex
                    elsif display_selector =  "010" then
                        -- send indoor min temp to lcd "IN MIN" to hex
                    elsif display_selector =  "011" then
                        -- send outdoor temp to lcd and  "OUT TEMP" to hex
                    elsif display_selector =  "100" then
                        -- send outdoor max temp to lcd and  "OUT MAX" to hex
                    elsif display_selector =  "101" then
                        -- send outdoor max temp to lcd and  "OUT MIN" to hex
                    else
                        -- send ERROR to hex
                    end if;
                when Transmitt_to_pc =>
                    -- set send flag and temp to transmitt module and wait for it to respond with a done flag
                    -- this should not be done every time, so have a counter and only send like once every tenth iteration or something
                when wait_a_sec =>
                    -- wait for some amount of time, like 0.1 sec, and go to the initial state
            end case;
        END IF;
    END PROCESS proc_name;