#!/bin/bash
echo "SETING VARS..."
APPDIR="/home/$USER/webapps"
APPNAME='myapp'
SV_NAME='localhost'
WD=$(pwd)

#Preparing config files
#sed -i "s/MYAPP/${APPNAME}/g" ${WD}/wsgiIni
#sed -i "s/MYAPP/${APPNAME}/g" ${WD}/wsgiConf
#sed -i "s/USER/$USER/g" ${WD}/wsgiConf
#sed -i "s/USER/$USER/g" ${WD}/appSv
#sed -i "s/MYAPP/${APPNAME}/g" ${WD}/appSv
#sed -i "s/SERVERNAME/${SV_NAME}/g" ${WD}/appSv


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


echo "SETUP VIRTUAL ENV..."
#Set up an AppDir and VirtualEnv
if [[ ! -d ${APPDIR} ]]
then
	mkdir ${APPDIR}
fi

#Set virtualenv
python3 -m venv ${APPDIR}/appVenv
#Activate the virtual environment
source ${APPDIR}/appVenv/bin/activate
#Now you are on the virtual env -> deactivate to quit
#installing uwsgi on the virtual environment
pip install wheel
pip install uwsgi flask
deactivate

cp ${WD}/ssidapp.py ${APPDIR}/ssidapp.py
cp ${WD}/wsgi.py ${APPDIR}/wsgi.py



