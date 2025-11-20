#!/bin/bash
/usr/sbin/useradd -s /bin/bash -m ritesh;
mkdir /home/ritesh/.ssh;
chmod -R 700 /home/ritesh;
echo "ssh-rsa XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX ritesh@DESKTOP-0XXXXXX" >> /home/ritesh/.ssh/authorized_keys;
chmod 600 /home/ritesh/.ssh/authorized_keys;
chown ritesh:ritesh /home/ritesh/.ssh -R;
echo "ritesh  ALL=(ALL)  NOPASSWD:ALL" > /etc/sudoers.d/ritesh;
chmod 440 /etc/sudoers.d/ritesh;

#################################### Install required packages #################################

yum install -y vim zip unzip wget git

#################################### Install oscap #############################################

yum install -y openscap-scanner scap-security-guide
oscap xccdf eval --oval-results --profile cis --results-arf /tmp/arf.xml --report /tmp/report.html /usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml
oscap xccdf generate fix --fix-type ansible --result-id "" --fetch-remote-resources /tmp/arf.xml > /opt/playbook-rhel9.yml

