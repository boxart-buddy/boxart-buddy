#!/bin/bash
# HELP: Boxart Buddy
# ICON: boxartbuddy
# GRID: Boxart Buddy

STAGE_OVERLAY=0 . /opt/muos/script/var/func.sh

if command -v SETUP_APP >/dev/null 2>&1; then
    # --- Jacaranda (2601+) Logic ---
    APP_BIN="bin/love"
    SETUP_APP "love" ""
fi

echo app >/tmp/act_go # -- can this be removed?

# Define paths and commands
LOVEDIR="$(GET_VAR "device" "storage/rom/mount")/MUOS/application/BoxartBuddy"
GPTOKEYB="$(GET_VAR "device" "storage/rom/mount")/MUOS/emulator/gptokeyb/gptokeyb2.armhf"
CONFDIR="$LOVEDIR/data/"
LOGDIR="${CONFDIR}/log"

mkdir -p "$CONFDIR" "$LOGDIR"

SETUP_SDL_ENVIRONMENT # -- can this be removed?
export XDG_DATA_HOME="$CONFDIR"

# Launcher
cd "$LOVEDIR" || exit
SET_VAR "system" "foreground_process" "love"
export LD_LIBRARY_PATH="$LOVEDIR/libs:$LD_LIBRARY_PATH"
LOGFILE="${LOGDIR}/bb-lua-launch.log"
echo "[DEBUG] Running as user: $(whoami)" >>"$LOGFILE"

# Start gptokeyb
$GPTOKEYB "love" &
GPTOKEYB_PID=$!

# Launch app and capture output
LD_PRELOAD="$LOVEDIR/boxart-buddy/native/linuxarm64/libjemalloc.so" ./love boxart-buddy --project-root="$LOVEDIR" >>"$LOGFILE" 2>&1

# Kill gptokeyb
kill -9 "$GPTOKEYB_PID"
