#!/bin/bash

# Function to pause the currently active window
stop_window() {
    xdocurpid=$(xdotool getactivewindow getwindowpid)
    kill -STOP "$xdocurpid"
}

# Function to resume the currently active window
resume_window() {
    xdocurpid=$(xdotool getactivewindow getwindowpid)
    kill -CONT "$xdocurpid"
}

# Toggle between pausing and resuming the window based on argument
toggle_window() {
    xdocurpid=$(xdotool getactivewindow getwindowpid)
    
    # window_name=$(xdotool getactivewindow getwindowname)
    # if [ "$window_name" == "Cultris II" ]; then
    #     kill -CONT "$pid"
    #     echo "Window paused."
    # else
    #     kill -CONT "$pid"
    #     echo "Window resumed."
    # fi
    
    if [ "$(ps -o state= -p "$xdocurpid")" == "T" ]; then
        kill -CONT "$xdocurpid"
        echo "Window resumed."
    else
        kill -STOP "$xdocurpid"
        echo "Window paused."
    fi
}

# Check for argument and call respective function
if [ "$1" == "stop" ]; then
    stop_window
    elif [ "$1" == "resume" ]; then
    resume_window
    elif [ "$1" == "toggle" ]; then
    toggle_window
else
    echo "Invalid argument. Usage: $0 [stop|resume|toggle]"
    exit 1
fi
