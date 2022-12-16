#
# Last Updete: 2022/12/13
#
# Author: Yoshihiko Hara
#
# Overview:
#   A Dockerfile to create a container running "Xfce desktop environment that can be connected using a VNC client".
#
# Example of Build command:
#   > docker build --no-cache -t ub2204_vncxfce_cutecom_esp32idf:20221213 .
#
# Example of container initial start command:
#   > docker run -it -v `pwd`:/home/hoge/data -p 5901:5901 -u hoge --name ESP32_Xfce --privileged ub2204_vncxfce_cutecom_esp32idf:20221213
# 

# Specify the image (Ubuntu 22.04) to be the base of the container.
from ubuntu:22.04

# Change the settings so that interactive operations that may cause waiting for input, etc., do not occur while building the container.
ENV DEBIAN_FRONTEND=noninteractive

# Specify working directory (/root).
WORKDIR /root

# Modernize the container userland.
# For the "upgrade" command, specify the options "--force-confdef" and "--force-confold" to automatically update packages non-interactively.
run apt-get update \
  && apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade

# Install "language-pack" to be able to use Japanese.
run apt-get install -y language-pack-ja-base language-pack-ja

# Set the time zone and locale ("Asia/Tokyo", "ja_JP.UTF-8").
run ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
  && echo 'Asia/Tokyo' > /etc/timezone \
  && locale-gen ja_JP.UTF-8 \
  && echo 'LC_ALL=ja_JP.UTF-8' > /etc/default/locale \
  && echo 'LANG=ja_JP.UTF-8' >> /etc/default/locale
env LANG=ja_JP.UTF-8 \
    LANGUAGE=ja_JP.UTF-8 \
    LC_ALL=ja_JP.UTF-8

# Install the "expect" command for interactive processing.
run apt-get -y install expect

# Install a set of things necessary to make "Xfce desktop environment".
run apt-get -y install \
  xubuntu-desktop \
  xfce4-terminal \
  fcitx-mozc \
  fonts-ipafont-gothic \
  fonts-ipafont-mincho \
  xdg-utils

# Install VNC Server.      
run apt-get -y install tigervnc-standalone-server

# Install "CuteCom" to communicate with the microcomputer board connected to the PC with "Serial-USB".
run apt-get -y install cutecom

# Install "vim" for text editing.
run apt-get -y install vim

# Remove "Light-locker" and install "gnome-screensaver" instead.
# This measure is a combination of "Xfce + Light-locker", and there is a possibility
# that the screen will remain black when resuming from suspend.
run apt-get -y remove --purge light-locker \
  && apt-get -y install gnome-screensaver
  
# Start "im-config" with "fcitx" specified for Japanese input.  
run im-config -n fcitx

# Delete unnecessary caches, etc.
run apt-get clean \
  && rm -rf /var/cache/apt/archives/* \
  && rm -rf /var/lib/apt/lists/*

# Create a user "hoge" for operation and make settings for VNC execution in the home of "hoge".
run groupadd -g 1000 hoge \
  && useradd -d /home/hoge -m -s /bin/bash -u 1000 -g 1000 hoge \
  && echo 'hoge:fugafuga' | chpasswd \
  && echo "hoge ALL=NOPASSWD: ALL" >> /etc/sudoers \
  && echo 'spawn "tigervncpasswd"' >> /tmp/initpass \
  && echo 'expect "Password:"' >> /tmp/initpass \
  && echo 'send "fugafuga\\r"' >> /tmp/initpass \
  && echo 'expect "Verify:"' >> /tmp/initpass \
  && echo 'send "fugafuga\\r"' >> /tmp/initpass \
  && echo 'expect "Would you like to enter a view-only password (y/n)?"' >> /tmp/initpass \
  && echo 'send "n\\r"' >> /tmp/initpass \
  && echo 'expect eof' >> /tmp/initpass \
  && echo 'exit' >> /tmp/initpass \
  && sudo -u hoge -H /bin/bash -c '/usr/bin/expect /tmp/initpass' \
  && mkdir -p /home/hoge/.vnc \
  && chown hoge:hoge /home/hoge/.vnc \
  && echo '#!/bin/sh' >> /home/hoge/.vnc/xstartup \
  && echo 'export LANG=ja_JP.UTF-8' >> /home/hoge/.vnc/xstartup \
  && echo 'export LC_ALL=ja_JP.UTF-8' >> /home/hoge/.vnc/xstartup \
  && echo 'export XMODIFIERS=@im=fcitx' >> /home/hoge/.vnc/xstartup \
  && echo 'export GTK_IM_MODULE=fcitx' >> /home/hoge/.vnc/xstartup \
  && echo 'fcitx -r -d &' >> /home/hoge/.vnc/xstartup \
  && echo 'exec startxfce4' >> /home/hoge/.vnc/xstartup \
  && chmod +x /home/hoge/.vnc/xstartup \
  && mkdir -p /home/hoge/data \
  && chown -R hoge:hoge /home/hoge/data

# Make settings so that the USB can be recognized from the container.
run usermod -a -G dialout hoge

# Prepare to mount the host side directory to "/home/hoge/data" in the container.
volume ["/home/hoge/data"]

# Publish port 5901 of the container as a communication port for VNC.
expose 5901

# Start VNC server
cmd /usr/bin/vncserver :1 -localhost no -geometry 1152x864 -alwaysshared -fg
