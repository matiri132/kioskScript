#!/bin/bash
echo "SETING VARS..."
APPDIR="/home/$USER/webapps"
APPNAME='myapp'
SV_NAME='localhost'
WD=$(pwd)

#Preparing config files
sed -i "s/MYAPP/${APPNAME}/g" ${WD}/wsgiIni
sed -i "s/MYAPP/${APPNAME}/g" ${WD}/wsgiConf
sed -i "s/USER/$USER/g" ${WD}/wsgiConf
sed -i "s/USER/$USER/g" ${WD}/appSv
sed -i "s/MYAPP/${APPNAME}/g" ${WD}/appSv
sed -i "s/SERVERNAME/${SV_NAME}/g" ${WD}/appSv


echo "INSTALLING DEPENDENCIES..."
#Install dependencies
#Python dep
if [ ! -x "$(command -v python3)" ]; then
	echo "Installing Python3..."
	sudo apt install python-dev python-pip
fi
#Nginx dep
if [ ! -x "$(command -v nginx))" ]; then
	echo "Installing NGINX..."
	sudo apt install nginx
fi

sudo pip install virtualenv

echo "SETUP VIRTUAL ENV..."
#Set up an AppDir and VirtualEnv
if [[ ! -d ${APPDIR} ]]
then
	mkdir ${APPDIR}
fi

cd ${APPDIR}
#Set virtualenv
virtualenv appenv
#Activate the virtual environment
source appenv/bin/activate
#Now you are on the virtual env -> deactivate to quit
#installing uwsgi on the virtual environment
pip install uwsgi
deactivate

echo "WSGI CONFIGURATION..."
#Config files
cp ${WD}/wsgiIni ${APPDIR}/${APPNAME}.ini

if [[ ! -d /etc/init ]]
then
	sudo mkdir /etc/init
fi
sudo cp ${WD}/wsgiConf /etc/init/${APPNAME}.conf
#Python script
cp ${WD}/wsgi.py ${APPDIR}/wsgi.py

sudo cp ${WD}/appSv /etc/nginx/sites-available/${APPNAME}
sudo ln -s /etc/nginx/sites-available/${APPNAME} /etc/nginx/sites-enabled

sudo service nginx restart


