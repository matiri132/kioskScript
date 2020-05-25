#!/bin/bash
echo "SETING VARS..."
APPDIR="/home/$USER/webapps"
APPNAME='myapp'
HOST_NAME='localhost'
SERVERNAME='localhost'
DOMAINNAME='localhost'
VENV_NAME='appVenv'
WD=$(pwd)

#Preparing config files
sed -i "s/HOSTNAME/${HOST_NAME}/g" ${WD}/ssidapp.py

sed -i "s/APPDIR/\/home\/$USER\/webapps/g" ${WD}/ssidappini
sed -i "s/APPNAME/${APPNAME}/g" ${WD}/ssidappini

sed -i "s/APPNAME/${APPNAME}/g" ${WD}/rc.local
sed -i "s/APPDIR/\/home\/$USER\/webapps/g" ${WD}/ssidservice
#sed -i "s/APPNAME/${APPNAME}/g" ${WD}/ssidservice
#sed -i "s/APPDIR/\/home\/$USER\/webapps/g" ${WD}/ssidservice
#sed -i "s/USER/$USER/g" ${WD}/ssidservice
#sed -i "s/VENVNAME/${VENV_NAME}/g" ${WD}/ssidservice

#sed -i "s/SERVERNAME/${SERVERNAME}/g" ${WD}/ssidnginx
#sed -i "s/DOMAINNAME/${DOMAINNAME}/g" ${WD}/ssidnginx
#sed -i "s/APPDIR/\/home\/$USER\/webapps/g" ${WD}/ssidnginx
sed -i "s/APPNAME/${APPNAME}/g" ${WD}/ssidnginx

#sed -i "s/USER/$USER/g" ${WD}/appSv
#sed -i "s/MYAPP/${APPNAME}/g" ${WD}/appSv


echo "INSTALLING DEPENDENCIES..."
#Install dependencies
#Python dep
if [ ! -x "$(command -v python3)" ]; then
	echo "Installing Python3..."
	sudo apt install python3-pip python3-dev build-essential libssl-dev libffi-dev python3-setuptools python3-venv 
fi
#Nginx dep
if [ ! -x "$(command -v nginx))" ]; then
	echo "Installing NGINX..."
	sudo apt install nginx
fi

echo "INSTALL Python PACKAGES..."
sudo pip install wheel flask
sudo pip install uwsgi

echo "SETUP FLASK APP..."
if [[ ! -d ${APPDIR} ]]
then
	mkdir ${APPDIR}
	sudo chown www-data ${APPDIR}
fi

sudo cp ${WD}/ssidapp.py ${APPDIR}/ssidapp.py

#Set virtualenv
#python3 -m venv ${APPDIR}/${VENV_NAME}
#Activate the virtual environment
#source ${APPDIR}/${VENV_NAME}/bin/activate
#Now you are on the virtual env -> deactivate to quit
#installing uwsgi on the virtual environment
#pip install wheel uwsgi flask
#deactivate

#Install application
sudo cp ${WD}/ssidappini ${APPDIR}/${APPNAME}.ini
#cp ${WD}/ssidapp.py ${APPDIR}/ssidapp.py
#cp ${WD}/wsgi.py ${APPDIR}/wsgi.py

#Creating SERVICE
#sudo cp ${WD}/ssidservice /etc/systemd/system/${APPNAME}.service
#sudo systemctl start ${APPNAME}
#sudo systemctl enable ${APPNAME}

#Configure NGINX
sudo rm /etc/nginx/sites-enabled/default
sudo cp ${WD}/ssidnginx /etc/nginx/sites-available/${APPNAME}
sudo ln -s /etc/nginx/sites-available/${MYAPP} /etc/nginx/sites-enabled
sudo systemctl restart nginx
#if [ -x "$(command -v ufw))" ]; then
#	echo "Configure firewall..."
	#sudo ufw allow 'Nginx Full'
#fi

