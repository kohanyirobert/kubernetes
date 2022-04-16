# Installs NGINX Ingress Controller via Helm
# https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-helm/
nginx_ingress_namespace=nginx-ingress
nginx_ingress_version=2.1.1
if ! kubectl wait pod --all --for=condition=Ready --namespace $nginx_ingress_namespace --timeout=0s
then
  if [ ! -d kubernetes-ingress ]
  then
    git clone --branch v$nginx_ingress_version https://github.com/nginxinc/kubernetes-ingress/
  fi
  cd kubernetes-ingress/deployments/helm-chart
  kubectl apply -f crds/
  helm upgrade nginx-ingress . \
    --install \
    --namespace $nginx_ingress_namespace \
    --create-namespace
  cd -
  until kubectl wait pod --all --for=condition=Ready --namespace $nginx_ingress_namespace
  do
    echo "warning: resources don't exist"
    sleep 1
  done
  echo "info: resources exist"
  kubectl wait pod --all --for=condition=Ready --namespace $nginx_ingress_namespace --timeout=120s
fi
