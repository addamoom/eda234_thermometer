vsim work.tb_w433_interface

add wave -position insertpoint  \
sim:/tb_w433_interface/DUT/Clk_10us \
sim:/tb_w433_interface/DUT/Reset_n \
sim:/tb_w433_interface/DUT/get_sample \
sim:/tb_w433_interface/DUT/data_in \
sim:/tb_w433_interface/DUT/Temp_out \
sim:/tb_w433_interface/DUT/sample_done \
sim:/tb_w433_interface/DUT/clock_counter \
sim:/tb_w433_interface/DUT/bit_counter \
sim:/tb_w433_interface/DUT/Receiver_state \
sim:/tb_w433_interface/DUT/temp_reg \
sim:/tb_w433_interface/DUT/key_reg \
sim:/tb_w433_interface/DUT/PSK


run 250ms