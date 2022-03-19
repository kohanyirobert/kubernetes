# Eliminates multipathd errors being logged to syslog due to running VirtualBox
# https://sleeplessbeastie.eu/2021/01/06/how-to-fix-multipath-daemon-error-about-missing-path-when-using-virtualbox/
grep --quiet blacklist /etc/multipath.conf || cat << EOF | sudo tee --append /etc/multipath.conf
blacklist {
  device {
    vendor "VBOX"
    product "HARDDISK"
  }
}
EOF
sudo systemctl restart multipathd
