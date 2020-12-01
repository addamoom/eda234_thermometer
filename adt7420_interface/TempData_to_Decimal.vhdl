-- Takes in the 13 bit vector, 13 bit is sign, it is represented with 2'complement 
-- Return s d d d . d d 
-- Sign + digital number representation

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity TempData_to_Decimal is
    port (
        temp_data : in STD_LOGIC_VECTOR (12 downto 0);
        temp_dec : out STD_LOGIC_VECTOR (20 downto 0)
    );
end TempData_to_Decimal;

architecture rtl of TempData_to_Decimal is

    -- Describe as d_3 d_2 . d_1 d_0
    constant part_16 : STD_LOGIC_VECTOR (19 downto 0) := x"00006"; -- 0.06 (0.0625)
    constant part_8 : STD_LOGIC_VECTOR (19 downto 0) := x"00013"; -- 0.13 (0.125)
    constant part_4 : STD_LOGIC_VECTOR (19 downto 0) := x"00025"; -- 0.25
    constant part_2 : STD_LOGIC_VECTOR (19 downto 0) := x"00050"; -- 0.50
    constant two_p0 : STD_LOGIC_VECTOR (19 downto 0) := x"00100"; -- 1
    constant two_p1 : STD_LOGIC_VECTOR (19 downto 0) := x"00200"; -- 2
    constant two_p2 : STD_LOGIC_VECTOR (19 downto 0) := x"00400"; -- 4
    constant two_p3 : STD_LOGIC_VECTOR (19 downto 0) := x"00800"; -- 8
    constant two_p4 : STD_LOGIC_VECTOR (19 downto 0) := x"01600"; -- 16
    constant two_p5 : STD_LOGIC_VECTOR (19 downto 0) := x"03200"; -- 32
    constant two_p6 : STD_LOGIC_VECTOR (19 downto 0) := x"06400"; -- 64
    constant two_p7 : STD_LOGIC_VECTOR (19 downto 0) := x"12800"; -- 128

    
    type values_array is array (11 downto 0) of STD_LOGIC_VECTOR (19 downto 0);

    constant val_arr : values_array := (two_p7, two_p6, two_p5, two_p4,
                                        two_p3, two_p2, two_p1, two_p0,
                                        part_2, part_4, part_8, part_16);

    signal temp_data_mod : STD_LOGIC_VECTOR (12 downto 0);
    signal temp_data_inv : STD_LOGIC_VECTOR (11 downto 0);

begin

    temp_data_inv <= not(temp_data(11 downto 0));
    
    temp_data_mod <= '1' & std_logic_vector(unsigned(temp_data_inv) + 1) when temp_data(12) = '1' else
                    temp_data when temp_data(12) = '0';

    to_dec: process(temp_data_mod)
    variable temp_temp : STD_LOGIC_VECTOR (19 downto 0); -- d d d . d d 
    variable concanate : STD_LOGIC_VECTOR (19 downto 0);
    variable add_val   : STD_LOGIC_VECTOR (19 downto 0);
    variable add_one   : STD_LOGIC_VECTOR (19 downto 0); 
    variable over      : STD_LOGIC_VECTOR (19 downto 0); 
    begin



        temp_temp := x"00000";
        for i in 0 to 11 loop
            if temp_data_mod(i)='1' then
               temp_temp := std_logic_vector(unsigned(temp_temp) + unsigned(val_arr(i)));


                if unsigned(temp_temp(3 downto 0)) >= 10 then
                    concanate := temp_temp(19 downto 4) & b"0000";
                    add_one := x"00010";
                    over := x"0000A";
                    add_val := std_logic_vector(unsigned(add_one) + unsigned(temp_temp(3 downto 0)) - unsigned(over));
                    temp_temp := std_logic_vector(unsigned(concanate) + unsigned(add_val));
                end if;
       
                if unsigned(temp_temp(7 downto 4)) >= 10 then
                    concanate := temp_temp(19 downto 8) & b"0000" & x"0"; --& temp_temp(3 downto 0);
                    add_one := x"00100";
                    over := x"000A0";
                    add_val := std_logic_vector(unsigned(add_one) + unsigned(temp_temp(7 downto 0)) - unsigned(over));
                    temp_temp := std_logic_vector(unsigned(concanate) + unsigned(add_val));
                end if;
          
                if unsigned(temp_temp(11 downto 8)) >= 10 then
                    concanate := temp_temp(19 downto 12) & b"0000" & x"00"; --& temp_temp(7 downto 0);
                    add_one := x"01000";
                    over := x"00A00";
                    add_val := std_logic_vector(unsigned(add_one) + unsigned(temp_temp(11 downto 0)) - unsigned(over));
                    temp_temp := std_logic_vector(unsigned(concanate) + unsigned(add_val));
                end if;
       
                if unsigned(temp_temp(15 downto 12)) >= 10 then
                    concanate := temp_temp(19 downto 16) & b"0000" & x"000";--& temp_temp(11 downto 0);
                    add_one := x"10000";
                    over := x"0A000";
                    add_val := std_logic_vector(unsigned(add_one) + unsigned(temp_temp(15 downto 0)) - unsigned(over));
                    temp_temp := std_logic_vector(unsigned(concanate) + unsigned(add_val));
                end if;
            end if;
        end loop;

        temp_dec <= temp_data_mod(12) & temp_temp;
    end process to_dec;
    
    
end architecture rtl;