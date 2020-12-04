LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY LCD_to_Ascii IS
 PORT(
	data: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	out_data_ascii: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
);

END LCD_to_Ascii;

ARCHITECTURE LCD_to_Ascii_arch OF LCD_to_Ascii IS

 signal data_signal : STD_LOGIC_VECTOR(3 DOWNTO 0);
 signal data_out_signal : STD_LOGIC_VECTOR(7 DOWNTO 0);

 BEGIN
 data_signal <= data;

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

  WITH data_signal SELECT
     data_out_signal <= x"30" WHEN "0000", --0
			x"31" WHEN "0001", --1
			x"32" WHEN "0010",--2
			x"33" WHEN "0011", --3
			x"34" WHEN "0100", --4
			x"35" WHEN "0101", --5
			x"36" WHEN "0110", --6
			x"37" WHEN "0111", --7
			x"38" WHEN "1000", --8
			x"39" WHEN "1001", --9
			x"18" WHEN others;--up arow

  out_data_ascii <=  data_out_signal;

END LCD_to_Ascii_arch;
