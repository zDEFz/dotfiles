#!/bin/bash
#radeontop -d - | grep -oP 'mclk \K\d+\.\d+%'
#radeontop -d - | grep -oP 'mclk \K\d+\.\d+%' | sed 's/$/\n/'
#radeontop -d - | grep -oP 'mclk \K\d+\.\d+%' | awk '{print $0"\n"}'
radeontop -d - | grep -oP 'mclk \K\d+\.\d+%' | sed 's/.*/&\n/'
