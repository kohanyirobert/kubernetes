# Installs Cloudflare's cfssl toolkit for working with certificates
cfssl_version=1.6.1
cfssl_os=linux
cfssl_platform=amd64
cfssl_executable=cfssl_${cfssl_version}_${cfssl_os}_${cfssl_platform}
cfssljson_executable=cfssljson_${cfssl_version}_${cfssl_os}_${cfssl_platform}
cfssl_url_prefix=https://github.com/cloudflare/cfssl/releases/download/v$cfssl_version
wget --no-verbose --timestamping $cfssl_url_prefix/$cfssl_executable
wget --no-verbose --timestamping $cfssl_url_prefix/$cfssljson_executable
sudo install \
  --verbose \
  --mode=+x $cfssl_executable /usr/local/bin/cfssl
sudo install \
  --verbose \
  --mode=+x $cfssljson_executable /usr/local/bin/cfssljson
