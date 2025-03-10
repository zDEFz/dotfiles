#!/bin/bash

# Function to perform OCR on a selected portion of the screen
ocr-en() {
    echo "Running OCR"
    export TESSDATA_PREFIX=/usr/share/tessdata
    maim -s /tmp/screenshot.png || { echo "Error capturing screen"; exit 1; }
    tesseract /tmp/screenshot.png /tmp/ocr_result || { echo "Error performing OCR"; exit 1; }
    xclip -selection clipboard /tmp/ocr_result.txt || { echo "Error copying text to clipboard"; exit 1; }
    rm -f /tmp/screenshot.png /tmp/ocr_result.txt
}

# Redirect stdout and stderr to a log file
#exec &> /tmp/ocr_log.txt

# Call the OCR function
ocr-en
