#!/bin/zsh

sudo apt update;
sudo apt upgrade -y;

sudo apt -y install bat;  # better cat
sudo apt -y install eza;  # better ls + tree with git and icons
sudo apt -y install fzf;  # filter in STDIN https://github.com/junegunn/fzf
sudo apt -y install git;
sudo apt -y install hx;  # helix: vim with builtin LSP
curl -sSL https://install.pi-hole.net | bash  # pi-hole
sudo apt -y install zsh;

chsh -s $(which zsh)

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
