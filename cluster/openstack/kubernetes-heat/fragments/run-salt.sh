#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

. /etc/sysconfig/heat-params

rm -rf /kube-install
mkdir -p /kube-install
cd /kube-install

curl "$KUBERNETES_SERVER_URL" -o kubernetes-server.tar.gz
curl "$KUBERNETES_SALT_URL" -o kubernetes-salt.tar.gz

tar xzf kubernetes-salt.tar.gz
./kubernetes/saltbase/install.sh kubernetes-server.tar.gz


# Salt server runs at locahost
echo "127.0.0.1 salt" >> /etc/hosts

if ! which salt-call >/dev/null 2>&1; then
  # Install salt binaries
  echo "[Info] Install salt binaries"
  curl -sS -L --connect-timeout 20 --retry 6 --retry-delay 10 https://bootstrap.saltstack.com | sh -s
fi


# Currently heat template tells a lie that the target is Vagrant. If Vagrant cloud provider is
# enabled, "Unable to construct api.Node object for kubelet" error will occur.
sed -e 's/{{cloud_provider}}//' -i /srv/salt/kubelet/default

# Run salt-call
# salt-call wants to start docker daemon but is unable to.
# See <https://github.com/projectatomic/docker-storage-setup/issues/77>.
# Run salt-call in background and make cloud-final finished.
echo "salt-call"
salt-call --local state.highstate && $$wc_notify --data-binary '{"status": "SUCCESS"}' || \
  $$wc_notify --data-binary '{"status": "FAILURE"}' &
