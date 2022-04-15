# Appends IPs of all nodes on every node to /etc/hosts
add_host() {
  pattern=$1
  entry=$2
  grep --quiet "$pattern" /etc/hosts \
    || echo "$entry" \
    | sudo tee --append /etc/hosts
}

node_hostname=$1
node_ip=$2

add_host cluster-endpoint "$node_ip cluster-endpoint"
add_host "$node_ip $node_hostname" "$node_ip $node_hostname"
add_host docker.local "10.0.100.100 docker.local"
