#!/bin/bash

echo "Hello Consul Client API!"

# Install Consul.  This creates...
# 1 - a default /etc/consul.d/consul.hcl
# 2 - a default systemd consul.service file
curl -fsSL https://apt.releases.hashicorp.com/gpg -o gpg.txt
sudo apt-key add gpg.txt
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install consul unzip awscli
rm gpg.txt

# aws eks --region=us-east-2 update-kubeconfig --name opsschool-eks-hbVC2yo8

#TODO add user ec2-user to group consul and avoid cp kubeconfig file to his dir.
#sudo mkdir -p /home/consul/.kube
#sudo cp /home/ec2-user/.kube/config /home/consul/.kube/config

# Grab instance IP
local_ip=`ip -o route get to 169.254.169.254 | sed -n 's/.*src \([0-9.]\+\).*/\1/p'`

# Modify the default consul.hcl file
cat > /etc/consul.d/consul.hcl <<- EOF
node_name = "consul-client-ubuntu"
data_dir = "/opt/consul"
datacenter = "opsschool"
log_level  = "DEBUG"
server = false
client_addr = "0.0.0.0"
bind_addr = "0.0.0.0"
advertise_addr = "$local_ip"
# retry_join = ["provider=k8s label_selector=\"app=consul,component=server\" kubeconfig=$HOME/.kube/config namespace=\"consul\""]
encrypt = "uDBV4e+LbFW3019YKPxIrh=="
# encrypt_verify_incoming = true
# encrypt_verify_outgoing = true
# disable_keyring_file = true
EOF

# Start Consul
sudo systemctl start consul

# Pull down and install Fake Service
curl -LO https://github.com/nicholasjackson/fake-service/releases/download/v0.22.7/fake_service_linux_amd64.zip
unzip fake_service_linux_amd64.zip
mv fake-service /usr/local/bin
chmod +x /usr/local/bin/fake-service

# Fake Service Systemd Unit File
cat > /etc/systemd/system/api.service <<- EOF
[Unit]
Description=API
After=syslog.target network.target

[Service]
Environment="MESSAGE=api"
Environment="NAME=api"
ExecStart=/usr/local/bin/fake-service
ExecStop=/bin/sleep 5
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload unit files and start the API
systemctl daemon-reload
systemctl start api

# Consul Config file for our fake API service
cat > /etc/consul.d/api.hcl <<- EOF
service {
 name = "api"
 port = 9090
}
EOF

systemctl restart consul

mkdir -p /etc/systemd/resolved.conf.d

# Point DNS to Consul's DNS
cat > /etc/systemd/resolved.conf.d/consul.conf <<- EOF
[Resolve]
DNS=127.0.0.1
Domains=~consul
EOF

# Because our Ubuntu's systemd is < 245, we need to redirect traffic to the correct port for the DNS changes to take effect
iptables --table nat --append OUTPUT --destination localhost --protocol udp --match udp --dport 53 --jump REDIRECT --to-ports 8600
iptables --table nat --append OUTPUT --destination localhost --protocol tcp --match tcp --dport 53 --jump REDIRECT --to-ports 8600

# Restart systemd-resolved so that the above DNS changes take effect
systemctl restart systemd-resolved
