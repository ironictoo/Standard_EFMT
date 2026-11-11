#!/usr/bin/env bash
# Start the Standard EFMT with this folder's .venv (made by install.sh).
# Usage: ./run.sh practice | scan | rest | <order .TL file> | (nothing: choose in a dialog)
# The desktop launchers call this. Started outside a terminal, the output goes
# to a log file and an error opens a dialog.
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$here" || exit 1
py="$here/.venv/bin/python"

alert() {
    if command -v zenity >/dev/null; then
        zenity --error --title='Standard EFMT' --no-wrap --text="$1"
    elif command -v osascript >/dev/null; then
        osascript -e "display alert \"Standard EFMT\" message \"$1\""
    elif command -v notify-send >/dev/null; then
        notify-send 'Standard EFMT' "$1"
    fi
}

if [ ! -x "$py" ]; then
    msg="No Python environment in $here/.venv. Run ./install.sh first."
    echo "$msg" >&2
    [ -t 1 ] || alert "$msg"
    exit 1
fi

if [ -t 1 ]; then
    exec "$py" StimTool.py "$@"
fi

log="${XDG_STATE_HOME:-$HOME/.local/state}/standard-efmt/launcher.log"
mkdir -p "$(dirname "$log")"
"$py" StimTool.py "$@" >"$log" 2>&1
status=$?
if [ "$status" -ne 0 ]; then
    alert "The task stopped with an error (exit code $status).
Details: $log"
fi
exit "$status"
