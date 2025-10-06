#!/bin/bash
apcaccess | awk -F':' '
/TIMELEFT/ {
  split($2, a, " ")
  mins   = a[1] + 0
  watts  = 11336 / mins + 40
}
/BCHARGE/ {
  gsub(/[^0-9.]/, "", $2)
  charge = $2 + 0
}
END {
  # Print: watts|min|percent% chg
  printf("%.0fW|%.1fmin|%.1f%%chg\n", watts, mins, charge)
}'
