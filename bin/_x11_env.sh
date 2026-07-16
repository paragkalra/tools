# Shared helper for cli3/gui5: find the running Xorg server (whichever user
# owns it - the gdm greeter if nobody's logged in yet, or the logged-in
# user), and resolve its DISPLAY/XAUTHORITY. Xorg doesn't set these in its
# own environment (they're for its clients), so they're parsed from its argv
# (-auth path) and from the active socket in /tmp/.X11-unix (display number),
# not from /proc/<pid>/environ.
#
# Sets globals: owner, envs (DISPLAY=... XAUTHORITY=... array for `env`).
x_env() {
  local pid args token prev display xauth sock

  pid="$(pgrep -x Xorg | head -1)"
  if [[ -z "$pid" ]]; then
    echo "$0: no Xorg process found" >&2
    exit 1
  fi
  owner="$(ps -o user= -p "$pid")"

  args="$(tr '\0' ' ' < "/proc/$pid/cmdline")"
  prev=""
  for token in $args; do
    [[ "$prev" == "-auth" ]] && xauth="$token"
    [[ "$token" =~ ^:[0-9]+$ ]] && display="$token"
    prev="$token"
  done

  if [[ -z "$display" ]]; then
    sock="$(ls /tmp/.X11-unix/ 2>/dev/null | head -1)"
    [[ -n "$sock" ]] && display=":${sock#X}"
  fi

  if [[ -z "$display" || -z "$xauth" ]]; then
    echo "$0: couldn't determine DISPLAY/XAUTHORITY for Xorg pid $pid" >&2
    exit 1
  fi

  envs=("DISPLAY=$display" "XAUTHORITY=$xauth")
}
