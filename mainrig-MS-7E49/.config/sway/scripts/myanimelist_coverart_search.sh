#!/bin/bash

# Check if required tools are installed
for cmd in jq curl swayimg magick; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: $cmd is required but not installed."
        if [[ "$cmd" == "magick" ]]; then
            echo "Install with: sudo pacman -S imagemagick (Arch) or sudo apt install imagemagick (Ubuntu/Debian)"
        fi
        exit 1
    fi
done

# Check if search term provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <anime_search_term or file path>"
    echo "Example: $0 \"Attack on Titan\""
    exit 1
fi

# Configuration
TEMP_DIR="/tmp/anime_covers"

input="$*"

# If input is a file path, extract the base name without extension for search
if [[ -f "$input" ]]; then
    filename=$(basename -- "$input")
    search_term="${filename%.*}"
else
    search_term="$input"
fi

echo "DEBUG: search_term='$search_term'"

# URL encode the search term
encoded_title=$(jq -nr --arg v "$search_term" '$v|@uri')

echo "DEBUG: encoded_title='$encoded_title'"

# Create temp directory
mkdir -p "$TEMP_DIR"

# Cleanup function
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

echo "Searching for: $search_term"

# Search MyAnimeList API
response=$(curl -s "https://api.jikan.moe/v4/anime?q=${encoded_title}&limit=5")

# Check if we got results
if [ -z "$response" ] || [ "$(echo "$response" | jq -r '.data | length')" -eq 0 ]; then
    echo "No anime found for: $search_term"
    exit 1
fi

# Show search results
echo "Found anime(s):"
echo "$response" | jq -r '.data[] | "\(.mal_id): \(.title) (\(.year // "N/A")) - Score: \(.score // "N/A")"' | head -5

# Get the first result details
mal_title=$(echo "$response" | jq -r '.data[0].title')
mal_score=$(echo "$response" | jq -r '.data[0].score')
mal_year=$(echo "$response" | jq -r '.data[0].year')
mal_episodes=$(echo "$response" | jq -r '.data[0].episodes')
mal_status=$(echo "$response" | jq -r '.data[0].status')
mal_type=$(echo "$response" | jq -r '.data[0].type')
image_url=$(echo "$response" | jq -r '.data[0].images.jpg.large_image_url')
synopsis=$(echo "$response" | jq -r '.data[0].synopsis')

echo ""
echo "Selected: $mal_title ($mal_year)"
echo "Score: $mal_score"
echo ""

# Sanitize filename for output (replace spaces and slashes)
safe_name=$(echo "$search_term" | tr ' /' '__')
fancy_image="$TEMP_DIR/${safe_name}.png"

# Function to wrap text for ImageMagick
wrap_text() {
    local text="$1"
    local width="$2"
    echo "$text" | fold -s -w "$width"
}

# Download and create fancy display
if [ "$image_url" != "null" ] && [ -n "$image_url" ]; then
    original_image="$TEMP_DIR/original_cover.jpg"
    background_image="$TEMP_DIR/background.png"
    text_overlay="$TEMP_DIR/text_overlay.png"

    echo "Downloading cover..."
    if curl -s -L "$image_url" -o "$original_image"; then
        echo "Creating fancy display..."

        # Prepare text info with improved dynamic font sizing
        title_text="$mal_title"
        [ "$mal_year" != "null" ] && info_line1="Year: $mal_year" || info_line1="Year: Unknown"
        [ "$mal_score" != "null" ] && info_line2="⭐ Score: $mal_score/10" || info_line2="⭐ Score: Not rated"
        [ "$mal_episodes" != "null" ] && info_line3="Episodes: $mal_episodes" || info_line3="Episodes: Unknown"
        [ "$mal_type" != "null" ] && info_line4="Type: $mal_type" || info_line4="Type: Unknown"
        [ "$mal_status" != "null" ] && info_line5="Status: $mal_status" || info_line5="Status: Unknown"

        # Dynamic title font size based on length
        title_length=${#title_text}
        if [ $title_length -le 10 ]; then
            title_size=56
        elif [ $title_length -le 15 ]; then
            title_size=48
        elif [ $title_length -le 25 ]; then
            title_size=42
        elif [ $title_length -le 35 ]; then
            title_size=36
        elif [ $title_length -le 45 ]; then
            title_size=30
        else
            title_size=26
        fi

        info_size=26

        # Synopsis sizing and wrapping
        if [ "$synopsis" != "null" ] && [ ${#synopsis} -gt 400 ]; then
            synopsis_text="${synopsis:0:380}..."
            synopsis_size=22
            synopsis_wrap=48
        elif [ "$synopsis" != "null" ] && [ ${#synopsis} -gt 250 ]; then
            synopsis_text="$synopsis"
            synopsis_size=24
            synopsis_wrap=50
        elif [ "$synopsis" != "null" ] && [ ${#synopsis} -gt 150 ]; then
            synopsis_text="$synopsis"
            synopsis_size=26
            synopsis_wrap=52
        else
            synopsis_text="$synopsis"
            synopsis_size=28
            synopsis_wrap=55
        fi

        # Create background gradient
        magick -size 1400x700 \
               -define gradient:direction=SouthEast \
               gradient:'#0f0f23'-'#1a1a2e' \
               "$background_image"

        # Resize cover with border
        magick "$original_image" \
               -resize 400x580 \
               -bordercolor '#333' \
               -border 5x5 \
               "$TEMP_DIR/resized_cover.jpg"

        # Create text overlay
        magick -size 900x700 xc:transparent \
               -fill white \
               -font DejaVu-Sans-Bold \
               -pointsize $title_size \
               -annotate +20+60 "$title_text" \
               -fill '#ff6b6b' \
               -font DejaVu-Sans-Bold \
               -pointsize 18 \
               -annotate +20+110 "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" \
               -fill '#4ecdc4' \
               -font DejaVu-Sans \
               -pointsize $info_size \
               -annotate +20+150 "📅 $info_line1" \
               -fill '#45b7d1' \
               -annotate +20+185 "$info_line2" \
               -fill '#96ceb4' \
               -annotate +20+220 "📺 $info_line3" \
               -fill '#ffeaa7' \
               -annotate +20+255 "🎬 $info_line4" \
               -fill '#fd79a8' \
               -annotate +20+290 "📊 $info_line5" \
               -fill '#74b9ff' \
               -font DejaVu-Sans-Bold \
               -pointsize 24 \
               -annotate +20+340 "SYNOPSIS:" \
               "$text_overlay"

        # Add wrapped synopsis text
        if [ "$synopsis_text" != "null" ] && [ -n "$synopsis_text" ]; then
            echo "$synopsis_text" | fold -s -w $synopsis_wrap > "$TEMP_DIR/synopsis.txt"
            y_pos=375
            line_spacing=$((synopsis_size + 8))
            while IFS= read -r line; do
                magick "$text_overlay" \
                       -fill '#ddd' \
                       -font DejaVu-Sans \
                       -pointsize $synopsis_size \
                       -annotate +20+$y_pos "$line" \
                       "$text_overlay"
                y_pos=$((y_pos + line_spacing))
                [ $y_pos -gt 660 ] && break
            done < "$TEMP_DIR/synopsis.txt"
        fi

        # Composite final image
        magick "$background_image" \
               \( "$TEMP_DIR/resized_cover.jpg" -geometry +50+60 \) \
               -composite \
               \( "$text_overlay" -geometry +480+0 \) \
               -composite \
               "$fancy_image"

        if [ $? -eq 0 ]; then
            echo "Opening fancy display in swayimg..."
            echo "Press 'i' to toggle info display on/off"
            swayimg "$fancy_image" 2>/dev/null
        else
            echo "Failed to create fancy image, showing original..."
            echo "Press 'i' to toggle info display on/off"
            swayimg "$original_image" 2>/dev/null
        fi
    else
        echo "Failed to download cover image"
        exit 1
    fi
else
    echo "No cover image available"
    exit 1
fi
