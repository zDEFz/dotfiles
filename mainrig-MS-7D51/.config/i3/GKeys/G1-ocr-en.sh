#!/bin/bash
echo "Running OCR"; TESSDATA_PREFIX=/usr/share/tessdata maim -s | tesseract stdin stdout --dpi 300 --psm 6 | xclip -selection clipboard
