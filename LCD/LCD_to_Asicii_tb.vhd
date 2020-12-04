LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;


ENTITY LCD_to_Asicii_tb IS
END LCD_to_Asicii_tb;


ARCHITECTURE LCD_to_Asicii_tb_arch OF LCD_to_Asicii_tb IS
	COMPONENT LCD_to_Ascii IS
	 PORT(
	data: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	out_data_ascii: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
);
	END COMPONENT LCD_to_Ascii;


	signal data_tb : STD_LOGIC_VECTOR(3 DOWNTO 0):="0000";
	signal out_data_ascii_tb: STD_LOGIC_VECTOR(7 DOWNTO 0):="00000000";

BEGIN

	LCD_to_Ascii_comp:
		COMPONENT LCD_to_Ascii
		PORT MAP(
				data =>data_tb ,
				out_data_ascii=>out_data_ascii_tb);

	data_tb <= "0000",--0
		   "0001" after 20 ns,--1
		   "0010" after 40 ns,--2
		   "0011" after 60 ns,--3
		   "0100" after 80 ns,--4
		   "0101" after 100 ns,--5
		   "0110" after 120 ns, --6
		   "0111" after 140 ns, --7
		   "1000" after 160 ns, --8
		   "1001" after 180 ns;
END LCD_to_Asicii_tb_arch;
