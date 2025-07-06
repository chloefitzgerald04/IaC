# url --url https://repo.almalinux.org/almalinux/9.5/BaseOS/x86_64/kickstart/

text
# skipx
eula --agreed
firstboot --disabled
lang en_US
keyboard --vckeymap=us --xlayouts='us'
timezone Europe/London

rootpw ${root_password}

network  --bootproto=dhcp --ipv6=auto --activate


clearpart --all --initlabel
ignoredisk --only-use=sda
part / --fstype="ext4" --grow --size=1
bootloader --location=mbr --boot-drive=sda

services --disabled="kdump" --enabled="sshd,rsyslog,chronyd"

sshkey --username=root '${ssh_public_key}'

<<<<<<< HEAD
user --name=cadmin --groups=wheel --iscrypted --password=$6$rounds=4096$n5UhTZUrBh1plr6X$RPpcZc2FQViT1jm.21VFnNu/Gt67tsam9k83UE.5RyLw6VmtXFZA4UyAq2ad3tTliIUKBhmLzoIn8o8eck4as/
sshkey --username=cadmin '${ssh_public_key}'

user --name=ansible --groups=wheel --iscrypted --password=$6$rounds=4096$0.9cLGrjWRsgekdp$vhmF0vx2P3kIYFw5FopudqN8FxVAh85N0RoacfaOJTtg8hDiAyAUCYGuNcZNuT9GYchLovo3Zvcq5TFTh4Glp1
sshkey --username=ansible "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKvPyNpFniifG62ydUeTPGVjxD4QDYM7PfQY7DJSu2cp eddsa-key-20250603"

=======
>>>>>>> parent of ded4bc0 (Add files via upload)
%packages --ignoremissing
@^minimal-environment
-iwl*firmware

%end

reboot

%post

<<<<<<< HEAD
dnf update -y
=======
yum update -y
>>>>>>> parent of ded4bc0 (Add files via upload)

sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
echo "PermitRootLogin yes" > /etc/ssh/sshd_config.d/00-allow-root-ssh.conf

<<<<<<< HEAD
dnf clean all
=======
yum clean all
>>>>>>> parent of ded4bc0 (Add files via upload)
%end
