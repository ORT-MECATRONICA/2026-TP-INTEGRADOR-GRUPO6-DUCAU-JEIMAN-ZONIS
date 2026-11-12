#pragma once
//LOS PINES SON TODOS INCORRECTOS Y SOLO SE USAN PARA DEBUG.
#define PIN_SENSOR_GAS 36
#define BOTON_1 26
#define BOTON_2 25
#define BOTON_3 32
#define BOTON_4 33
#define BOTON_5 15
#define BOTON_6 2

#define LED_1 14
#define LED_2 12

#define SDA_3V3 21
#define SCL_3V3 22

#define SDA_5V 18
#define SCL_5V 19

#define SENSOR_LUZ 34
#define RADAR_RX_PIN 16
#define RADAR_TX_PIN 17
#define TIMEOUT_RADAR_MS 1000   // Sin datos del radar por este tiempo = desconectado
#define MAX_LECTURAS_RADAR 32   // Tramas máximas a procesar por llamada a actualizarSensorPresencia()

#define UMBRAL_LUZ 500

// WIFI: las credenciales se guardan en la EEPROM en estas direcciones
#define EEPROM_SIZE 128             // Bytes de EEPROM que se reservan (las credenciales ocupan 98)
#define MARCA_CREDENCIALES 0xA5     // Valor guardado en DIRECCION_MARCA cuando hay credenciales
#define DIRECCION_MARCA 0           // Ocupa 1 byte
#define DIRECCION_SSID 1            // Ocupa 33 bytes: 32 caracteres + el fin del texto
#define DIRECCION_PASSWORD 34       // Ocupa 64 bytes: 63 caracteres + el fin del texto
#define LARGO_MAXIMO_SSID 32
#define LARGO_MAXIMO_PASSWORD 63

// MQTT (EMQX Cloud con SSL/TLS)
#define NUMERO_DISPOSITIVO 136      // Número de grupo: 5A 11x, 5B 12x, 5C 13x
#define MQTT_HOST "sa11b75f.ala.us-east-1.emqxsl.com"
#define MQTT_PORT 8883
#define MQTT_USERNAME "esp32"
#define MQTT_PASSWORD "mirko15"
#define MQTT_PUB "/esp32/datos_sensores"   // Topic donde se publican los sensados
#define TIMEOUT_MQTT_SEG 5          // Espera máxima al servidor en cada paso de la conexión (subirlo si la red es lenta)
#define TAMANIO_COLA_MQTT 1000      // Sensados que se guardan mientras no se pueden enviar

// HORA: se obtiene de internet (servidor NTP)
#define SERVIDOR_NTP "south-america.pool.ntp.org"
#define GMT_OFFSET_SEG -10800       // Argentina: 3 horas menos que la hora mundial (UTC)
#define HORA_MINIMA_VALIDA 1700000000   // Una hora menor a esta significa que todavía no llegó la de internet