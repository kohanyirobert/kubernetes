# Must create a StorageClass before using PersistentVolumeClaims.
# https://kubernetes.io/blog/2019/04/04/kubernetes-1.14-local-persistent-volumes-ga/#how-to-use-a-local-persistent-volume
kubectl apply -f - << EOF
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
EOF
