#!/bin/bash
#

PACKAGES="fail2ban fail2ban-systemd"

echo "Setup starting: fail2ban"

declare -A osInfo;
osInfo[/etc/redhat-release]=dnf
osInfo[/etc/arch-release]=pacman
osInfo[/etc/gentoo-release]=emerge
osInfo[/etc/SuSE-release]=zypp
osInfo[/etc/debian_version]=apt
osInfo[/etc/alpine-release]=apk

for f in ${!osInfo[@]}
do
    if [[ -f $f ]];then
        echo "Using ${osInfo[$f]}"
        if [[ "${osInfo[$f]}" == "dnf" ]]; then
          ${osInfo[$f]} install -y epel-release
          ${osInfo[$f]} install -y ${PACKAGES}
          ${osInfo[$f]} update -y selinux-policy*
        elif [[ "${osInfo[$f]}" == "apt" ]]; then
          ${osInfo[$f]} install ${PACKAGES}

        fi
    fi
done

cp -pf /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

cat > /etc/fail2ban/jail.d/sshd.local << EOL
[sshd]
enabled = true
filter   = sshd
port = ssh
logpath = /var/log/auth.log
maxretry = 3
bantime = 1200
EOL

systemctl enable firewalld
systemctl start firewalld

systemctl enable fail2ban
systemctl start fail2ban

echo "Completed setup: Fail2Ban"
