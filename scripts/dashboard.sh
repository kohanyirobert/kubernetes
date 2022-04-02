# Installs Kubernetes dashboard and configures access as per the default documentation here: https://github.com/kubernetes/dashboard/
# Notes:
# - the token needed to access the dashboard is printed to standard output
# - there are several ways to access the dashboard from outside localhost
#   1. via proxy (which is subpar)
#   1. via port-forward
#   
#     kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 8443:443 --address 172.16.0.97
#   1. edit the kubernetes-dashboard service's definition and
#     - add an external IP (e.g. add an `externalIPs` array to the YAML and the node's IP)
#     - change the ClusterIP type of the service to NodePort and access the service using the allocated dynamic port via HTTPS
#     - change the ClusterIP type of the service to LoadBalancer and do the same as above but without the dynamic port
dashboard_version=2.5.1
if ! kubectl wait pod --all --for=condition=Ready --namespace kubernetes-dashboard --timeout=0s
then
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v$dashboard_version/aio/deploy/recommended.yaml
  until kubectl wait pod --all --for=condition=Ready --namespace=kubernetes-dashboard --timeout=0s
  do
    echo "warning: resources don't exist"
    sleep 1
  done
  echo "info: resources exist"
  kubectl wait pod --all --for=condition=Ready --namespace=kubernetes-dashboard --timeout=120s

  kubectl apply -f - << EOF
  apiVersion: v1
  kind: ServiceAccount
  metadata:
    name: vagrant
    namespace: kubernetes-dashboard
  EOF
  kubectl apply -f - << EOF
  apiVersion: rbac.authorization.k8s.io/v1
  kind: ClusterRoleBinding
  metadata:
    name: vagrant
  roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: ClusterRole
    name: cluster-admin
  subjects:
  - kind: ServiceAccount
    name: vagrant
    namespace: kubernetes-dashboard
  EOF
  kubectl apply -f - << EOF
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: dashboard-ingress
    namespace: kubernetes-dashboard
    annotations:
      nginx.ingress.kubernetes.io/rewrite-target: /
  spec:
    ingressClassName: nginx
    rules:
    - http:
        paths:
        - path: /testpath
          pathType: Prefix
          backend:
            service:
              name: test
              port:
                number: 80

EOF

  sleep 3
fi

sa_secret_name=$(kubectl get sa vagrant -n kubernetes-dashboard -o jsonpath="{.secrets[0].name}")
sa_secret=$(kubectl get secret $sa_secret_name -n kubernetes-dashboard)
token=$(kubectl get secret $sa_secret_name -n kubernetes-dashboard -o go-template="{{.data.token | base64decode}}")
echo $token
