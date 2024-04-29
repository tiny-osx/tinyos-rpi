#!/bin/bash

# Abort script if any command returns error
set -e

sudo minicom -D /dev/ttyACM0 -b 115200
