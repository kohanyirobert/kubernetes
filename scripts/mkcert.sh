mkcert_version=1.4.3
mkcert_os=linux
mkcert_platform=amd64
mkcert_binary=mkcert-v$mkcert_version-$mkcert_os-$mkcert_platform
mkcert_url=https://github.com/FiloSottile/mkcert/releases/download/v$mkcert_version/$mkcert_binary
wget --no-verbose --timestamping $mkcert_url
sudo install \
  --verbose \
  --mode=+x $mkcert_binary /usr/local/bin/mkcert

grep --quiet CAROOT $HOME/.profile \
  || echo 'export CAROOT=/vagrant/.local/share/mkcert' \
  | sudo tee --append $HOME/.profile

grep --quiet TRUST_STORES $HOME/.profile \
  || echo 'export TRUST_STORES=system' \
  | sudo tee --append $HOME/.profile

source $HOME/.profile

mkcert -install
