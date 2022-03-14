# Installs the generated SSH key to facilitate node-a SSH-ing into node-b, etc.
install --mode=u=rw,go= /vagrant/id_rsa $HOME/.ssh
grep -q "$(cat /vagrant/id_rsa.pub)" $HOME/.ssh/authorized_keys \
  || cat /vagrant/id_rsa.pub >> $HOME/.ssh/authorized_keys
