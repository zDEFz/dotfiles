#!/usr/bin/env python3

import re
import tkinter as tk
from tkinter import colorchooser
import subprocess

def parse_i3blocks_conf(conf_file):
    blocks = {}
    with open(conf_file, 'r') as f:
        current_block = None
        for line in f:
            match = re.match(r'^\[(.*)\]$', line.strip())
            if match:
                current_block = match.group(1)
                blocks[current_block] = {}
            elif current_block:
                key_value = line.strip().split('=')
                if len(key_value) == 2:
                    key, value = key_value
                    blocks[current_block][key.strip()] = value.strip()
    return blocks

def rgb_to_hex(rgb):
    # Convert RGB string to hexadecimal color representation
    return '#{:02x}{:02x}{:02x}'.format(int(rgb[0]), int(rgb[1]), int(rgb[2]))

def save_color(block, color):
    with open('/home/blu/.config/i3blocks/i3blocks.conf', 'r') as f:
        lines = f.readlines()

    with open('/home/blu/.config/i3blocks/i3blocks.conf', 'w') as f:
        within_block = False
        for line in lines:
            if line.startswith(f"[{block}]"):
                within_block = True
                f.write(line)
                f.write(f"color={color}\n")
            elif within_block and line.strip().startswith('['):
                within_block = False
            else:
                f.write(line)

    print(f"Saved color for {block}: {color}")

    with open('/home/blu/.config/i3blocks/i3blocks.conf', 'r') as f:
        lines = f.readlines()

    with open('/home/blu/.config/i3blocks/i3blocks.conf', 'w') as f:
        within_block = False
        block_found = False
        for line in lines:
            if line.startswith(f"[{block}]"):
                within_block = True
                block_found = True
                f.write(line)
                f.write(f"color={color}\n")
            elif within_block and line.strip().startswith('['):
                within_block = False
            else:
                if not block_found:
                    f.write(line)

    print(f"Saved color for {block}: {color}")

    with open('/home/blu/.config/i3blocks/i3blocks.conf', 'r') as f:
        lines = f.readlines()

    with open('/home/blu/.config/i3blocks/i3blocks.conf', 'w') as f:
        within_block = False
        for line in lines:
            if line.startswith(f"[{block}]"):
                within_block = True
                f.write(line)
                f.write(f"color={color}\n")
            elif within_block and line.strip().startswith('['):
                within_block = False
            else:
                if not within_block:
                    f.write(line)

    print(f"Saved color for {block}: {color}")

    with open('/home/blu/.config/i3blocks/i3blocks.conf', 'r') as f:
        lines = f.readlines()

    with open('/home/blu/.config/i3blocks/i3blocks.conf', 'w') as f:
        found_block = False
        block_found = False
        within_block = False
        for line in lines:
            if line.strip().startswith('['):
                if within_block:
                    within_block = False
                if block_found:
                    # If we've found the block and reached the next block, stop writing
                    block_found = False
            if line.startswith(f"[{block}]"):
                found_block = True
                block_found = True
                within_block = True
                f.write(line)
                f.write(f"color={color}\n")
            elif found_block and within_block and line.strip() and '=' in line:
                key, value = line.strip().split('=')
                if key.strip() != 'color':
                    f.write(line)
            elif not block_found:
                f.write(line)

    print(f"Saved color for {block}: {color}")

def choose_color(blocks):
    chosen_colors = {}

    # Create a Tkinter window
    root = tk.Tk()
    root.withdraw()  # Hide the main window

    for block, config in blocks.items():
        # Get the current color for the block
        current_color = config.get('color', '#000000')

        # Let the user choose a color for the block
        print(f"Choosing color for block: {block}")
        color = colorchooser.askcolor(title=f"Choose Color for {block}", color=current_color)[1]

        # Check if the color selection was canceled
        if color is not None and isinstance(color, str) and color.startswith('#'):
            # Output the chosen color for the block
            chosen_colors[block] = color
            print(f"Selected color for {block}: {color}")
        else:
            # Use the default color
            default_color = '#000000'
            chosen_colors[block] = default_color
            print(f"Color selection canceled for {block}. Using default color: {default_color}")

    return chosen_colors

if __name__ == "__main__":
    # Path to the i3blocks configuration file
    conf_file = '/home/blu/.config/i3blocks/i3blocks.conf'

    # Parse the i3blocks configuration file to get the list of blocks
    blocks = parse_i3blocks_conf(conf_file)

    # Choose color for each block
    chosen_colors = choose_color(blocks)

    # Save chosen colors and reload i3blocks configuration
    for block, color in chosen_colors.items():
        save_color(block, color)

    # Reload i3blocks
    subprocess.run(['/home/blu/.config/i3/i3blocksreload.sh'])
