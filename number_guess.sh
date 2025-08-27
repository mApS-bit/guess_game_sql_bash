#!/bin/bash

# Prompt for username
echo "Enter your username:"
read USERNAME

# Generate random number
SECRET_NUMBER=$(( 1 + RANDOM % 1000 ))

# Connect to database
PSQL='psql --username=freecodecamp --dbname=number_guess -t --no-align -c'

# Check if user exists
IS_NEW_USER=$($PSQL "SELECT user_name FROM users WHERE user_name = '$USERNAME'")

if [[ -z $IS_NEW_USER ]]; then
  # Insert new user with initial values
  $PSQL "INSERT INTO users(user_name, games_played, best_game) VALUES('$USERNAME', 0, 1000)"
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else 
  # Get user data
  USER_DATA=$($PSQL "SELECT games_played, best_game FROM users WHERE user_name = '$USERNAME'")
  IFS="|" read GAMES_PLAYED BEST_GAME <<< "$USER_DATA"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"

NUMBER_OF_GUESSES=0
USER_GUESS=""

while true; do
  read USER_GUESS
  
  # Validate integer input
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi
  
  (( NUMBER_OF_GUESSES++ ))
  
  if (( USER_GUESS == SECRET_NUMBER )); then
    break
  elif (( USER_GUESS > SECRET_NUMBER )); then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
done

# Update database
if [[ -z $IS_NEW_USER ]]; then
  # For new users, set first game
  $PSQL "UPDATE users SET games_played = 1, best_game = $NUMBER_OF_GUESSES WHERE user_name = '$USERNAME'"
else
  # For existing users, update stats
  $PSQL "UPDATE users SET games_played = games_played + 1, best_game = LEAST(best_game, $NUMBER_OF_GUESSES) WHERE user_name = '$USERNAME'"
fi

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"