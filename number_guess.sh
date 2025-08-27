#!/bin/bash

#prompt for username
echo " Enter your username: "
read USERNAME
echo $USERNAME
#generates a random number

SECRET_NUMBER=$(( RANDOM ))
echo $SECRET_NUMBER