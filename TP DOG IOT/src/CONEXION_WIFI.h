//Grupo 6 - Ducau, Jeiman & Zonis
#pragma once
#include <Arduino.h>
#include <WiFi.h>
#include <EEPROM.h>
#include "config.h"

// Las credenciales del WiFi se guardan en la EEPROM.
// Antes de usar estas funciones hay que llamar a EEPROM.begin(EEPROM_SIZE) en el setup.

struct credencialesWifi {
    String ssid;       // Nombre de la red
    String password;   // Contraseña de la red
    bool validas;      // false si en la EEPROM no hay credenciales guardadas
};

// Guarda el nombre y la contraseña de la red en la EEPROM.
// Devuelve false si no se guardaron: nombre vacío, textos demasiado largos o falla de la EEPROM
bool guardarCredencialesWifi(String ssid, String password);

// Lee las credenciales guardadas en la EEPROM. Si no hay ninguna, validas viene en false
credencialesWifi leerCredencialesWifi();

// Borra las credenciales guardadas en la EEPROM
void borrarCredencialesWifi();

// Empieza a conectarse a la red guardada en la EEPROM y vuelve enseguida, sin esperar a que conecte.
// Devuelve false si no hay credenciales guardadas.
// No hay que llamarla en cada vuelta del loop: se la llama una vez y después se consulta wifiConectado().
// Si la conexión se corta, el ESP32 vuelve a intentar solo.
// Si pasan unos segundos y no conectó (por ejemplo con la contraseña mal), se la puede volver a llamar
bool conectarWifi();

// Devuelve true si el WiFi está conectado
bool wifiConectado();
