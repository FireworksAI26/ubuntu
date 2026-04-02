FROM runpod/base:0.7.0-ubuntu2004

ENV DEBIAN_FRONTEND=noninteractive
# Crucial for GNOME apps to find the display
ENV DISPLAY=:1

# 1. Install Ubuntu Desktop, GNOME, and VNC tools
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    ubuntu-desktop \
    gnome-shell \
    gnome-terminal \
    yaru-theme-gtk yaru-theme-icon \
    tigervnc-standalone-server \
    novnc websockify \
    dbus-x11 x11-xserver-utils \
    sudo curl wget \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Create the user
RUN useradd -m -s /bin/bash remoteuser && \
    echo "remoteuser:remoteuser" | chpasswd && \
    usermod -aG sudo remoteuser && \
    echo "remoteuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# 3. Setup noVNC index
RUN ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# 4. Configure the VNC xstartup for GNOME
# We use dbus-launch to ensure GNOME can talk to the system bus
WORKDIR /home/remoteuser
RUN mkdir -p .vnc && \
    echo "#!/bin/sh\n\
export XDG_CURRENT_DESKTOP=GNOME\n\
export GNOME_SHELL_SESSION_MODE=ubuntu\n\
export DESKTOP_SESSION=ubuntu\n\
export XDG_SESSION_TYPE=x11\n\
export GDK_BACKEND=x11\n\
dbus-launch --exit-with-session gnome-session &" > .vnc/xstartup && \
    chmod +x .vnc/xstartup

# 5. Set VNC password ("password")
RUN echo "password" | vncpasswd -f > .vnc/passwd && \
    chmod 600 .vnc/passwd && \
    chown -R remoteuser:remoteuser /home/remoteuser

# 6. Final setup
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 6080
CMD ["/start.sh"]

