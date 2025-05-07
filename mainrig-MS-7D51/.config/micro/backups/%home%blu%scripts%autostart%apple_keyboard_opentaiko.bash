def send_key(key):
    """Send a key press event to the OpenTaiko window."""
    # Using direct window ID targeting for faster response
    global TARGET
    command = f"xdotool key --window {TARGET} {key}"
    print(f"Sending: {key}")
    subprocess.call(command, shell=True, stderr=subprocess.DEVNULL)#!/usr/bin/env python3
import sys
import subprocess
import time
import threading
import os
from evdev import InputDevice, ecodes, UInput, categorize

# Device path for the Apple Magic Keyboard
DEV_PATH = '/dev/input/by-id/usb-Apple_Inc._Magic_Keyboard_F0T2477RPER18DTAN-if01-event-kbd'

# Autorepeat settings
REPEAT_DELAY = 0.15    # Time in seconds before autorepeat starts (much shorter for snappier response)
REPEAT_INTERVAL = 0.03  # Time between repeated keystrokes (faster repeat rate)

# Track which keys are currently being held down
keys_held = {}
stop_threads = {}
repeat_threads = {}

# Special key mapping for xdotool
SPECIAL_KEYS = {
    'KEY_BACKSPACE': 'BackSpace',
    'KEY_ENTER': 'Return',
    'KEY_ESCAPE': 'Escape',
    'KEY_TAB': 'Tab',
    'KEY_ESC': 'Escape',
}

# System control keys that should NOT be sent to OpenTaiko
SYSTEM_KEYS = {
    'KEY_VOLUMEDOWN', 'KEY_VOLUMEUP', 'KEY_MUTE',
    'KEY_BRIGHTNESSDOWN', 'KEY_BRIGHTNESSUP',
    'KEY_PLAYPAUSE', 'KEY_PREVIOUSSONG', 'KEY_NEXTSONG',
    'KEY_POWER', 'KEY_SLEEP', 'KEY_WAKEUP',
    'KEY_MEDIA', 'KEY_MAIL', 'KEY_CALC', 'KEY_COMPUTER',
    'KEY_PRINT', 'KEY_EJECTCD', 'KEY_WWW'
}

# Global variables
TARGET = None
ui = None

def get_key_name(key_code):
    """Safely get the key name, handling cases where it might be a tuple."""
    try:
        key = ecodes.KEY[key_code]
        
        # Handle case where it returns a tuple
        if isinstance(key, tuple):
            print(f"DEBUG: Key code {key_code} returned tuple: {key}")
            return key[0]  # Take the first element
        
        # Normal string case
        return key
    except Exception as e:
        print(f"DEBUG: Error getting key name for code {key_code}: {e}")
        return f"UNKNOWN_{key_code}"

def pass_through_key(key_code, value):
    """Pass a key event through to the host system using uinput."""
    try:
        # We'll use the UInput from evdev to create a virtual input device
        # that can send events to the system
        global ui
        if ui is None:
            print("Creating virtual input device for pass-through")
            # Get capabilities from the original device
            capabilities = {}
            capabilities[ecodes.EV_KEY] = [key_code]  # Just the key we need
            ui = UInput(capabilities, name="OpenTaiko-PassThrough")
        
        # Send the event to the system
        ui.write(ecodes.EV_KEY, key_code, value)
        ui.syn()
        print(f"Passed through key: code {key_code}, value {value}")
        return True
    except Exception as e:
        print(f"Failed to pass through key: {e}")
        return False

def key_repeater(key):
    """Function that runs in a thread to handle auto-repeating a key."""
    # First wait for the initial delay - using smaller check intervals for faster response
    for _ in range(int(REPEAT_DELAY / 0.005)):
        time.sleep(0.005)
        if key in stop_threads and stop_threads[key]:
            return
    
    # Then start repeating at the specified interval
    while key in keys_held and keys_held[key]:
        send_key(key)
        # Smaller sleep increment for more responsive key release detection
        for _ in range(int(REPEAT_INTERVAL / 0.005)):
            time.sleep(0.005)
            if key in stop_threads and stop_threads[key]:
                return

def main():
    global keys_held, stop_threads, repeat_threads, TARGET, ui
    ui = None
    
    try:
        # Ungrab the device first to release it
        try:
            dev = InputDevice(DEV_PATH)
            dev.ungrab()
            print("Previous device ungrabbed")
        except:
            print("No previous device to ungrab")
            pass
            
        # Open the device
        dev = InputDevice(DEV_PATH)
        
        # Grab the device
        dev.grab()
        print("Device grabbed successfully!")
    except Exception as e:
        print(f"❌ Failed to grab the device {DEV_PATH}: {e}")
        sys.exit(1)

    # Cache the OpenTaiko window ID
    try:
        win_ids = subprocess.check_output(
            ['xdotool', 'search', '--name', 'OpenTaiko.*']
        ).decode().split()
        TARGET = win_ids[0]
        print(f"🎯 Target window: {TARGET}")
    except Exception as e:
        print(f"❌ Couldn't find OpenTaiko window: {e}")
        dev.ungrab()
        sys.exit(1)

    # Focus the OpenTaiko window once at the start and raise it to the front
    subprocess.call(['xdotool', 'windowfocus', TARGET], stderr=subprocess.DEVNULL)
    subprocess.call(['xdotool', 'windowraise', TARGET], stderr=subprocess.DEVNULL)
    print("OpenTaiko window focused and raised.")

    try:
        for e in dev.read_loop():
            try:
                if e.type == ecodes.EV_KEY:
                    key_code = e.code
                    key_name = get_key_name(key_code)
                    
                    # Print debug info for all keys
                    print(f"DEBUG: Key event - code:{key_code}, name:{key_name}, value:{e.value}")
                    
                    # Check if this is a system control key that should be ignored for OpenTaiko
                    # but passed through to the host system
                    if key_name in SYSTEM_KEYS:
                        print(f"System key detected: {key_name} - passing through to host")
                        # Pass the original event through to the host
                        pass_through_key(key_code, e.value)
                        continue
                    
                    # Default xdotool key name
                    xdotool_key = key_name
                    
                    # Format the key for xdotool
                    if isinstance(key_name, str) and key_name.startswith('KEY_'):
                        name_without_prefix = key_name[4:]  # Remove 'KEY_' prefix
                        
                        if key_name in SPECIAL_KEYS:
                            xdotool_key = SPECIAL_KEYS[key_name]
                        elif name_without_prefix == 'BACKSPACE':
                            xdotool_key = 'BackSpace'
                        elif name_without_prefix == 'ESCAPE' or name_without_prefix == 'ESC':
                            xdotool_key = 'Escape'
                        else:
                            xdotool_key = name_without_prefix.capitalize()
                    
                    print(f"Processed key: {key_name} -> {xdotool_key}")
                    
                    if e.value == 1:  # Key down event
                        print(f"Detected key down: {xdotool_key}")
                        
                        # Send the key immediately
                        send_key(xdotool_key)
                        
                        # Set up for autorepeat
                        keys_held[xdotool_key] = True
                        stop_threads[xdotool_key] = False
                        
                        # Start a thread for this key's autorepeat
                        repeat_thread = threading.Thread(target=key_repeater, args=(xdotool_key,))
                        repeat_threads[xdotool_key] = repeat_thread
                        repeat_thread.daemon = True
                        repeat_thread.start()
                        
                    elif e.value == 0:  # Key up event
                        print(f"Detected key up: {xdotool_key}")
                        
                        # Stop any auto-repeat for this key
                        keys_held[xdotool_key] = False
                        stop_threads[xdotool_key] = True
                        
                        # Clean up the thread reference
                        if xdotool_key in repeat_threads:
                            repeat_threads[xdotool_key] = None
            except Exception as ex:
                print(f"Error processing event: {ex}")
                print(f"Event data: type={e.type}, code={e.code}, value={e.value}")
                
    except KeyboardInterrupt:
        print("Interrupted by user")
    except Exception as ex:
        print(f"Main loop error: {ex}")
    finally:
        # Clean up
        try:
            # Close virtual input device if it exists
            if ui is not None:
                ui.close()
                print("Virtual input device closed")
                
            # Ungrab to make sure the keyboard is released back to the system
            dev.ungrab()
            print("Device ungrabbed successfully")
        except:
            print("Note: Could not clean up resources properly")
            
        print("🛑 Stopped")
        sys.stdout.flush()

if __name__ == "__main__":
    main()
