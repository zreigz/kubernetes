#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

. /etc/sysconfig/heat-params

FLANNEL_ETCD_URL="http://${MASTER_IP}:4379"

# Install flannel for overlay
if ! which flanneld > /dev/null 2>&1; then
  apt-get install -y linux-libc-dev gcc git
  curl -L https://storage.googleapis.com/golang/go1.5.3.linux-amd64.tar.gz -o go.tar.gz
  tar -C /usr/local -xzf go.tar.gz
  mkdir /usr/lib/go
  export PATH=$PATH:/usr/local/go/bin
  export GOPATH=/usr/lib/go
  export GOBIN=$GOPATH/bin
  export PATH=$GOPATH:$GOBIN:$PATH
  git clone https://github.com/coreos/flannel.git
  cd flannel; ./build
fi

  cat <<EOF > /etc/init/flanneld.conf
description     "FLANNELD"

start on runlevel [2345]
stop on starting rc RUNLEVEL=[016]
respawn
respawn limit 2 5
exec /flannel/bin/flanneld --etcd-endpoints ${FLANNEL_ETCD_URL} --etcd-prefix=/coreos.com/network --iface=eth0 --ip-masq=true
EOF

initctl start flanneld
