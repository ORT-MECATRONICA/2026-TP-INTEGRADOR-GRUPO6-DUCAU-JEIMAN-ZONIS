//Grupo 6 - Ducau, Jeiman & Zonis
#pragma once
#include <Arduino.h>
#include <NimBLEDevice.h>
#include "config.h"

// Se usa la librería NimBLE y no la BLE que trae Arduino: la de Arduino deja reservada la memoria
// del Bluetooth clásico y no queda RAM para la conexión segura (SSL) de MQTT

// El Bluetooth (BLE) queda prendido todo el tiempo: la aplicación se conecta cuando quiere
// y, si se desconecta, el ESP32 vuelve a aparecer en el celular solo.
// Los mensajes son tramas de texto:   <COMANDO;campo1;campo2>
//   <WIFI;nombre;contraseña>      Cambia la red WiFi. La contraseña puede tener ';' pero el nombre no
//   <UMBRALES;gas;temperatura>    Cambia los umbrales de la alarma.   Ejemplo: <UMBRALES;50;40.5>
//   <LEER>                        Pide la configuración guardada

struct datosBluetooth {
    String comando;    // WIFI, UMBRALES o LEER
    String campo1;     // Primer valor después del comando (puede venir vacío)
    String campo2;     // Segundo valor después del comando (puede venir vacío)
    bool validos;      // false si lo que llegó no respeta la trama
};

// Prende el Bluetooth. El ESP32 aparece en el celular con el nombre NOMBRE_BLUETOOTH
void inicializarBluetooth();

// Devuelve true si la aplicación está conectada
bool bluetoothConectado();

// Devuelve true si llegó una trama completa que todavía no se leyó
bool hayMensajeBluetooth();

// Devuelve la última trama que llegó, separada en campos.
// Hay que llamarla solamente cuando hayMensajeBluetooth() avisa que llegó algo
datosBluetooth leerDatosBluetooth();

// Le envía a la aplicación el texto entre '<' y '>'. Ejemplo: enviarBluetooth("OK;WIFI") envía <OK;WIFI>.
// Si la aplicación no está conectada no hace nada
void enviarBluetooth(String texto);
