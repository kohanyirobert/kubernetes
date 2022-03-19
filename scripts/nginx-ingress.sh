# Installs NGINX Ingress Controller via Helm
# https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-helm/
if ! kubectl wait pod --all --for=condition=Ready --namespace nginx-ingress --timeout=0s
then
  nginx_ingress_version=2.1.1
  if [ ! -d kubernetes-ingress ]
  then
    git clone --branch v$nginx_ingress_version https://github.com/nginxinc/kubernetes-ingress/
  fi
  cd kubernetes-ingress/deployments/helm-chart
  kubectl apply -f crds/
  helm upgrade nginx-ingress . \
    --install \
    --namespace nginx-ingress \
    --create-namespace
  cd -
  until kubectl wait pod --all --for=condition=Ready --namespace  nginx-ingress
  do
    echo "warning: resources don't exist"
    sleep 1
  done
  echo "info: resources exist"
  kubectl wait pod --all --for=condition=Ready --namespace  nginx-ingress --timeout=120s
fi
