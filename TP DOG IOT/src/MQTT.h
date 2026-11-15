//Grupo 6 - Ducau, Jeiman & Zonis
#pragma once
#include <Arduino.h>
#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <PubSubClient.h>
#include <time.h>
#include "config.h"

// Datos de un sensado. Se envían al servidor en este mismo orden
struct datosMqtt {
    long hora;           // Hora del sensado. La completa guardarDatosMqtt(): no hace falta cargarla
    float temperatura;   // En grados
    float presion;       // Entre 0 y 99. En este parámetro se envía la humedad
    float luz;           // Entre 0 y 99: cuanta más luz, más alto
    float gas;           // Entre 0 y 99
    float corriente;     // Entre 0 y 99
    bool presencia;      // true si hay presencia
    bool opto;           // Lectura del optoacoplador
    bool alarma;         // true si se superó algún umbral
};

// Configura la conexión con el servidor MQTT. Se llama una sola vez en el setup
void inicializarMqtt();

// Hace UN solo intento de conexión con el servidor MQTT. Devuelve true si quedó conectado.
// Si no hay WiFi devuelve false enseguida.
// Es la única función que tarda: como la conexión es cifrada, el intento puede durar algunos segundos.
// No hay que llamarla en cada vuelta del loop: hay que dejar pasar unos segundos entre un intento y otro
bool conectarMqtt();

// Devuelve true si está conectado al servidor MQTT
bool mqttConectado();

// Hay que llamarla en cada vuelta del loop: mantiene viva la conexión con el servidor.
// Si no está conectado no hace nada
void actualizarMqtt();

// Guarda un sensado en la cola para enviarlo cuando se pueda, y le pone la hora actual.
// Devuelve false si todavía no llegó la hora de internet: se pide en el primer conectarMqtt()
// y llega unos segundos después.
// Si la cola está llena se pierde el sensado más viejo
bool guardarDatosMqtt(datosMqtt datos);

// Envía el sensado más viejo de la cola. Devuelve true si se envió.
// Si no hay nada para enviar o el envío falla devuelve false, y el sensado sigue guardado en la cola
bool enviarDatosMqtt();

// Cantidad de sensados guardados en la cola que todavía no se enviaron
int mqttDatosPendientes();
