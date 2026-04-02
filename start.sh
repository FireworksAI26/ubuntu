#!/bin/bash

# 1. Housekeeping: Clear old locks
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1 /var/run/dbus/pid

# 2. Critical: Generate machine-id for GNOME/D-Bus
dbus-uuidgen > /var/lib/dbus/machine-id
mkdir -p /var/run/dbus
dbus-daemon --system --fork

# 3. Start VNC as the user
# We use -localhost no so the websockify bridge can reach it
sudo -u remoteuser vncserver :1 -geometry 1920x1080 -depth 24 -localhost no

# 4. Start noVNC proxy
echo "Launching noVNC on port 6080..."
websockify --web=/usr/share/novnc/ 6080 localhost:5901 &

# 5. Keep the container alive and log output
tail -f /home/remoteuser/.vnc/*.log
