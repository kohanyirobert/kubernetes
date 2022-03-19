# Installs MetalLB in order to be able to use the LoadBalancer Service type
kubectl get configmap kube-proxy -n kube-system -o yaml \
  | sed -e "s/strictARP: false/strictARP: true/" \
  | kubectl apply -f - -n kube-system

metallb_version=0.12.1
if ! kubectl wait pod --all --for=condition=Ready --namespace metallb-system --timeout=0s
then
  kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v$metallb_version/manifests/namespace.yaml
  kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v$metallb_version/manifests/metallb.yaml
  # https://metallb.universe.tf/configuration/
  kubectl apply -f - << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 172.31.0.1-172.31.255.254
EOF
  until kubectl wait pod --all --for=condition=Ready --namespace metallb-system
  do
    echo "warning: resources don't exist"
    sleep 1
  done
  echo "info: resources exist"
  kubectl wait pod --all --for=condition=Ready --namespace metallb-system --timeout=120s
fi
