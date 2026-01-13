#!/usr/bin/env bash

#This script creates two files, namely sshconfig and uipassword

echo "$(date) Reading Terraform outputs"

TF_OUTPUT=$(terraform output -json)

BASTION_IP=$(echo "$TF_OUTPUT" | jq -r '.bastion_public_ip.value')
HAPROXY_IP=$(echo "$TF_OUTPUT" | jq -r '.haproxy_private_ip.value')
WEB1_IP=$(echo "$TF_OUTPUT" | jq -r '.web_private_ips.value[0]')
WEB2_IP=$(echo "$TF_OUTPUT" | jq -r '.web_private_ips.value[1]')
WEB3_IP=$(echo "$TF_OUTPUT" | jq -r '.web_private_ips.value[2]')

if [[ -z "$BASTION_IP" || "$BASTION_IP" == "null" ]]; then
  echo "ERROR: Terraform outputs not found. Run 'terraform apply' first."
  exit 1
fi

echo "$(date) Generating SSH config file"
cat <<EOF > sshconfig

Host bastion
    User ubuntu
    HostName ${BASTION_IP}
    IdentityFile ~/.ssh/id_rsa
    UserKnownHostsFile /dev/null
    StrictHostKeyChecking no
    PasswordAuthentication no

Host haproxy
    User ubuntu
    HostName ${HAPROXY_IP}
    IdentityFile ~/.ssh/id_rsa
    StrictHostKeyChecking no
    PasswordAuthentication no
    ProxyJump bastion

Host web1
    User ubuntu
    HostName ${WEB1_IP}
    IdentityFile ~/.ssh/id_rsa
    StrictHostKeyChecking no
    PasswordAuthentication no
    ProxyJump bastion

Host web2
    User ubuntu
    HostName ${WEB2_IP}
    IdentityFile ~/.ssh/id_rsa
    StrictHostKeyChecking no
    PasswordAuthentication no
    ProxyJump bastion

Host web3
    User ubuntu
    HostName ${WEB3_IP}
    IdentityFile ~/.ssh/id_rsa
    StrictHostKeyChecking no
    PasswordAuthentication no
    ProxyJump bastion
EOF
echo "$(date) SSH config file generated"
chmod 600 sshconfig


echo "$(date) Generating HAProxy UI password file"
cat <<EOF > uipassword
userlist stats_user
    user admin insecure-password CHANGE_ME
EOF
chmod 600 uipassword
