## Setup

### On Mac

1. Download the Armbian Imager
   1. Apple silicon: download Armbian.Imager_1.2.8_aarch64.dmg
   2. https://github.com/armbian/imager/releases
2. Flash Armbian
3. Connect the Orange Pi to power and to router via ethernet

### Asus router

1. Open the router app
   1. <http://asusrouter.com>
2. Get the IP address of the pihole
   1. Confirm you can `ssh root@<ip-address>`
   2. Default Armbian password: `1234`
3. `sudo apt update && sudo apt upgrade -y && sudo armbian-config`
   1. don't start `Iperf3` on boot (do I still need this on Armbian?)
4. Router: reserve that IP address
   1. Asus: LAN -> DHCP -> Manually Assigned IP -> scroll down
   2. Can't do this with Beanfield Airties Air 4960x, even when logged into http://masternode.local/

### Mac terminal

1. `ssh-copy-id root@<ip-address>`
   1. (ssh without the typing the password)
2. `~/.ssh/config`: update the IP address of the `home-assistant` entry
3. Confirm you can `ssh home-assistant`

### SSHed on `home-assistant`

1. Generate an SSH key
   1. `ssh-keygen`
2. Copy the value of the public SSH key
   1. `cat ~/.ssh/id_ed25519.pub`
3. Add the key to GitHub as a deploy key (can just access this one repo)
   1. https://github.com/Fullchee/orange-pi-home-assistant-dotfiles/settings/keys
4. Setup the bare git repo

```bash
sudo apt update;
sudo apt upgrade -y;
sudo apt install -y git;
git config --global init.defaultBranch main
git init --bare $HOME/.cfg
config() {
   /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME "$@"
}
config config --local status.showUntrackedFiles no
config remote add origin git@github.com:Fullchee/orange-pi-home-assistant-dotfiles.git
config fetch origin main
config checkout main
config reset --hard origin/main
config branch --set-upstream-to=origin/main main
bash ~/.dotfiles/post-install.sh
```

### Browser

1. Go to IP address
2. http://[ip-address-of-pihole]/admin
