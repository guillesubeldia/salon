#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

# Función para mostrar los servicios
mostrar_servicios() {
  echo -e "\n~~~~~ Programador de Citas del Salón ~~~~~\n"
  echo "Bienvenido al Salón, ¿cómo puedo ayudarte?"
  SERVICIOS=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICIOS" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Función para solicitar la selección del servicio
solicitar_seleccion_servicio() {
  echo -e "\nPor favor, selecciona un servicio ingresando el ID del servicio:"
  read SERVICE_ID_SELECTED
}

# Función para verificar si el servicio seleccionado es válido
verificar_validez_servicio() {
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME ]]
  then
    echo -e "\nSelección de servicio inválida."
    return 1
  else
    return 0
  fi
}

# Función para solicitar la información del cliente
solicitar_info_cliente() {
  echo -e "\nIngresa tu número de teléfono:"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nIngresa tu nombre:"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi
  
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
}

# Función para solicitar la hora de la cita
solicitar_hora_cita() {
  echo -e "\nIngresa la hora de la cita:"
  read SERVICE_TIME
}

# Función para insertar la cita
insertar_cita() {
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  echo -e "\nTe he reservado una cita para un $SERVICE_NAME a las $SERVICE_TIME, $CUSTOMER_NAME."
}

# Función principal para ejecutar la lógica del script
main() {
  mostrar_servicios
  solicitar_seleccion_servicio

  while ! verificar_validez_servicio
  do
    mostrar_servicios
    solicitar_seleccion_servicio
  done

  solicitar_info_cliente
  solicitar_hora_cita
  insertar_cita
}

# Ejecutar la función principal
main
