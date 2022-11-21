#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t -c"

RANDUM_NUMBER=$(( $RANDOM % 1000 +1 ))

GAME() {
  echo -e "\nEnter your username:"
  read USERNAME

  # Username input is not empty
  if [[ ! -z $USERNAME ]]
  then 
    USER=$($PSQL "SELECT * FROM users WHERE username='$USERNAME'")

    # generate/find user
    if [[ $USER ]]
    # Existing user
    then
      read USER_ID BAR USERNAME BAR GAMES_PLAYED BAR BEST_GAME <<< $USER
      echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
      MATCH_GUESS
      UPDATE_USER=$($PSQL "UPDATE users SET games_played=$(( $GAMES_PLAYED+1 )) WHERE user_id=$USER_ID")
      
      # new game record
      if [[ $COUNT -lt $BEST_GAME ]]
      then 
        UPDATE_BEST=$($PSQL "UPDATE users SET best_game=$COUNT WHERE user_id=$USER_ID;")
      fi

    # New User 
    else
      echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
      MATCH_GUESS
      CREATE_USER=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 1, $COUNT)")
    fi 

  # if empty string provided to username
  else
    GAME
  fi
}


COUNT=0
MATCH_GUESS() {
  COUNT=$((COUNT+1))
  # guess hint 
  case $1 in
    higher)
      echo -e "\nIt's higher than that, guess again:"
      ;;
    lower)
      echo -e "\nIt's lower than that, guess again:"
      ;;
    wrong)
      echo -e "\nThat is not an integer, guess again:"
      ;;
    *)
      echo -e "\nGuess the secret number between 1 and 1000:"
      ;;
  esac
  read GUESS

  #Test guess
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    MATCH_GUESS "wrong"
  # corect guess terminates loop
  elif [[ $GUESS -eq $RANDUM_NUMBER ]]
  then
    echo -e "\nYou guessed it in $COUNT tries. The secret number was $RANDUM_NUMBER. Nice job!"
  elif [[ $RANDUM_NUMBER -gt $GUESS ]]
  then
    MATCH_GUESS "higher"
  elif [[ $RANDUM_NUMBER -lt $GUESS ]]
  then
    MATCH_GUESS "lower"
  else
    MATCH_GUESS "wrong"
  fi
}

GAME