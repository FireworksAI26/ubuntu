FROM runpod/base:0.7.0-ubuntu2004

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV XDG_CURRENT_DESKTOP=GNOME
ENV GNOME_SHELL_SESSION_MODE=ubuntu
ENV DESKTOP_SESSION=ubuntu
ENV XDG_SESSION_TYPE=x11
ENV GDK_BACKEND=x11

# 1. Install Ubuntu GNOME desktop + Xvfb + noVNC
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    ubuntu-desktop \
    gnome-shell \
    gnome-terminal \
    gnome-tweaks \
    yaru-theme-gtk \
    yaru-theme-icon \
    yaru-theme-sound \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    dbus-x11 \
    x11-xserver-utils \
    xdotool \
    pulseaudio \
    sudo curl wget \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Create user
RUN useradd -m -s /bin/bash remoteuser && \
    echo "remoteuser:remoteuser" | chpasswd && \
    usermod -aG sudo remoteuser && \
    echo "remoteuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# 3. noVNC index
RUN ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# 4. Entrypoint
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 6080
CMD ["/start.sh"]
