
# menu: Print | 📋 Print System Specs
sys_print_specs() {
    # 1. Generate clean text
    # -c none: ignores your local config file
    # -l none: removes the logo/ascii art
    # --pipe: outputs raw text without colors/escape codes
    local TEXT
    TEXT=$(fastfetch -c none -l none --pipe --structure OS:Host:Kernel:Uptime:Packages:CPU:GPU:Memory)

    # 2. Copy to clipboard
    echo -n "$TEXT" | wl-copy

    # 3. Paste with a slight delay for Wayland stability
    sleep 0.2
    echo 'key ctrl+v' | dotoolc
}

