#!/bin/bash

# Configuration
LOG_FILE="/var/log/sddm-setup-debug.log"
XSETUP_CUSTOM="/usr/share/sddm/scripts/Xsetup_custom"
SDDM_CONF="/etc/sddm.conf.d/kde_settings.conf"

echo "--- SDDM Pro Diagnostic & Setup ---"
echo "Logging to $LOG_FILE"

# 1. Root Check
[[ $EUID -ne 0 ]] && echo "Please run as root." && exit 1

# 2. Comprehensive Diagnostic Function
{
    echo "=== Diagnostic Run: $(date) ==="
    echo "Current User: $USER"
    echo "Kernel: $(uname -r)"
    
    # Check for SDDM config conflicts
    echo "Checking SDDM config files..."
    grep -r "DisplayCommand" /etc/sddm.conf*
    
    # Try to find connected monitors using xrandr
    # We use a subshell to try and find an active X session to query
    echo "Detecting connected monitors..."
    export DISPLAY=:0
    # Try to grab the SDDM xauth file to allow xrandr to query the hardware
    AUTH_FILE=$(find /var/run/sddm/ -type f | head -n 1)
    if [ -n "$AUTH_FILE" ]; then
        export XAUTHORITY="$AUTH_FILE"
        echo "Found Auth: $XAUTHORITY"
        xrandr --query | grep " connected"
    else
        echo "Warning: Could not find SDDM Xauthority. Auto-detection might be limited."
    fi
} > "$LOG_FILE" 2>&1

# 3. Create the Smart Xsetup Script
echo "Generating $XSETUP_CUSTOM..."
cat << 'EOF' > "$XSETUP_CUSTOM"
#!/bin/bash
# Log start
exec > /var/log/sddm-xsetup-execution.log 2>&1
echo "Xsetup started at $(date)"

# Wait for X server
sleep 3
export DISPLAY=:0

# Auto-locate XAUTHORITY
AUTH_FILE=$(find /var/run/sddm/ -type f | head -n 1)
if [ -n "$AUTH_FILE" ]; then
    export XAUTHORITY="$AUTH_FILE"
    echo "Using XAUTHORITY: $AUTH_FILE"
fi

# Apply Layout
# Note: Using your specific coordinates
echo "Applying xrandr layout..."
xrandr --output DP-1 --mode 1920x1080 --pos 2160x570 --rotate normal \
       --output DP-2 --mode 1920x1080 --pos 1080x460 --rotate left \
       --output DP-3 --mode 1920x1080 --pos 4080x470 --rotate left \
       --output DP-4 --mode 1920x1080 --pos 2160x1650 --rotate inverted

echo "xrandr exit code: $?"
EOF

chmod 755 "$XSETUP_CUSTOM"

# 4. Force SDDM Config Priority
echo "Applying SDDM configuration..."
mkdir -p /etc/sddm.conf.d
# We use '99-z-custom.conf' to ensure it is the LAST file read (highest priority)
PRIORITY_CONF="/etc/sddm.conf.d/99-z-custom-layout.conf"

cat <<EOF > "$PRIORITY_CONF"
[X11]
DisplayCommand=$XSETUP_CUSTOM
EOF

echo "Done."
echo "1. Restart SDDM: systemctl restart sddm"
echo "2. If it fails, check: /var/log/sddm-xsetup-execution.log"
