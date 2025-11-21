#!/bin/bash

PSQL="psql -U freecodecamp -d salon -t --no-align -c"

while true
do 
  # Show menu
  SERVICES=$($PSQL "SELECT service_id || ') ' || name FROM services ORDER BY service_id;")
  echo -e "\nAvailable services:\n$SERVICES"

  # Ask user
  echo -e "\nEnter the service ID:"
  read SERVICE_ID_SELECTED

  # Validate
  VALID_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  if [[ -z $VALID_ID ]]
  then
    echo -e "\nInvalid ID, please try again"
  else
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    echo -e "\nYou selected: $SERVICE_ID_SELECTED) $SERVICE_NAME"
    break
  fi
done

# Enter a phone number
echo -e "\nPlease, enter your phone number"
read CUSTOMER_PHONE

IS_CUSTOMER=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE'")

# Check if already customer
if [[ -z $IS_CUSTOMER ]]
then 
  echo -e "\nEnter your name: "
  read CUSTOMER_NAME

  # Insert the data
  $PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')"
else
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
fi

# Enter a time
echo -e "\nEnter service time"
read SERVICE_TIME

RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES((SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'), $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

if [[ $RESULT == "INSERT 0 1" ]]
then
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
fi
