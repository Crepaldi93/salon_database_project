#! /bin/bash

# Create variable to query the database
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

# Print title
echo -e "\n~~~~~ MY SALON ~~~~~"

# Create the main menu function

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  else
    echo -e "\nWelcome to My Salon, how can I help you?\n"
  fi

  # Get list of services
  SERVICE_LIST=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  # Display formatted service list
  echo "$SERVICE_LIST" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done 
}

NEW_APPOINTMENT() {
  # Display main menu
  MAIN_MENU

  # Lopp through main menu until valid input is given
  SERVICE_ID_IS_VALID=1
  until [[ SERVICE_ID_IS_VALID == 0 ]]
  do
    # Get input for service id
    read SERVICE_ID_SELECTED

    # Check if input is valid
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]] || [[ -z $($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED") ]]
    then
      # Send to main menu
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      SERVICE_ID_IS_VALID=0
      break
    fi
  done
 
  # Get input for phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # Get customer name
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # If customer is not registered
  if [[ -z $CUSTOMER_NAME ]]
  then
    # Get input for customer name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    # Register new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi

  # Get remaining customer and service info
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  
  # Format variables
  CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/^ *//g')
  SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME_SELECTED | sed 's/^ *//g')

  # Get information for the time of the appointment
  echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
  read SERVICE_TIME

  
  # Insert appointment into the appointments table
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
}

NEW_APPOINTMENT



