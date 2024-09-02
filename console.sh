#!/bin/bash

# Abort script if any command returns error
set -e

# BLACK => GND
# GREEN => GPIO 14 (TX)
# WHITE => GPIO 15 (RX) 

sudo picocom /dev/ttyUSB0 -b 115200

# Raspberry Pi Debug Probe Kit 
# sudo picocom /dev/ttyACM0 -b 115200

# sudo minicom -o -D /dev/ttyACM0 -b 115200