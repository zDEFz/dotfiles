#!/bin/bash

# --- 1. Define Path ---
USER_MON_CONF="/etc/sddm.conf.d/monitors.conf"

# --- 2. Ensure Directory Exists ---
sudo mkdir -p /etc/sddm.conf.d/

# --- 3. Writing the Config ---
# We use sudo tee to write to protected directories without escaping $
sudo tee "$USER_MON_CONF" > /dev/null << 'EOF'
# --- Hardware IDs ---
set {
    $L      'Iiyama North America PL2590HS 1219241201616'
    $LL     'Iiyama North America PL2590HS 1219241201677'
    $M      'BNQ ZOWIE XL LCD EBF2R02370SL0'
    $MON_KB 'Iiyama North America PL2590HS 1219241201302'
    $R      'BNQ ZOWIE XL LCD EBMCM01300SL0'
    $RR     'Iiyama North America PL2590HS 1219241201699'
    $TAIKO  'BNQ ZOWIE XL LCD EBX7M01214SL0'
}

# --- Geometry and Transforms ---
output $LL {
    mode 1920x1080@240Hz
    position 0 460
    transform 90
}

output $L {
    mode 1920x1080@240Hz
    position 1080 460
    transform 270
}

output $M {
    mode 1920x1080@240Hz
    position 2160 570
}

output $MON_KB {
    mode 1920x1080@240Hz
    position 2160 1650
    transform 180
}

output $R {
    mode 1920x1080@240Hz
    position 4080 470
    transform 270
}

output $RR {
    mode 1920x1080@240Hz
    position 5160 480
    transform 270
}
EOF

echo "Config saved to $USER_MON_CONF"
