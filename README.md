# Ubuntu dotfiles

## Setup

### On Mac

1. Install Raspberry Pi OS on an SD card
   1. `brew install --cask raspberry-pi-imager`
   2. Pick the latest `lite` debian version
   3. set the user to be `pihole`, call the computer `pihole`
2. Connect the pihole to power and to router via ethernet

### Asus router

1. Open the router app
   1. <http://asusrouter.com>
2. Get the IP address of the pihole
   1. Confirm you can `ssh pihole@<ip-address>`
   2. Run `sudo apt update` in the background
3. Router: reserve that IP address
   1. Asus: LAN -> DHCP -> Manually Assigned IP -> scroll down
   2. Can't do this with Beanfield Airties Air 4960x, even when logged into http://masternode.local/

### Mac terminal

1. `ssh-copy-id pihole@<ip-address>`
   1. (ssh without the typing the password)
2. `~/.ssh/config`: update the IP address of the `pihole` entry
3. Confirm you can `ssh pihole`

### SSHed on pihole

1. Generate an SSH key
   1. `ssh-keygen`
2. Copy the value of the public SSH key
   1. `cat ~/.ssh/id_ed25519.pub`
3. Add the key to GitHub as a deploy key (can just access this one repo)
   1. https://github.com/Fullchee/pihole-dotfiles/settings/keys
4. Setup the bare git repo

```bash
sudo apt update;
sudo apt upgrade -y;
sudo apt install -y git;
git init --bare $HOME/.cfg
config() {
   /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME "$@"
}
config config --local status.showUntrackedFiles no
config remote add origin git@github.com:Fullchee/pihole-dotfiles.git
config fetch origin main
config reset --hard origin/main
config branch --set-upstream-to=origin/main main
bash ~/.dotfiles/post-install.sh
```

### Browser

1. Go to IP address
2. http://[ip-address-of-pihole]/admin
