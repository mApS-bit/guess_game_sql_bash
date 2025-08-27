#!/bin/bash

#prompt for username
echo " Enter your username: "
read USERNAME
echo $USERNAME
#generates a random number

SECRET_NUMBER=$(( 1 + RANDOM % 1000 ))
echo $SECRET_NUMBER

#conect to database
PSQL='psql --username=freecodecamp --dbname=number_guess -t --no-align -c'

IS_NEW_USER=$($PSQL "SELECT user_name FROM users WHERE user_name = '$USERNAME'")

if [[ -z $IS_NEW_USER ]]; then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
fi

echo "Guess the secret number between 1 and 1000:"