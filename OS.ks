# Reboot after installation
reboot

# Use text mode install
text

# Keyboard layouts
keyboard --vckeymap=us--xlayouts='us'

# System language
lang en_US.UTF-8

timesource --ntp-pool=time.stanford.edu

# System timezone
timezone America/Los_Angeles --utc

clearpart --all --initlabel
autopart --type=btrfs

network --bootproto=dhcp --device=link --activate

# Use network installation
url --url="https://mirrors.kernel.org/fedora/releases/44/Everything/x86_64/os/"
repo --name="fedora-updates" --baseurl="https://mirrors.kernel.org/fedora/updates/44/Everything/x86_64/"

# repo --name="Roc-Foss" --baseurl="https://mirror.krfoss.org/fedora/releases/44/Everything/x86_64/os/"
# url --url="http://192.168.10.15:8080/os"

# Do not configure the X Window System
# skipx

# single user
sshkey --username=preese "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOIJw+UxwDZtlkHqbm7F+2fgDKx1QW0WNnAJKNVBhXCs preese@networking"
user --groups=wheel --name=preese --password=$6$NFqDsPtXjTl.2jq1$LJtTeT0Svp2RWwvLjJFpS7XPkDcfFQDKBtddX8H9ADclB0ntu0j1k4OpSAunsCEE6hMA5.6RU8mc59GAhTqRy. --iscrypted --gecos="Phil Reese"

%packages
@^workstation-product-environment
# @^server-product-environment
cockpit-machines
lshw
btop
mtr
wget
tcpdump
git
iperf3
fastfetch
inxi
NetworkManager-tui
rsync
%end

%post --logfile=/root/post_install.log
echo "%wheel        ALL=(ALL)        NOPASSWD: ALL" > /etc/sudoers.d/no-su-pw
dnf install -y --allowerasing vim-default-editor
# systemctl enable --now sshd
dnf update -y
%end
