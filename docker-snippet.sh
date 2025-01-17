#!/bin/bash

mkdir -p /var/lib/vz/snippets

cat <<EOF > /var/lib/vz/snippets/docker.yaml
#cloud-config
runcmd:
    - apt update
    - apt install ca-certificates curl
    - install -m 0755 -d /etc/apt/keyrings
    - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    - chmod a+r /etc/apt/keyrings/docker.gpg
    - echo "deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \$(. /etc/os-release && echo "\$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    - apt update
    - apt install -y qemu-guest-agent gnupg docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    - usermod -aG docker \$USER
    - reboot
EOF

chmod 644 /var/lib/vz/snippets/docker.yaml

echo "File /var/lib/vz/snippets/docker.yaml created successfully."
