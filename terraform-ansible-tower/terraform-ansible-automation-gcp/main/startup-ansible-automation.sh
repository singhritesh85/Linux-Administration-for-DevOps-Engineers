#!/bin/bash
/usr/sbin/useradd -s /bin/bash -m ritesh;
mkdir /home/ritesh/.ssh;
chmod -R 700 /home/ritesh;
echo "ssh-rsa XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX ritesh@DESKTOP-0XXXXXX" >> /home/ritesh/.ssh/authorized_keys;
chmod 600 /home/ritesh/.ssh/authorized_keys;
chown ritesh:ritesh /home/ritesh/.ssh -R;
echo "ritesh  ALL=(ALL)  NOPASSWD:ALL" > /etc/sudoers.d/ritesh;
chmod 440 /etc/sudoers.d/ritesh;

#################################################### create a user to login using SSH ##################################################################

useradd -s /bin/bash -m dexter;
echo "Password@#795" | passwd dexter --stdin;
echo "Password@#795" | passwd root --stdin;
sed -i '0,/PasswordAuthentication no/s//PasswordAuthentication yes/' /etc/ssh/sshd_config;
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
sed -i '0,/PasswordAuthentication no/s//PasswordAuthentication yes/' /etc/ssh/sshd_config.d/50-cloud-init.conf
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config.d/50-cloud-init.conf
systemctl reload sshd;
echo "dexter  ALL=(ALL)  NOPASSWD:ALL" >> /etc/sudoers

#################################################### Installation of Required Packages ##################################################################

yum install -y google-cloud-cli-gke-gcloud-auth-plugin vim zip unzip wget git subscription-manager policycoreutils-python-utils

####################################################### Installation of Ansible-Core ####################################################################

yum install -y ansible-core

##################################################### Installation Google-Cloud-Ops-Agent ###############################################################

curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install
systemctl status google-cloud-ops-agent
