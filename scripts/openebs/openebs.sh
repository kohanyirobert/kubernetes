# https://artifacthub.io/packages/helm/openebs/openebs
# https://github.com/openebs/jiva-operator/blob/develop/docs/quickstart.md
openebs_namespace=openebs
openebs_version=3.1.0
if ! kubectl wait pod --all --for=condition=Ready --namespace $openebs_namespace --timeout=0s
then
  helm repo add openebs https://openebs.github.io/charts
  helm repo update
  helm upgrade \
    --install \
    --namespace $openebs_namespace \
    --create-namespace \
    --version $openebs_version \
    --set jiva.enabled=true \
    openebs \
    openebs/openebs

  until kubectl wait pod --all --for=condition=Ready --namespace $openebs_namespace
  do
    echo "warning: resources don't exist"
    sleep 1
  done
  echo "info: resources exist"
  kubectl wait pod --all --for=condition=Ready --namespace $openebs_namespace --timeout=120s

  # https://kubernetes.io/docs/tasks/manage-kubernetes-objects/update-api-object-kubectl-patch/#summary
  kubectl patch jivavolumepolicies \
    --namespace $openebs_namespace openebs-jiva-default-policy \
    --type=merge \
    --patch='
spec:
  replica:
    tolerations:
      - effect: NoSchedule
        key: node-role.kubernetes.io/master
        operator: Exists
'
fi
