#!/bin/bash
if  [ "$(curl https://www.iqair.com/germany/baden-wuerttemberg/wiesloch | grep -Eo " Open your windows")" = " Open your windows" ] ; 
then
	 echo "Good air outside"
else
	 echo "Bad air outside"
fi
