#!/bin/bash

# Get disk I/O statistics using iostat
io_stats=$(iostat -d -k -x 1 2 | grep -E '^nvme0n1' | tail -n 1)

# Extract read and write operations per second
read_ops=$(echo "$io_stats" | awk '{print $4}')
write_ops=$(echo "$io_stats" | awk '{print $5}')

# Display the results
echo "R: $read_ops/s W: $write_ops/s"
