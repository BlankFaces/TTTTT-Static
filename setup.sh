#!/usr/bin/env bash

echo "Add your key to ssh before anything!"
echo "Resource links:\nhttps://medium.com/@jasonrigden/hardening-ssh-1bcb99cd4cef"
echo "https://geekflare.com/nginx-webserver-security-hardening-guide/"
echo "https://medium.com/@jgefroh/a-guide-to-using-nginx-for-static-websites-d96a9d034940"
echo "-----------------------------------------------------------------------------------"
$waiting = ""

read  -n 1 -p "Done? " waiting

if [ $EUID != 0 ]; then
	# Update & upgrade
	sudo add-apt-repository ppa:certbot/certbot -y
	sudo apt update -y
	sudo apt upgrade -y
	
	# Install programs
	sudo apt install nginx unattended-upgrades libpam-google-authenticator ufw fail2ban software-properties-common python-certbot-nginx -y
	
	# Setup Firewall & ssh
	sudo sed -ri 's/#?Port 22/Port 3121/' /etc/ssh/sshd_config
	sudo sed -ri 's/#?PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/ssh_config
	sudo sed -ri 's/#?ClientAliveInterval 0/ClientAliveInterval 300/' /etc/ssh/ssh_config
	sudo sed -ri 's/#?ClientAliveCountMax 3/ClientAliveCountMax 2/' /etc/ssh/ssh_config
	sudo echo "AllowUsers $USER\nX11Forwarding no\nUsePAM yes\nChallengeResponseAuthentication yes" >> /etc/ssh/ssh_config
	echo "Add https://sign-bunny.glitch.me/ to /etc/issue.net and update sshd to have 'Banner /etc/issue.net' at the bottom"

	cp /etc/update-motd.d/00-header /etc/update-motd.d/backup.00-header
	sudo echo 'figlet "No Trespassing"' >> 

	cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
	mv /etc/fail2ban/jail.conf /etc/fail2ban/jail.conf.bak
	echo "Please setup fail2ban manually, and setup google-authenticator from link"
	read  -n 1 -p "Done? " waiting	
	sudo echo "auth required pam_google_authenticator.so" >> /etc/pam.d/sshd

	cd ~
	git clone https://github.com/arthepsy/ssh-audit.git
	cd ssh-audit
	echo 'Run "python ssh-audit.py labs.seattlebot.net" after setting up fully and follow the rest of the guide'

	# Setup key
	printf "/home/$USER/.ssh/github\n\n" | ssh-keygen -t rsa -b 4096 -C "esther@pastel.codes"
	xclip -selection clipboard < /home/$USER/.ssh/github.pub
	echo "Add the key to the repo"
	read  -n 1 -p "Done? " waiting

	# Pull
	cd /var/www/
	git clone git@github.com:BlankFaces/TTTTT-Static.git
	mv TTTTT-Static ttttt.uk

	# Get SSL cert
	echo 'Please run "sudo certbot --nginx certonly"'
	echo 'And then "sudo crontab -e" adding the line "17 7 * * * certbot renew --post-hook "systemctl reload nginx""'

	# NginX Setup
	echo 'After setting up manually, copy config files into repo on client'

	# Setup auto update
	echo 'Follow https://libre-software.net/ubuntu-automatic-updates/'

	read  -n 1 -p "Done? " waiting

	sudo sed -ri 's/#?PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
	sudo ufw enable
else
	echo "Please run sudo"

fi
