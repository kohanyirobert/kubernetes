sudo systemctl disable motd-news.service
sudo systemctl disable motd-news.timer
sudo chmod -x /etc/update-motd.d/*

dashboard_namespace=kubernetes-dashboard
dashboard_url=$(kubectl get svc \
  --namespace $dashboard_namespace \
  -o jsonpath="https://{.status.loadBalancer.ingress[0].ip}" \
  kubernetes-dashboard)
dashboard_secret_name=$(kubectl get sa \
  --namespace $dashboard_namespace \
  -o jsonpath="{.secrets[0].name}" \
  vagrant)
dashboard_token=$(kubectl get secret \
  --namespace $dashboard_namespace \
  -o go-template="{{.data.token | base64decode}}" \
  $dashboard_secret_name)

waypoint_namespace=waypoint
waypoint_url=$(kubectl get service \
  --namespace=$waypoint_namespace \
  -o jsonpath='https://{.status.loadBalancer.ingress[0].ip}:{.spec.ports[?(@.name=="http")].targetPort}' \
  waypoint)
waypoint_token=$(waypoint user token)
cat << EOF | sudo tee /etc/motd
# Dashboard
URL: $dashboard_url
Token: $dashboard_token

# Waypoint
URL: $waypoint_url
Token: $waypoint_token
EOF
