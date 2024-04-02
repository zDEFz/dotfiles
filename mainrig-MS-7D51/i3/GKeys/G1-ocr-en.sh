#!/bin/bash
echo "Running ocr-en function"
export TESSDATA_PREFIX=/usr/share/tessdata 
scrot -s /tmp/screenshot.png
tesseract /tmp/screenshot.png /tmp/ocr_result
xclip -selection clipboard < /tmp/ocr_result.txt
rm -f /tmp/screenshot.png /tmp/ocr_result.txt
