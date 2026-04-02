#!/bin/bash

# 1. Clear old locks
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1 /var/run/dbus/pid

# 2. Generate machine-id for dbus
mkdir -p /var/lib/dbus
dbus-uuidgen > /var/lib/dbus/machine-id

# 3. Start system dbus
mkdir -p /var/run/dbus
dbus-daemon --system --fork || true

# 4. Start Xvfb (virtual framebuffer — lets GNOME actually render)
echo "Starting Xvfb..."
Xvfb :1 -screen 0 1920x1080x24 &
sleep 2

# 5. Start GNOME as remoteuser
echo "Starting GNOME session..."
sudo -u remoteuser env \
    DISPLAY=:1 \
    XDG_CURRENT_DESKTOP=GNOME \
    GNOME_SHELL_SESSION_MODE=ubuntu \
    DESKTOP_SESSION=ubuntu \
    XDG_SESSION_TYPE=x11 \
    GDK_BACKEND=x11 \
    dbus-launch --exit-with-session gnome-session &
sleep 5

# 6. Start x11vnc (connects to the Xvfb display, not TigerVNC)
echo "Starting x11vnc..."
x11vnc -display :1 -nopw -listen localhost -xkb -ncache 10 -ncache_cr -forever &
sleep 2

# 7. Start noVNC
echo "Starting noVNC on port 6080..."
websockify --web=/usr/share/novnc/ 6080 localhost:5900 &

echo ""
echo "========================================="
echo "  GNOME Desktop ready!"
echo "  Open port 6080 in RunPod to connect."
echo "  No password required."
echo "========================================="
echo ""

# 8. Keep alive
wait
