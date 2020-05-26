#!/bin/bash
echo "SETING VARS..."
APPDIR="/home/$USER/webapps"
APPNAME='myapp'
HOST_NAME='0.0.0.0'
DOMAINNAME='localhost'
WD=$(pwd)

if[ $1 = "install"]
then
	#Preparing config files
	sed -i "s/HOSTNAME/${HOST_NAME}/g" ${WD}/ssidapp.py

	sed -i "s/APPDIR/\/home\/$USER\/webapps/g" ${WD}/ssidappini
	sed -i "s/APPNAME/${APPNAME}/g" ${WD}/ssidappini

	sed -i "s/APPNAME/${APPNAME}/g" ${WD}/ssidservice
	sed -i "s/APPDIR/\/home\/$USER\/webapps/g" ${WD}/ssidservice
	sed -i "s/USER/$USER/g" ${WD}/ssidservice

	sed -i "s/DOMAINNAME/${DOMAINNAME}/g" ${WD}/ssidnginx
	sed -i "s/APPNAME/${APPNAME}/g" ${WD}/ssidnginx


	echo "INSTALLING DEPENDENCIES..."
	#Install dependencies
	if[ $2 = "full"]
	then
		install_packages();
	fi

	echo "SETUP FLASK APP..."
	if [[ ! -d ${APPDIR} ]]
	then
		mkdir ${APPDIR}
		chown www-data ${APPDIR}
	fi

	#Install application
	cp ${WD}/ssidappini ${APPDIR}/${APPNAME}.ini
	cp ${WD}/ssidapp.py ${APPDIR}/ssidapp.py
	cp ${WD}/wsgi.py ${APPDIR}/wsgi.py

	#Creating SERVICE
	cp ${WD}/ssidservice /etc/systemd/system/${APPNAME}.service
	systemctl start ${APPNAME}
	systemctl enable ${APPNAME}

	#Configure NGINX
	rm /etc/nginx/sites-enabled/default
	cp ${WD}/ssidnginx /etc/nginx/sites-available/${APPNAME}
	ln -s /etc/nginx/sites-available/${APPNAME} /etc/nginx/sites-enabled/

	if [ -x "$(command -v ufw))" ]; then
		echo "Configure firewall..."
		ufw allow 'Nginx Full'
	fi

	systemctl restart nginx
fi

if[ $1 = "uninstall"]
then
	#Remove WEBAPP	
	rm -R ${APPDIR}
	#Remove Service
	systemctl stop ${APPNAME}
	systemctl disable ${APPNAME}
	rm /etc/systemd/system/${APPNAME}.service
	#Set default nginx
	rm /etc/nginx/sites-enabled/${APPNAME}
	rm /etc/nginx/sites-available/${APPNAME}
	ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/
	systemctl reload nginx
fi

install_packages(){
	#Python dep
	sudo apt install python3-dev build-essential libssl-dev libffi-dev python3-setuptools 

	#Nginx dep
	if [ ! -x "$(command -v nginx))" ]; then
		echo "Installing NGINX..."
		sudo apt install nginx
	fi
	#Sed omstaññ
	if [ ! -x "$(command -v sed))" ]; then
		echo "Installing SED..."
		sudo apt install sed
	fi

	echo "INSTALL Python PACKAGES..."
	if [ ! -x "$(command -v pip3))" ]; then
		echo "Installing PIP..."
		sudo apt install python3-pip 	
	fi

	sudo pip3 install wheel flask
	sudo pip3 install uwsgi
}