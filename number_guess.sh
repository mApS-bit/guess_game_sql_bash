#!/bin/bash

# Prompt for username
echo "Enter your username:"
read USERNAME

# Generate random number
SECRET_NUMBER=$(( 1 + RANDOM % 1000 ))

# Connect to database
PSQL='psql --username=freecodecamp --dbname=number_guess -t --no-align -c'

# Check if user exists
USER_EXISTS=$($PSQL "SELECT user_name FROM users WHERE user_name = '$USERNAME'")

if [[ -z $USER_EXISTS ]]; then
  # Insert new user
  $PSQL "INSERT INTO users(user_name) VALUES('$USERNAME')"
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else 
  # Get user data - handle NULL values with COALESCE
  USER_DATA=$($PSQL "SELECT COALESCE(games_played, 0), COALESCE(best_game, 0) FROM users WHERE user_name = '$USERNAME'")
  IFS="|" read GAMES_PLAYED BEST_GAME <<< "$USER_DATA"
  
  # If best_game is 0 (meaning no games played), adjust the message
  if [[ $BEST_GAME -eq 0 ]]; then
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took 0 guesses."
  else
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi
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

# Update database - handle first game scenario
if [[ -z $USER_EXISTS ]]; then
  # New user's first game
  $PSQL "UPDATE users SET games_played = 1, best_game = $NUMBER_OF_GUESSES WHERE user_name = '$USERNAME'" > /dev/null
else
  # Existing user - get current best game to compare
  CURRENT_BEST=$($PSQL "SELECT COALESCE(best_game, 1000) FROM users WHERE user_name = '$USERNAME'")
  
  # If it's their first game or they beat their record
  if [[ $CURRENT_BEST -eq 0 ]] || [[ $NUMBER_OF_GUESSES -lt $CURRENT_BEST ]]; then
    NEW_BEST=$NUMBER_OF_GUESSES
  else
    NEW_BEST=$CURRENT_BEST
  fi
  
  $PSQL "UPDATE users SET games_played = COALESCE(games_played, 0) + 1, best_game = $NEW_BEST WHERE user_name = '$USERNAME'" > /dev/null
fi

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"