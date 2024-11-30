#!/bin/bash

# Define the starting values
start_num=1
end_num=100
counter=1  # Add a counter to track the values

# Loop to generate the sequence for 7 outputs (LL, L, M, R, RR, TAIKO, MON_KB)
for ((i = "$start_num"; i <= "$end_num"; i++)); do
    # LL
    echo "### ws$(printf "%02d" $i)-LL ($counter)"
    echo -e "\t"
    ((counter++))

    # L
    echo "### ws$(printf "%02d" $i)-L ($counter)"
    echo -e "\t"
    ((counter++))

    # M
    echo "### ws$(printf "%02d" $i)-M ($counter)"
    echo -e "\t"
    ((counter++))

    # R
    echo "### ws$(printf "%02d" $i)-R ($counter)"
    echo -e "\t"
    ((counter++))

    # RR
    echo "### ws$(printf "%02d" $i)-RR ($counter)"
    echo -e "\t"
    ((counter++))

    # TAIKO
    echo "### ws$(printf "%02d" $i)-TAIKO ($counter)"
    echo -e "\t"
    ((counter++))

    # MON_KB
    echo "### ws$(printf "%02d" $i)-MON_KB ($counter)"
    echo -e "\t"
    ((counter++))
done
