#!/bin/bash

# https://github.com/Ao1Pointblank/gummy-osd
# Usage Guide:
# 
# This script allows you to adjust brightness, backlight, and temperature settings using the gummy daemon, 
# and it also displays an on-screen display (OSD) notification.
# 
# Usage:
# ./gummy-osd.sh <mode> <direction>
# 
# Parameters:
# - <mode>: Specifies the setting to adjust. Available modes:
#   - brightness: Adjusts the screen brightness.
#   - backlight: Adjusts the screen backlight.
#   - temperature: Adjusts the screen color temperature.
# 
# - <direction>: Specifies the adjustment direction. Available directions:
#   - up: Increases the setting value.
#   - down: Decreases the setting value.
#   - reset: Resets the setting to its default value.
# 
# Examples:
# - Increase Brightness: ./gummy-osd.sh brightness up
# - Decrease Backlight: ./gummy-osd.sh backlight down
# - Reset Temperature to Default: ./gummy-osd.sh temperature reset
# 
# Notes:
# - Ensure the gummy daemon is installed and configured correctly: https://codeberg.org/fusco/gummy/
# - Assumes gdbus and gummy commands are available in your PATH.

# Define directories and files
DIR=$HOME/.local/share/gummy-osd
BRIGHTNESS_FILE="$DIR/brightness"
BACKLIGHT_FILE="$DIR/backlight"
TEMPERATURE_FILE="$DIR/temperature"

# Initialize value files and storage directory
if [ ! -d "$DIR" ]; then
    mkdir -p "$DIR"
fi

if [ ! -f "$BRIGHTNESS_FILE" ]; then
    echo "100" > "$BRIGHTNESS_FILE"
fi

if [ ! -f "$BACKLIGHT_FILE" ]; then
    echo "100" > "$BACKLIGHT_FILE"
fi

if [ ! -f "$TEMPERATURE_FILE" ]; then
    echo "6500" > "$TEMPERATURE_FILE"
fi

# Start gummy daemon if needed
if ! pgrep gummyd > /dev/null; then
    echo "Gummy daemon is not running: starting now"
    gummy start
else
    echo "Gummy daemon is running."
fi

# Function to update and display OSD
update_osd() {
    local icon=$1
    local level=$2

    gdbus call --session \
        --dest org.Cinnamon \
        --object-path /org/Cinnamon \
        --method org.Cinnamon.ShowOSD \
        '{"icon": <"'$icon'">, "level": <'$level'>}' > /dev/null 2>&1
}

# Check the mode and adjust accordingly
case "$1" in
    "brightness")
        VALUE_FILE="$BRIGHTNESS_FILE"
        ICON="display-brightness-symbolic"
        STEP=5
        DEFAULT=100
        ;;
    "backlight")
        VALUE_FILE="$BACKLIGHT_FILE"
        ICON="display-brightness-symbolic"
        STEP=5
        DEFAULT=100
        ;;
    "temperature")
        VALUE_FILE="$TEMPERATURE_FILE"
        ICON="temperature-symbolic"
        STEP=250
        DEFAULT=6500
        ;;
    *)
        echo "Unknown mode: $1"
        exit 1
        ;;
esac

# Read the current value
VALUE=$(cat "$VALUE_FILE")

# Adjust the value based on the direction
case "$2" in
    "up")
        VALUE=$((VALUE + STEP))
        ;;
    "down")
        VALUE=$((VALUE - STEP))
        ;;
    "reset")
        VALUE=$DEFAULT
        ;;
    *)
        echo "Unknown direction: $2"
        exit 1
        ;;
esac

# Ensure VALUE is within valid ranges
if [ "$1" == "brightness" ] || [ "$1" == "backlight" ]; then
    if [ "$VALUE" -gt 100 ]; then
        VALUE=100
        echo "no change"
    elif [ "$VALUE" -lt 0 ]; then
        VALUE=0
        echo "no change"
    else
        echo "value: $VALUE"
    fi
elif [ "$1" == "temperature" ]; then
    if [ "$VALUE" -gt 6500 ]; then
        VALUE=6500
        echo "no change"
    elif [ "$VALUE" -lt 1000 ]; then
        VALUE=1000
        echo "no change"
    else
        echo "value: $VALUE"
    fi
fi

# Write the updated value back to the file
echo "$VALUE" > "$VALUE_FILE"

# Update the OSD display
update_osd "$ICON" "$VALUE"

# Adjust the settings using gummy
case "$1" in
    "brightness")
        gummy -B 0 -b "$VALUE"
        ;;
    "backlight")
        gummy -P 0 -p "$VALUE"
        ;;
    "temperature")
        gummy -T 0 -t "$VALUE"
        ;;
esac
