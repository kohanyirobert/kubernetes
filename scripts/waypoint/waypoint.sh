namespace=$1

waypoint_version=0.8.1
waypoint_os=linux
waypoint_platform=amd64
waypoint_archive=waypoint_${waypoint_version}_${waypoint_os}_${waypoint_platform}.zip
waypoint_url=https://releases.hashicorp.com/waypoint/$waypoint_version/$waypoint_archive
wget --timestamping $waypoint_url
unzip -f $waypoint_archive
sudo install \
  --verbose \
  --mode=+x waypoint /usr/local/bin/waypoint

kubectl apply -f - << EOF
apiVersion: v1
kind: Namespace
metadata:
  name: $namespace
EOF

waypoint install \
  -platform=kubernetes \
  -accept-tos \
  -k8s-namespace=$namespace \
  -k8s-storageclassname=local-storage \
  -k8s-storage-request=1Gi

url=$(kubectl get service \
  --namespace=$namespace \
  -o jsonpath='https://{.items[0].status.loadBalancer.ingress[0].ip}:{.items[0].spec.ports[?(@.name=="http")].targetPort}')

token=$(waypoint user token)

echo $url
echo $token
