//Grupo 6 - Ducau, Jeiman & Zonis
#pragma once
#include <Arduino.h>
#include <BluetoothSerial.h>
#include "config.h"

// Por Bluetooth se recibe la red WiFi a la que se tiene que conectar el ESP32.
// Tiene que llegar con esta trama:   <nombre;contraseña>     Ejemplo: <MiCasa;clave1234>

// Objeto Bluetooth. En main.cpp se usa solamente para consultar SerialBT.available()
extern BluetoothSerial SerialBT;

struct datosBluetooth {
    String ssid;       // Nombre de la red que llegó en la trama
    String password;   // Contraseña que llegó en la trama
    bool validos;      // false si lo que llegó no respeta la trama
};

// Prende el Bluetooth. El ESP32 aparece en el celular con el nombre NOMBRE_BLUETOOTH
void inicializarBluetooth();

// Lee lo que llegó por Bluetooth y lo separa según la trama.
// Hay que llamarla solamente cuando SerialBT.available() avisa que llegó algo.
// Espera TIMEOUT_BLUETOOTH_MS a que termine de llegar el mensaje
datosBluetooth leerDatosBluetooth();

// Apaga el Bluetooth, para dejarle la memoria al WiFi
void finalizarBluetooth();
