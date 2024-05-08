#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
# randomly generated number and counter
RANDOM_NUMBER=$((RANDOM % 1001))
COUNTER=1

echo -e "\nEnter your username:\n"
read USER_NAME

EXISTING_USER_CHECK=$($PSQL "SELECT username FROM players WHERE username = '$USER_NAME'")

if [[ -z $EXISTING_USER_CHECK ]]
then
  GAMES_PLAYED=0
  BEST_GAME=1000
  echo -e "\nWelcome, $USER_NAME! It looks like this is your first time here.\n"
else
  GAMES_PLAYED=$($PSQL "SELECT num_games FROM players WHERE username = '$USER_NAME';")
  BEST_GAME=$($PSQL "SELECT best_game FROM players WHERE username = '$USER_NAME';")
  echo -e "\nWelcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.\n"
fi


####################
####INTIAL GUESS####
####################

echo -e "Guess the secret number between 1 and 1000:"
read GUESS
if ! [[ $GUESS =~ ^-?[0-9]+$ ]];
then
  until [[ $GUESS =~ ^-?[0-9]+$ ]];
  do
    if ! [[ $GUESS =~ ^-?[0-9]+$ ]];
    then
        echo "That is not an integer, guess again:"
        read GUESS
    fi
  done
fi

####################
#####NEXT GUESS#####
####################

if [[ $RANDOM_NUMBER != $GUESS ]]
then
  while [ $RANDOM_NUMBER != $GUESS ]
  do
    if [[ $GUESS -lt $RANDOM_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
      read GUESS
      if ! [[ $GUESS =~ ^-?[0-9]+$ ]];
      then
        until [[ $GUESS =~ ^-?[0-9]+$ ]];
        do
          if ! [[ $GUESS =~ ^-?[0-9]+$ ]];
          then
            echo "That is not an integer, guess again:"
            read GUESS
          fi
        done
      fi
    else
      echo "It's lower than that, guess again:"
      read GUESS
            if ! [[ $GUESS =~ ^-?[0-9]+$ ]];
      then
        until [[ $GUESS =~ ^-?[0-9]+$ ]];
        do
          if ! [[ $GUESS =~ ^-?[0-9]+$ ]];
          then
            echo "That is not an integer, guess again:"
            read GUESS
          fi
        done
      fi
    fi
    let COUNTER++
  done
fi

echo "You guessed it in $COUNTER tries. The secret number was $GUESS. Nice job!"

# get the games played and best games
let GAMES_PLAYED++

if [[ $BEST_GAME == 1000 || $BEST_GAME > $COUNTER ]]
then
  BEST_GAME=$COUNTER
fi

# insert
if [[ -z $EXISTING_USER_CHECK ]]
then
  INSERT_USER=$($PSQL "INSERT INTO players(username, num_games, best_game) VALUES('$USER_NAME', $GAMES_PLAYED, $BEST_GAME);")
else
  UPDATE_USER=$($PSQL "UPDATE players SET num_games = $GAMES_PLAYED, best_game = $BEST_GAME WHERE username = '$USER_NAME';")
fi