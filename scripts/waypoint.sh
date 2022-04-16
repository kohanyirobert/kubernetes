waypoint_namespace=waypoint

waypoint_version=0.8.1
waypoint_os=linux
waypoint_platform=amd64
waypoint_archive=waypoint_${waypoint_version}_${waypoint_os}_${waypoint_platform}.zip
waypoint_url=https://releases.hashicorp.com/waypoint/$waypoint_version/$waypoint_archive
wget --no-verbose --timestamping $waypoint_url
unzip -u $waypoint_archive
sudo install \
  --verbose \
  --mode=+x waypoint /usr/local/bin/waypoint

kubectl apply -f - << EOF
apiVersion: v1
kind: Namespace
metadata:
  name: $waypoint_namespace
EOF

waypoint install \
  -accept-tos \
  -platform=kubernetes \
  -k8s-storageclassname=openebs-hostpath \
  -k8s-storage-request=1Gi \
  -k8s-namespace=$waypoint_namespace

url=$(kubectl get service \
  --namespace=$waypoint_namespace \
  -o jsonpath='https://{.items[0].status.loadBalancer.ingress[0].ip}:{.items[0].spec.ports[?(@.name=="http")].targetPort}')

token=$(waypoint user token)

echo $url
echo $token
