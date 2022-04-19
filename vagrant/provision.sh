#!/usr/bin/env bash
set -e

VAGRANT_USER_PASS=vagrant
VAGRANT_SHARED_FOLDER=/vagrant
VAGRANT_HOME=/home/vagrant

# UBUNTU
# Configure docker repository
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo groupadd docker
sudo usermod -a -G docker vagrant
newgrp docker

# Install base
sudo apt-get update
sudo apt-get install -y git vim neovim zsh curl wget docker-ce docker-ce-cli containerd.io gnome gnome-tweak-tool python3-pip python3.8 alacarte

# Configure spanish keyboard layout for gnome
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'es')]"

# Set timezone
sudo timedatectl set-timezone Europe/Madrid

# Install GUI
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install xfce4 virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11
sudo sed -i 's/allowed_users=.*$/allowed_users=anybody/' /etc/X11/Xwrapper.config
sudo VBoxClient --checkhostversion
sudo VBoxClient --clipboard
sudo VBoxClient --display
sudo VBoxClient --draganddrop
sudo VBoxClient --seamless

# Docker Compose instalation
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

cd /opt

# Install Oh My ZSH and set as default shell
if [[ -d $VAGRANT_HOME/.oh-my-zsh ]]; then
    rm -rf /home/vagrant/.oh-my-zsh
    sudo apt-get update
    sudo apt-get install zsh
    # Install Oh My ZSH and set as default shell
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo "$VAGRANT_USER_PASS" | chsh -s $(which zsh)
    # Sets default plugins for oh my zsh
    sed -i '/plugins=/s/.*/plugins=(git oc kubectl gh)/' ${HOME}/.zshrc
fi

GOLANG_VERSION=1.18.1
GOLANG_TAR_URL="https://go.dev/dl/go$GOLANG_VERSION.linux-amd64.tar.gz"
echo "---------------------------------------------------------------------------> Installing go $GOLANG_TAR_URL"
echo $GOLANG_TAR_URL
sudo wget ${GOLANG_TAR_URL} &> /dev/null
sudo tar -zxf "$(basename $GOLANG_TAR_URL)"
sudo rm "$(basename $GOLANG_TAR_URL)"
GOROOT=/opt/$(ls | grep go | head -1)

JDK_TAR_URL=https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.10%2B9/OpenJDK11U-jdk_x64_linux_hotspot_11.0.10_9.tar.gz
echo "---------------------------------------------------------------------------> Installing JDK $JDK_TAR_URL"
sudo wget ${JDK_TAR_URL} &> /dev/null
sudo tar -zxf "$(basename $JDK_TAR_URL)"
sudo rm "$(basename $JDK_TAR_URL)"
JAVA_HOME=/opt/$(ls | grep jdk | head -1)

MAVEN_VERSION=3.6.3
MAVEN_BIN_URL=apache-maven-$MAVEN_VERSION-bin.tar.gz
MAVEN_TAR_URL=https://ftp.cixug.es/apache/maven/maven-3/${MAVEN_VERSION}/binaries/$MAVEN_BIN_URL
echo "---------------------------------------------------------------------------> Installing Maven $MAVEN_TAR_URL"
sudo wget ${MAVEN_TAR_URL} &> /dev/null
sudo tar -zxf "$(basename $MAVEN_BIN_URL)"
sudo rm "$(basename $MAVEN_BIN_URL )"
MAVEN_HOME=/opt/$(ls | grep maven | head -1)

JETBRAINS_TOOLBOX_VERSION="1.23.11731"
echo "---------------------------------------------------------------------------> Installing jetbrains-toolbox-$JETBRAINS_TOOLBOX_VERSION"
JETBRAINS_TOOLBOX_URL="https://download-cdn.jetbrains.com/toolbox/jetbrains-toolbox-${JETBRAINS_TOOLBOX_VERSION}.tar.gz"
echo "Downloading from $JETBRAINS_TOOLBOX_URL"
sudo wget $JETBRAINS_TOOLBOX_URL  &> /dev/null
sudo tar -xzf jetbrains-toolbox-"$JETBRAINS_TOOLBOX_VERSION".tar.gz
sudo rm "$(basename $JETBRAINS_TOOLBOX_URL )"

echo "---------------------------------------------------------------------------> Installing Kubectl"
sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o vagrant -g vagrant -m 0755 kubectl /usr/local/bin/kubectl

echo "---------------------------------------------------------------------------> Installing OC"
OC_BIN_TAR="openshift-client-linux-4.10.0-0.okd-2022-03-07-131213.tar.gz"
OC_URL="https://github.com/openshift/okd/releases/download/4.10.0-0.okd-2022-03-07-131213/$OC_BIN_TAR"
echo "OC_URL $OC_URL"
sudo wget $OC_URL &> /dev/null
sudo tar -zxf "$(basename $OC_BIN_TAR)"
sudo rm "$(basename $OC_BIN_TAR )"
OC_HOME=/opt/$(ls | grep maven | head -1)

echo "export ZSH_THEME=dieter" >> $VAGRANT_HOME/.zshrc
echo "export PATH=${GOROOT}/bin:${JAVA_HOME}/bin:${MAVEN_HOME}/bin:${VAGRANT_HOME}/.local/bin:/opt:${PATH}" >>  $VAGRANT_HOME/.zshrc

sudo VBoxClient-all

sudo reboot
