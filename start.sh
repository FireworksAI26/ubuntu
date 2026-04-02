#!/bin/bash

echo "==> Clearing old locks..."
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1 /var/run/dbus/pid

echo "==> Setting up dbus..."
mkdir -p /var/lib/dbus
dbus-uuidgen > /var/lib/dbus/machine-id
mkdir -p /var/run/dbus
dbus-daemon --system --fork || true
sleep 1

echo "==> Starting Xvfb..."
Xvfb :1 -screen 0 1920x1080x24 &
sleep 3

echo "==> Starting GNOME as remoteuser..."
sudo -u remoteuser env \
    DISPLAY=:1 \
    XDG_CURRENT_DESKTOP=GNOME \
    GNOME_SHELL_SESSION_MODE=ubuntu \
    DESKTOP_SESSION=ubuntu \
    XDG_SESSION_TYPE=x11 \
    GDK_BACKEND=x11 \
    dbus-launch --exit-with-session gnome-session &
sleep 8

echo "==> Starting x11vnc..."
x11vnc -display :1 -nopw -listen 0.0.0.0 -xkb -forever -shared -bg -o /var/log/x11vnc.log
sleep 2

echo "==> Starting noVNC on port 6080..."
websockify --web=/usr/share/novnc/ 0.0.0.0:6080 localhost:5900 &

echo ""
echo "========================================="
echo "  GNOME Desktop ready!"
echo "  Open port 6080 in RunPod to connect."
echo "========================================="
echo ""

# Keep alive and show x11vnc log
tail -f /var/log/x11vnc.log
