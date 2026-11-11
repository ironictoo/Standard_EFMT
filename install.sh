#!/usr/bin/env bash
# Install the Standard EFMT on Linux or macOS (Apple Silicon, macOS 14+):
#   1. uv (installed in ~/.local/bin if missing) puts Python 3.10 and exactly
#      the package versions in uv.lock into .venv
#   2. checks for system libraries (Linux: offers to install missing ones with
#      sudo apt) and the NimStim faces
#   3. launchers for the practice and scan runs and the resting state cross
#      (Linux: app menu and desktop; macOS: .command files on the desktop)
# Usage: ./install.sh [--no-launchers]
# Rerun after `git pull` to update .venv to the new uv.lock; it is safe to rerun.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$here"
launchers=1
[ "${1:-}" = "--no-launchers" ] && launchers=0

say() { printf '\n==> %s\n' "$*"; }
warn() { printf '\nWARNING: %s\n' "$*" >&2; }
die() { printf '\nERROR: %s\n' "$*" >&2; exit 1; }
title() { case "$1" in practice) echo 'EFMT Practice' ;; scan) echo 'EFMT Scan' ;; rest) echo 'Resting State Cross' ;; esac; }
comment() {
    case "$1" in
    rest) echo 'Fixation cross for resting state scans, shown until Escape is pressed' ;;
    *) echo "Standard emotional face matching task: $1 run" ;;
    esac
}
ask() {  # yes/no question; no if there is no terminal to answer from
    local reply=""
    printf '\n%s [y/N] ' "$1"
    read -r reply 2>/dev/null </dev/tty || true
    [[ "$reply" == [Yy]* ]]
}
apt_install() {  # ask, then install Debian/Ubuntu packages with sudo; fails if declined or no apt
    command -v apt-get >/dev/null || return 1
    ask "$1 Install with: sudo apt-get install $2 ?" || return 1
    # shellcheck disable=SC2086
    sudo apt-get install -y $2
}
find_uv() {
    uv=""
    for c in uv "$HOME/.local/bin/uv" "$HOME/.cargo/bin/uv"; do
        if command -v "$c" >/dev/null 2>&1; then uv="$(command -v "$c")"; return; fi
    done
}

# 1. Python environment
find_uv
if [ -z "$uv" ]; then
    say "Installing uv in ~/.local/bin (it provides Python 3.10 and the task's packages)"
    if command -v curl >/dev/null; then
        curl -LsSf https://astral.sh/uv/install.sh | sh
    elif command -v wget >/dev/null; then
        wget -qO- https://astral.sh/uv/install.sh | sh
    else
        die "Need curl or wget to install uv"
    fi
    find_uv
    [ -n "$uv" ] || die "uv did not install; see the messages above"
fi

say "Installing Python 3.10 and the packages in uv.lock into .venv (the first install takes a few minutes)"
"$uv" sync --locked
.venv/bin/python -c 'import psychopy; print("PsychoPy", psychopy.__version__)' \
    || die "PsychoPy did not import; see the messages above"

# 2. Checks
if [ "$(uname -s)" = Linux ] && command -v ldconfig >/dev/null; then
    # Qt (used for the dialogs) needs these; Ubuntu 22.04 lacks libxcb-cursor0
    libs="$(ldconfig -p)"
    missing=""
    for lib in libxcb-cursor.so.0 libxcb-icccm.so.4 libxcb-image.so.0 libxcb-keysyms.so.1 \
               libxcb-randr.so.0 libxcb-render-util.so.0 libxcb-shape.so.0 libxcb-xfixes.so.0 \
               libxcb-xkb.so.1 libxkbcommon-x11.so.0 libX11-xcb.so.1; do
        grep -q "$lib" <<<"$libs" || missing="$missing $lib"
    done
    qt_packages="libxcb-cursor0 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-randr0 libxcb-render-util0 libxcb-shape0 libxcb-xfixes0 libxcb-xkb1 libxcb-util1 libxkbcommon-x11-0 libx11-xcb1"
    if [ -n "$missing" ] \
        && ! apt_install "Some libraries that the task's dialogs (Qt) need are missing." "$qt_packages"; then
        warn "Missing libraries for the Qt dialogs:$missing
The task's dialogs will not open until they are installed. On Ubuntu/Debian:
    sudo apt install $qt_packages"
    fi
fi

face_dir="$(sed -n "s/^face_dir[[:space:]]*'\(.*\)'.*/\1/p" Default.params)"
face_dir="${face_dir/#\~/$HOME}"
if [ ! -d "$face_dir" ]; then
    warn "NimStim face folder not found: $face_dir
Copy the faces there, or set face_dir in Default.params (see README.md)."
else
    n="$(find "$face_dir" -maxdepth 1 -type f \( -iname '*_AN_C.*' -o -iname '*_FE_C.*' \) | wc -l)"
    [ "$n" -ge 32 ] || warn "Only $n closed-mouth angry/fearful faces in $face_dir (the task uses 32; see README.md)."
fi

# 3. Launchers
chmod +x run.sh
if [ "$launchers" = 1 ]; then
    case "$(uname -s)" in
    Linux)
        apps="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
        desktop="$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Desktop")"
        mkdir -p "$apps"
        for run in practice scan rest; do
            name="$(title "$run")"
            file="$apps/standard-efmt-$run.desktop"
            cat >"$file" <<EOF
[Desktop Entry]
Type=Application
Name=$name
Comment=$(comment "$run")
Exec="$here/run.sh" $run
Path=$here
Icon=$here/tools/efmt-icon.svg
Terminal=false
Categories=Science;
EOF
            chmod +x "$file"
            if [ -d "$desktop" ] && [ "$desktop" != "$HOME" ]; then
                cp "$file" "$desktop/"
                # GNOME only starts desktop launchers marked trusted
                gio set "$desktop/standard-efmt-$run.desktop" metadata::trusted true 2>/dev/null || true
            fi
        done
        say "Added 'EFMT Practice', 'EFMT Scan' and 'Resting State Cross' to the app menu ($apps)"
        [ -d "$desktop" ] && [ "$desktop" != "$HOME" ] && echo "    and the desktop ($desktop)"
        ;;
    Darwin)
        for run in practice scan rest; do
            file="$HOME/Desktop/$(title "$run").command"
            printf '#!/bin/bash\nexec "%s/run.sh" %s\n' "$here" "$run" >"$file"
            chmod +x "$file"
        done
        say "Added 'EFMT Practice.command', 'EFMT Scan.command' and 'Resting State Cross.command' to the desktop"
        ;;
    esac
fi

say "Done. Start the task with the launchers, or from this folder:
    ./run.sh practice     (training, before scanning)
    ./run.sh scan         (in the scanner; waits for the trigger)
    ./run.sh rest         (resting state: fixation cross until Escape)"
