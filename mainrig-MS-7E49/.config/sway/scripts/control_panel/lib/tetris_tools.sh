#!/bin/bash

# menu: Tetris Tools | 🎵 Activate 1kf Sounds
1kf_sounds() { 
    local pid_file="/tmp/1kf_sounds.pid"

    if ! command -v play &> /dev/null || ! command -v libinput &> /dev/null; then
        echo "❌ Please install dependencies: sudo pacman -S sox libinput-tools"
        return 1
    fi

    echo "🚀 1kf Sound Orientation Active [Bulma's Spaceship Computer]"
    echo "📟 System Status: ONLINE"
    echo "🛡️ Boundary Guard: Enabled (Strict Matrix Only)"

    (
        declare -A FREQS=(
            [KEY_1]=400 [KEY_2]=444 [KEY_3]=488 [KEY_4]=533 [KEY_5]=577
            [KEY_6]=622 [KEY_7]=666 [KEY_8]=711 [KEY_9]=755 [KEY_0]=800
            [KEY_Q]=450 [KEY_W]=494 [KEY_E]=538 [KEY_R]=583 [KEY_T]=627
            [KEY_Y]=672 [KEY_U]=716 [KEY_I]=761 [KEY_O]=805 [KEY_P]=850
            [KEY_A]=500 [KEY_S]=544 [KEY_D]=588 [KEY_F]=633 [KEY_G]=677
            [KEY_H]=722 [KEY_J]=766 [KEY_K]=811 [KEY_L]=855 [KEY_SEMICOLON]=900
            [KEY_Z]=550 [KEY_X]=594 [KEY_C]=638 [KEY_V]=683 [KEY_B]=727
            [KEY_N]=772 [KEY_M]=816 [KEY_COMMA]=861 [KEY_DOT]=905 [KEY_SLASH]=950
        )

        RATE=22050
        BITS=16
        CHANNELS=1
        DURATION=0.055
        FADE_IN=0.003
        FADE_OUT=0.012

        libinput debug-events --show-keycodes | while read -r line; do
            if [[ "$line" == *"pressed"* ]]; then
                key=$(echo "$line" | grep -oP 'KEY_[A-Z0-9_]+')
                if [[ -n "$key" && -n "${FREQS[$key]}" ]]; then
                    freq="${FREQS[$key]}"
                    play -q -r $RATE -b $BITS -c $CHANNELS -n synth $DURATION sine "$freq" tremolo 8 40 fade t $FADE_IN $DURATION $FADE_OUT gain -8 echo 0.8 0.7 10 0.3 lowpass 6000 &
                elif [[ "$key" == "KEY_SPACE" ]]; then
                    play -q -r $RATE -b $BITS -c $CHANNELS -n synth 0.08 sine 500:600 fade t 0.005 0.08 0.02 gain -9 echo 0.8 0.7 12 0.3 lowpass 5000 &
                elif [[ "$key" == "KEY_RIGHTSHIFT" ]]; then
                    (play -q -r $RATE -b $BITS -c $CHANNELS -n synth 0.05 sine 1000 fade t 0.002 0.05 0.01 gain -9 echo 0.8 0.7 10 0.3 lowpass 6000 ; \
                     play -q -r $RATE -b $BITS -c $CHANNELS -n synth 0.05 sine 800 fade t 0.002 0.05 0.012 gain -9 echo 0.8 0.7 10 0.3 lowpass 6000) &
                fi
            fi
        done
    ) &
    
    echo $! > "$pid_file"
    disown $!
}

# menu: Tetris Tools | 🔇 Stop 1kf Sounds
stop_1kf_sounds() {
    local pid_file="/tmp/1kf_sounds.pid"

    echo "🔌 Deactivating Spaceship Computer..."
    
    if [ -f "$pid_file" ]; then
        local saved_pid=$(cat "$pid_file")
        # Kill the subshell process and all children
        pkill -P "$saved_pid" 2>/dev/null
        kill "$saved_pid" 2>/dev/null
        rm "$pid_file"
    fi

    # Hard cleanup for libinput and audio
    pkill -f "libinput debug-events"
    pkill -u "$USER" play
    
    echo "💤 System Status: OFFLINE"
}


"$@"
