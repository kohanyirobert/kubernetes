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
    echo "warning: resources don't exist yet in namespace nginx-ingress"
    sleep 1
  done
  kubectl wait pod --all --for=condition=Ready --namespace  nginx-ingress --timeout=120s
fi
