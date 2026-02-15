#!/bin/bash

sudo apt update;
sudo apt upgrade -y;

# is zsh is installed?
if ! command -v zsh &> /dev/null; then
    echo "Zsh not found. Installing..."
    sudo apt update && sudo apt install -y zsh
fi

# 2. Check if we are currently running in zsh
if [ -z "$ZSH_VERSION" ]; then
    echo "Switching context to Zsh..."
    exec zsh "$0" "$@"
fi

# --- Everything below this line will run in Zsh ---
echo "Now running in $(zsh --version)"

chsh -s $(which zsh);  # set zsh as default shell

sudo apt -y install bat;  # better cat
sudo apt -y install eza;  # better ls + tree with git and icons
sudo apt -y install fzf;  # filter in STDIN https://github.com/junegunn/fzf
sudo apt -y install git;
sudo apt -y install hx;  # helix: vim with builtin LSP

# install prezto
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME' $@
rm -rf ~/.zprezto
rm -rf ~/.zprofile
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
config config --local status.showUntrackedFiles no
echo 'source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"' >> ~/.zshrc
config reset --hard origin/main
touch ~/.lc_history

setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -sf "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done


sudo apt -y install speedtest;
sudo apt -y install xclip;  # copy to clipboard from CLI
sudo apt -y install zoxide;  # better cd with history and frecency


# # 1. Get the current IP with CIDR (e.g., 192.168.50.8/24) specifically for eth0
# CURRENT_IP=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}/\d+')

# # 2. Get the specific gateway for the eth0 interface
# # We look for the default route that specifically points to eth0
# CURRENT_GW=$(ip route show default dev eth0 | awk '{print $3}')

# # 3. Safety Check
# if [ -z "$CURRENT_IP" ] || [ -z "$CURRENT_GW" ]; then
#     echo "Error: Could not capture IP ($CURRENT_IP) or Gateway ($CURRENT_GW) for eth0."
#     echo "Make sure the ethernet cable is plugged in and has a temporary DHCP lease."
#     exit 1
# fi

# echo "Locking in Ethernet Settings..."
# echo "Interface: eth0"
# echo "IP Address: $CURRENT_IP"
# echo "Gateway:   $CURRENT_GW"

# # 4. Apply the configuration to NetworkManager
# sudo nmcli con mod "netplan-eth0" \
#   ipv4.addresses "$CURRENT_IP" \
#   ipv4.gateway "$CURRENT_GW" \
#   ipv4.dns "1.1.1.1,8.8.8.8" \
#   ipv4.method manual

# # 5. Restart the connection to apply changes
# sudo nmcli con up "netplan-eth0"

# echo "Done! Test with: ping -c 3 8.8.8.8"
