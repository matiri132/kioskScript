#!/bin/bash
echo "SETING VARS..."
APPDIR='webapps'
APPNAME='myapp'
WD=$(pwd)

#Preparing config files
sed -i "s/MYAPP/${APPNAME}/g" ${WD}/wsgiIni
sed -i "s/MYAPP/${APPNAME}/g" ${WD}/wsgiConf
sed -i "s/USER/${USER}/g" ${WD}/wsgiConf

echo "INSTALLING DEPENDENCIES..."
#Install dependencies
##sudo apt update
#Python dep
if [ ! -x "$(command -v python3)" ]; then
	echo "Installing Python3..."
	sudo apt install python-dev python-pip
fi

if [ ! -x "$(command -v n))" ]; then
	echo "Installing NGINX..."
	sudo apt install python-dev python-pip
fi
##sudo pip install virtualenv
#Nginx dep
##sudo apt install nginx

echo "SETUP VIRTUAL ENV..."
#Set up an AppDir and VirtualEnv
if [ ! -d "~/${APPDIR}" ]; then
	mkdir ~/${APPDIR}
fi

cd ~/${APPDIR}
#Set virtualenv
virtualenv appenv
#Activate the virtual environment
source appenv/bin/activate
#Now you are on the virtual env -> deactivate to quit
#installing uwsgi on the virtual environment
#pip install uwsgi
deactivate

echo "WSGI CONFIGURATION..."
#touch ~/${APPDIR}/${APPNAME}.ini
#sudo touch /etc/init/${APPNAME}.conf
#cat wsgiIni >> ~/${APPDIR}/${APPNAME}.ini
#sudo cat wsgiConf >> /etc/init/${APPNAME}.conf
cp ${WD}/wsgiIni ~/${APPDIR}/${APPNAME}.ini
sudo cp ${WD}/wsgiConf /etc/init/${APPNAME}.conf
