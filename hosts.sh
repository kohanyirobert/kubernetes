# Appends IPs of all nodes on every node to /etc/hosts
node_hostname=$1
node_ip=$2

grep --quiet cluster-endpoint /etc/hosts \
  || echo "$node_ip cluster-endpoint" \
  | sudo tee --append /etc/hosts

grep --quiet "$node_ip $node_hostname" /etc/hosts \
  || echo "$node_ip $node_hostname" \
  | sudo tee --append /etc/hosts
