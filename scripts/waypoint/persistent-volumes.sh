# Must create persistent volumes on each node manually for now.
# https://kubernetes.io/blog/2019/04/04/kubernetes-1.14-local-persistent-volumes-ga/#:~:text=Local%20Persistent%20Volumes%20do%20not%20support%20dynamic%20volume%20provisioning
hostname=$1
namespace=$2
directory=$3
capacity=$4

ssh -o StrictHostKeyChecking=no vagrant@$hostname -- mkdir -p $directory

kubectl apply -f - << EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  namespace: $namespace
  name: $hostname
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: $capacity
  volumeMode: Filesystem
  persistentVolumeReclaimPolicy: Delete
  storageClassName: local-storage
  local:
    path: /home/vagrant/$directory
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - $hostname
EOF
