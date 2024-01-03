# shellcheck shell=bash
set -e -u -o pipefail -x

AWK="@gawk@/bin/awk"
DASEL="@dasel@/bin/dasel"
GREP="@gnugrep@/bin/grep"
XRANDR="@xrandr@/bin/xrandr"

# Redirect all output to a logfile and prefix with timestamp
exec &> >($AWK '{ print strftime("[%Y-%m-%d %H:%M:%S]"), $0 }' >> "${HOME}/log/hotplug_monitor.log")

env | sort

USER="${USER:-@username@}"
HOME="${HOME:-@homeDirectory@}"
DISPLAY="${DISPLAY:-:0}"
if [ -z "${XAUTHORITY:-}" ]; then
  XAUTHORITY="$(find /tmp -maxdepth 1 -name 'xauth_*' -type f -user "$USER" | head -1)"
fi

export HOME USER DISPLAY XAUTHORITY

echo "DISPLAY: ${DISPLAY}"
echo "XAUTHORITY: ${XAUTHORITY}"

INTERNAL=eDP1

wait_for_monitor() {
  while sleep .1; do
    dev="$(xrandr | $GREP -v '^eDP1' | awk '/^DP.+ connected /{print $1}' | head -n1)"
    if [ -n "$dev" ]; then
      echo "$dev"
      return
    fi
  done
}

set_font_size() {
  $DASEL put -f ~/.alacritty.toml -t int -v "$1" font.size
}

# Usually it's `card0` but sometimes it's `card1`...
if $GREP -q '^connected$' /sys/class/drm/card?-DP-*/status; then
  # SOME device connected
  echo "($$) detecting external..."
  EXTERNAL="$(wait_for_monitor)"

  echo "($$) switching to $EXTERNAL"
  $XRANDR \
    --output "$EXTERNAL" --auto --primary \
    --output "$INTERNAL" --off
  set_font_size 11

else
  echo "($$): switching to internal"
  $XRANDR --output "$INTERNAL" --auto --primary
  set_font_size 9

fi

@feh@/bin/feh --bg-fill "${HOME}/Pictures/wallpaper.png"
