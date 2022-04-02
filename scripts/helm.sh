# Installs Helm in order to easily install certain controllers
# https://helm.sh/docs/intro/install/
helm_version=3.8.1
helm_os=linux
helm_platform=amd64
helm_archive=helm-v$helm_version-$helm_os-$helm_platform.tar.gz
helm_url=https://get.helm.sh/$helm_archive
wget --timestamping $helm_url
tar xvf $helm_archive
sudo install \
  --verbose \
  --mode=+x $helm_os-$helm_platform/helm /usr/local/bin/helm
