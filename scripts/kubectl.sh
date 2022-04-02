# Installs Bash completion for kubectl
# https://kubernetes.io/docs/tasks/tools/included/optional-kubectl-configs-bash-linux/
if ! grep -q 'source <(kubectl completion bash)' $HOME/.bashrc
then
  echo 'source <(kubectl completion bash)' >> $HOME/.bashrc
  echo 'alias k=kubectl' >> $HOME/.bashrc
  echo 'complete -F __start_kubectl k' >> $HOME/.bashrc
fi
