#!/usr/bin/env bash
set -e

VAGRANT_USER_PASS=vagrant
VAGRANT_SHARED_FOLDER=/vagrant
VAGRANT_HOME=/home/vagrant

# UBUNTU
# # Configure docker repository
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt-get update
sudo apt-get install -y git vim neovim zsh curl wget docker-ce docker-ce-cli containerd.io gnome gnome-tweak-tool python-pip python3-pip alacarte
sudo usermod -a -G docker vagrant

# I3 window mannager setup
sudo apt-get install -y i3 i3status dmenu rofi i3lock xbacklight feh conky lxappearance arc-theme fonts-font-awesome fonts-powerline
pip3 install bumblebee-status # Bar mannager for i3
sudo timedatectl set-timezone Europe/Madrid

# Install kitty terminal
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
sudo ln -s /home/vagrant/.local/kitty.app/bin/kitty /usr/bin/kitty

# Docker Compose instalation
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose


cd /opt

echo "GOLANG https://golang.org/dl/"
GOLANG_VERSION=1.18.8
GOLANG_TAR_URL="https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz"
sudo wget ${GOLANG_TAR_URL} &> /dev/null
sudo tar -zxf "$(basename $GOLANG_TAR_URL)"
sudo rm "$(basename $GOLANG_TAR_URL)"
GOROOT=/opt/$(ls | grep go | head -1)

echo "JDK 11 https://adoptopenjdk.net/"
JDK_TAR_URL=https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.10%2B9/OpenJDK11U-jdk_x64_linux_hotspot_11.0.10_9.tar.gz
sudo wget ${JDK_TAR_URL} &> /dev/null
sudo tar -zxf "$(basename $JDK_TAR_URL)"
sudo rm "$(basename $JDK_TAR_URL)"
JAVA_HOME=/opt/$(ls | grep jdk | head -1)

echo "MAVEN https://maven.apache.org/download.cgi"
MAVEN_VERSION=3.6.3
MAVEN_TAR_URL=https://ftp.cixug.es/apache/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz
sudo wget ${MAVEN_TAR_URL} &> /dev/null
sudo tar -zxf "$(basename $MAVEN_TAR_URL)"
sudo rm "$(basename $MAVEN_TAR_URL )"
MAVEN_HOME=/opt/$(ls | grep maven | head -1)

echo "jetbrains-toolbox-X.X.X"
JETBRAINS_TOOLBOX_VERSION="1.23.11731"
JETBRAINS_TOOLBOX_URL="https://download-cdn.jetbrains.com/toolbox/jetbrains-toolbox-${JETBRAINS_TOOLBOX_VERSION}.tar.gz"
sudo wget  &> /dev/null
sudo tar -xzf jetbrains-toolbox-"$JETBRAINS_TOOLBOX_VERSION".tar.gz
sudo rm "$(basename $JETBRAINS_TOOLBOX_URL )"

# Configure spanish keyboard layout for gnome
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'es')]"

# Install Oh My ZSH and set as default shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo "$VAGRANT_USER_PASS" | chsh -s "$(which zsh)"

sudo curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o vagrant -g vagrant -m 0755 kubectl /usr/local/bin/kubectl

cat <<-EOFILE > "/vagrant/vagrant_env.sh"
#!/bin/bash
export GOROOT=${GOROOT}
export GOPATH=${VAGRANT_HOME}/go
export JAVA_HOME=${JAVA_HOME}
export MAVEN_HOME=${MAVEN_HOME}
export PATH=${GOROOT}/bin:${GOPATH}/bin:${JAVA_HOME}/bin:${MAVEN_HOME}/bin:${VAGRANT_HOME}/.local/bin:${PATH}
EOFILE
chmod +x /vagrant/vagrant_env.sh

sudo reboot
