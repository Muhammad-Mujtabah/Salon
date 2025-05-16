#!/bin/bash

# Command to execute PostgreSQL queries
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# Print welcome message
echo -e "\n~~~~~ MY SALON ~~~~~\n"

# Function to display the services
SERVICES_SALON() {
    # Retrieve list of services
    MY_SERVICES=$($PSQL "select service_id, name from services order by service_id")

    # If not services
    if [[ -z $MY_SERVICES ]]; then
        MAIN_MENU "Sorry, we don't have any service available right now."
    else
        # Display the services menu
        echo 'Welcome to My Salon, how can I help you?'
        echo "$MY_SERVICES" | while read SERVICE_ID BAR NAME; do
            echo "$SERVICE_ID) $NAME"
        done

        read SERVICE_ID_SELECTED

        SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")

        if [[ -z $SERVICE_NAME ]]; then
            SERVICE_MENU
        else
            # read phone number
            echo -e "\nYour phone number?"
            read CUSTOMER_PHONE

            CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE';")

            # If not customer
            if [[ -z $CUSTOMER_NAME ]]; then
                echo -e "\nYour name?"
                read CUSTOMER_NAME

                # service time
                echo -e "\nHow many times do you want this service?"
                read SERVICE_TIME

                # Insert new customer
                ADD_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone,name) values('$CUSTOMER_PHONE','$CUSTOMER_NAME')")

                CUSTOMER_ID=$($PSQL "SELECT customer_id from customers where name='$CUSTOMER_NAME'")

                ADD_NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) values('$SERVICE_TIME','$CUSTOMER_ID','$SERVICE_ID_SELECTED')")
            else
                # If the customer exists
                echo -e "\nHow many times do you want this service?"
                read SERVICE_TIME
            fi

            echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
        fi
    fi
}

# start
SERVICES_SALON