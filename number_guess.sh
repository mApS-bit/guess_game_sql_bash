#!/bin/bash

#prompt for username
echo "Enter your username:"
read USERNAME
#echo $USERNAME
#generates a random number

SECRET_NUMBER=$(( 1 + RANDOM % 1000 ))
#echo $SECRET_NUMBER

#conect to database
PSQL='psql --username=freecodecamp --dbname=number_guess -t --no-align -c'

IS_NEW_USER=$($PSQL "SELECT user_name FROM users WHERE user_name = '$USERNAME'")

if [[ -z $IS_NEW_USER ]]; then
  $PSQL "INSERT INTO users(user_name) VALUES('$USERNAME')"
  echo "Welcome, $USERNAME! It looks like this is your first time here."

else 
  USER_DATA=$($PSQL "SELECT games_played, best_game FROM users WHERE user_name = '$USERNAME'")
  IFS="|" read GAMES_PLAYED BEST_GAME <<< "$USER_DATA"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi
echo "Guess the secret number between 1 and 1000:"
read USER_GUESS
while [[ ! $USER_GUESS =~ ^[0-9]+$ ]];do
  echo "That is not an integer, guess again:"
  read USER_GUESS
done
NUMBER_OF_GUESSES=1
echo "The secret number is $SECRET_NUMBER"
while (( USER_GUESS != SECRET_NUMBER )); do
  if (( USER_GUESS > SECRET_NUMBER )); then
    echo "It's higher than that, guess again:"
    read USER_GUESS
  else
    echo "It's lower than that, guess again:"
    read USER_GUESS
  fi
  while [[ ! $USER_GUESS =~ ^[0-9]+$ ]];do
    echo "That is not an integer, guess again:"
    read USER_GUESS
  done
  (( NUMBER_OF_GUESSES++ )) 
done
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"