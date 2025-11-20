#!/bin/bash
/usr/sbin/useradd -s /bin/bash -m ritesh;
mkdir /home/ritesh/.ssh;
chmod -R 700 /home/ritesh;
echo "ssh-rsa XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX ritesh@DESKTOP-0XXXXXX" >> /home/ritesh/.ssh/authorized_keys;
chmod 600 /home/ritesh/.ssh/authorized_keys;
chown ritesh:ritesh /home/ritesh/.ssh -R;
echo "ritesh  ALL=(ALL)  NOPASSWD:ALL" > /etc/sudoers.d/ritesh;
chmod 440 /etc/sudoers.d/ritesh;

#################################### Install rsyslog ###########################################

yum install -y rsyslog
systemctl start rsyslog && systemctl enable rsyslog

#################################### Install OSCAP ##############################################

yum install -y openscap-scanner scap-security-guide
oscap xccdf eval --oval-results --profile xccdf_org.ssgproject.content_profile_standard --results-arf /tmp/arf.xml --report /tmp/report.html /usr/share/xml/scap/ssg/content/ssg-al2023-ds.xml
oscap xccdf generate fix --fix-type ansible --result-id "" --fetch-remote-resources /tmp/arf.xml > /opt/playbook-almalinux2023.yml
