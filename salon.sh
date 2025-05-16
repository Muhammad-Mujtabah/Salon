#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo 'Welcome to My Salon, how can I help you?'

MY_SERVICES=$($PSQL "select service_id, name from services order by service_id")
echo "$MY_SERVICES" | while read SERVICE_ID BAR NAME; do
    echo "$SERVICE_ID) $NAME"
done

read SERVICE_ID_SELECTED

SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")

while [[ -z $SERVICE_NAME ]]; do
    echo -e "\nI could not find that service. What would you like today?"
    echo "$MY_SERVICES" | while read SERVICE_ID BAR NAME; do
        echo "$SERVICE_ID) $NAME"
    done
    read SERVICE_ID_SELECTED
    SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
done

echo -e "\nYour phone number?"
read CUSTOMER_PHONE

CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE';")

if [[ -z $CUSTOMER_NAME ]]; then
    echo -e "\nYour name?"
    read CUSTOMER_NAME

    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME

    ADD_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone,name) values('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id from customers where name='$CUSTOMER_NAME'")
    ADD_NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) values('$SERVICE_TIME','$CUSTOMER_ID','$SERVICE_ID_SELECTED')")
else
    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME
    CUSTOMER_ID=$($PSQL "SELECT customer_id from customers where phone='$CUSTOMER_PHONE'")
    ADD_NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) values('$SERVICE_TIME','$CUSTOMER_ID','$SERVICE_ID_SELECTED')")
fi

echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
