# Ubuntu dotfiles

## Setup

1. Install Raspberry Pi OS on an SD card
   1. `brew install --cask raspberry-pi-imager`
   2. Pick the latest `lite` debian version
   3. set the user to be `pi`, call the computer `pihole`
2. Connect the pihole to power and to router via ethernet
3. Find the pihole's IP address (router app)
4. `ssh pi@<ip-address>`
5. Generate an SSH key
   1. `ssh-keygen`
6. Copy the value of the public SSH key
   1. `cat ~/.ssh/id_ed25519.pub`
7. Add the key to GitHub
   1. https://github.com/settings/keys
8. Setup the bare git repo (below)

```bash
git init --bare $HOME/.cfg
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
export config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
config config --local status.showUntrackedFiles no
config remote add origin git@github.com:Fullchee/ubuntu-dotfiles.git
config fetch origin main
config reset --hard origin/main
config branch --set-upstream-to=origin/main main
zsh ~/.dotfiles/post-install.sh
```
