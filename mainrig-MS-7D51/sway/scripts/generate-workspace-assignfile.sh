# #!/bin/bash

# # Define the starting values
# start_num=1
# end_num=500

# # Loop to generate the sequence
# for ((i = "$start_num"; i <= "$end_num"; i++)); do
#     echo "### ws$(printf "%02d" $i)-L ($(("$i" * 2 - 1)))"
#     echo -e "\t"
#     echo "### ws$(printf "%02d" $i)-R ($(("$i" * 2)))"
#     echo -e "\t"
# done

### ws01-L (1)
	
### ws01-R (2)
	
### ws02-L (3)
	
### ws02-R (4)
	
### ws03-L (5)


#!/bin/bash

# Define the starting values
start_num=1
end_num=500

# Loop to generate the sequence for 4 outputs (LL, L, M, R)
for ((i = "$start_num"; i <= "$end_num"; i++)); do
    echo "### ws$(printf "%02d" $i)-LL ($(("$i" * 4 - 3)))"
    echo -e "\t"

    echo "### ws$(printf "%02d" $i)-L ($(("$i" * 4 - 2)))"
    echo -e "\t"

    echo "### ws$(printf "%02d" $i)-M ($(("$i" * 4 - 1)))"
    echo -e "\t"

    echo "### ws$(printf "%02d" $i)-R ($(("$i" * 4)))"
    echo -e "\t"
done
