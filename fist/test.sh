#!/bin/bash

APPDIR="/home/$USER/adddir"

if [[ ! -d ${APPDIR} ]]
then
	echo "Create dir"
	mkdir ${APPDIR}
fi

