#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Function to get or create user info
get_user_info() {
  USERNAME=$1
  USER_INFO=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME'")

  if [[ -z $USER_INFO ]]
  then
    # New user
    echo "new"
    # Insert new user
    INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    # Retrieve new user info
    USER_INFO=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME'")
  else
    # Returning user
    echo $USER_INFO
  fi
}

# Function to update game stats
update_game_stats() {
  USER_ID=$1
  NUMBER_OF_GUESSES=$2

  # Get current games played and best game
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$USER_ID")

  # Increment games played
  NEW_GAMES_PLAYED=$((GAMES_PLAYED + 1))

  # Determine if the current game is the best game
  if [[ -z $BEST_GAME || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
  then
    NEW_BEST_GAME=$NUMBER_OF_GUESSES
  else
    NEW_BEST_GAME=$BEST_GAME
  fi

  # Update user stats
  UPDATE_USER_RESULT=$($PSQL "UPDATE users SET games_played=$NEW_GAMES_PLAYED, best_game=$NEW_BEST_GAME WHERE user_id=$USER_ID")
}

# Main game logic function
play_game() {
  SECRET_NUMBER=$(( RANDOM % 10 + 1 ))  
  NUMBER_OF_GUESSES=0
  echo "Guess the secret number between 1 and 1000:"
  while true
  do
    read GUESS

    if ! [[ $GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
    elif [[ $GUESS -lt $SECRET_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
      NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))
    elif [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
      NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))
    else
      NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))
      echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
      update_game_stats $USER_ID $NUMBER_OF_GUESSES
      break
    fi
  done
}

# Main script execution
echo "Enter your username:"
read USERNAME

# Validate username length
if [[ ${#USERNAME} -gt 22 ]]
then
  echo "Username must be 22 characters or less."
  exit 1
fi

# Get user info
USER_INFO=$(get_user_info $USERNAME)

# Check if new user
if [[ $USER_INFO == "new" ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
  USER_ID=$(echo $USER_INFO | cut -d'|' -f1)
  GAMES_PLAYED=$(echo $USER_INFO | cut -d'|' -f2)
  BEST_GAME=$(echo $USER_INFO | cut -d'|' -f3)
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Play the game
play_game