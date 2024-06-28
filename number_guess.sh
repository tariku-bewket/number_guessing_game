#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# prompts name 
echo -e "\nEnter your username:\n"
read USERNAME

PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username = '$USERNAME'")

if [[ -z $PLAYER_ID ]]
then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here.\n"
  PLAYER_RESULT=$($PSQL "INSERT INTO players (username) VALUES ('$USERNAME')")
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM players WHERE username = '$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM players WHERE username = '$USERNAME'")

  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.\n"

  echo -e "\nGuess the secret number between 1 and 1000:\n"
  read GUESS

fi