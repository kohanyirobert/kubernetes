# https://openebs.io/docs/user-guides/prerequisites#ubuntu
if ! sudo systemctl is-active --quiet iscsid
then
  sudo systemctl enable --now iscsid
fi
