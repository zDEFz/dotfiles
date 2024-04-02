import os

# block character
block = u"\u2588"

# get disk usage
disk = int(os.popen("df -h --output='pcent' / | tail -n1 | tr -s ' ' | tr -s '\n'").read()[:-2])

# round up the number of blocks
used = round(float(disk)/10)

# print blocks
string = "[" + block*used + " "*(10-used) + "] " + str(disk) + "%"
print(string)
