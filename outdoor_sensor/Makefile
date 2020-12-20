compile: outdoor_sensor.ino
	arduino-cli compile --fqbn arduino:avr:nano:cpu=atmega328old outdoor_sensor.ino
upload: outdoor_sensor.ino compile
	arduino-cli upload -p /dev/ttyUSB0 --fqbn arduino:avr:nano:cpu=atmega328old outdoor_sensor.ino
