#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
else
  # Determine if the argument is an atomic number (integer) or a symbol/name (string)
  if [[ $1 =~ ^[0-9]+$ ]]; then
    # The input is an atomic number (integer)
    ELEMENT_INFO=$($PSQL "SELECT elements.atomic_number, name, symbol, atomic_mass, type, melting_point_celsius, boiling_point_celsius 
                          FROM elements 
                          INNER JOIN properties ON elements.atomic_number=properties.atomic_number 
                          INNER JOIN types ON properties.type_id=types.type_id
                          WHERE elements.atomic_number=$1;")
  else
    # The input is a symbol or name (string)
    ELEMENT_INFO=$($PSQL "SELECT elements.atomic_number, name, symbol, atomic_mass, type, melting_point_celsius, boiling_point_celsius 
                          FROM elements 
                          INNER JOIN properties ON elements.atomic_number=properties.atomic_number 
                          INNER JOIN types ON properties.type_id=types.type_id
                          WHERE elements.symbol='$1' OR elements.name='$1';")
  fi

  if [[ -z $ELEMENT_INFO ]]; then
    echo "I could not find that element in the database."
  else
    echo "$ELEMENT_INFO" | while IFS="|" read ATOMIC_NUMBER NAME SYMBOL MASS TYPE MELTING_POINT BOILING_POINT; do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    done
  fi
fi
