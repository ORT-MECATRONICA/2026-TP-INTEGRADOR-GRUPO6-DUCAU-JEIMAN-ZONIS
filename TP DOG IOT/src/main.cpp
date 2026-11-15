//Grupo 6 - Ducau, Jeiman & Zonis
#include "main.h"
#include <Arduino.h>
#include <Wire.h>


#include "MQTT.h"
#include "CONEXION_WIFI.h"
#include "CONEXION_BLUETOOTH.h"
#include "SENSORES/humedad.h"
#include "SENSORES/gas.h"
#include "SENSORES/corriente.h"
#include "SENSORES/luz.h"
#include "SENSORES/presencia_humana.h"
#include "ACTUADORES/interfaz.h"
#include "ACTUADORES/lcd.h"
#include "config.h"


datosHumedad datosHumedadActual;        // Temperatura y humedad del AHT
int porcentajeGasActual;                // Gas de 0 a 100
datosPresenciaHumana datosPresenciaActual;
energia datosCorrienteActual;
int porcentajeLuzActual;
bool estadoLDR;
estadoBotones datosBotonActual;
datosBluetooth datosBluetoothActual;    // Lo último que llegó por Bluetooth
datosMqtt datosMqttActual;              // Último sensado armado para enviar al servidor

bool botonCentralApretado = false;      // true solamente en la vuelta del loop en la que se aprieta el botón central
bool botonCentralAnterior = false;      // Cómo estaba el botón central en la vuelta anterior
unsigned long tiempoBotonCentral = 0;   // Momento en que el botón central cambió por última vez

String linea0Anterior = "";             // Último texto que se escribió en cada línea del LCD
String linea1Anterior = "";

unsigned long tiempoAnterior = 0;       // Momento en que empezó a mostrarse un mensaje
unsigned long tiempoConexion = 0;       // Momento del último intento de conexión con el servidor
unsigned long tiempoSensado = 0;        // Momento de la última lectura de los sensores
unsigned long tiempoGuardado = 0;       // Momento en que se guardó el último sensado en la cola
unsigned long tiempoEnvio = 0;          // Momento del último envío al servidor

// Escribe las dos líneas del LCD solamente cuando cambia el texto, porque escribir en el LCD es lento
void mostrarEnLCD(String linea0, String linea1) {
  if (linea0 != linea0Anterior || linea1 != linea1Anterior) {
    setearLCD();
    printearLCD(linea0, 0);
    printearLCD(linea1, 1);
    linea0Anterior = linea0;
    linea1Anterior = linea1;
  }
}

// Hay que llamarla en cada vuelta del loop: lee los botones y detecta cuándo se aprieta el botón central
void actualizarBotones() {
  datosBotonActual = leerBotones();
  botonCentralApretado = false;

  if (datosBotonActual.BOTON_CENTRAL != botonCentralAnterior) {
    // Para que los rebotes no cuenten, el botón tiene que haber estado quieto un tiempo antes de apretarse
    if (datosBotonActual.BOTON_CENTRAL && millis() - tiempoBotonCentral >= TIEMPO_ANTIRREBOTE_MS) {
      botonCentralApretado = true;
    }
    botonCentralAnterior = datosBotonActual.BOTON_CENTRAL;
    tiempoBotonCentral = millis();
  }
}

// Lee todos los sensores y deja las lecturas en las variables de arriba
void leerSensores() {
  datosHumedadActual = actualizarHumedad();
  porcentajeGasActual = porcentajeGas();
  // Sirve para calibrar el potenciómetro (GAS_LECTURA_MINIMA y GAS_LECTURA_MAXIMA en config.h)
  Serial.println("Gas: lectura " + String(lecturaAnalogicaGas()) + " -> " + String(porcentajeGasActual) + " %");
  datosPresenciaActual = leerPresenciaHumana();
  datosCorrienteActual = actualizarDatosEnergia();
  Serial.println("Corriente: lectura " + String(datosCorrienteActual.corriente, 2) + " | " + String(datosCorrienteActual.voltaje, 2) + " V");
  porcentajeLuzActual = porcentajeLuz();
  estadoLDR = LDRDigital();
}

// Pasa una lectura que va de minimo a maximo a un valor entre 0 y 99
float pasarARango(float lectura, float minimo, float maximo) {
  float valor = (lectura - minimo) * 99 / (maximo - minimo);

  // Si el sensor no respondió la lectura no es un número: queda en 0
  if (isnan(valor) || valor < 0) {
    valor = 0;
  }
  if (valor > 99) {
    valor = 99;
  }

  return valor;
}

// Arma el sensado que se envía al servidor con las últimas lecturas de los sensores
datosMqtt armarDatosMqtt() {
  datosMqtt datos;

  datos.hora = 0;  // La hora la completa guardarDatosMqtt()

  // La temperatura y la humedad salen del AHT. Si no respondió, las dos quedan en 0
  datos.temperatura = datosHumedadActual.temperatura;

  // En el parámetro de presión se envía la humedad (el servidor espera las mismas claves)
  datos.presion = pasarARango(datosHumedadActual.humedad, 0, 100);
  datos.luz = pasarARango(porcentajeLuzActual, 0, 100);
  datos.gas = pasarARango(porcentajeGasActual, 0, 100);
  // Mapeo fijo de la corriente: se toma sin signo y en amperes. De 0 a 3.2 A se envía como 0 a 99
  datos.corriente = pasarARango(fabs(datosCorrienteActual.corriente), 0, 3.2);
  datos.presencia = datosPresenciaActual.presencia;
  datos.opto = false;  // El módulo del optoacoplador todavía no tiene funciones
  datos.alarma = datos.gas > UMBRAL_GAS || datos.temperatura > UMBRAL_TEMPERATURA;

  return datos;
}

// Devuelve "OK" o "NO" para mostrar en el LCD si algo está conectado
String textoConexion(bool conectado) {
  if (conectado) {
    return "OK";
  } else {
    return "NO";
  }
}

// Muestra en el LCD el estado de las conexiones y las últimas lecturas
void mostrarDatosEnLCD() {
  String linea0 = "WIFI:" + textoConexion(wifiConectado()) + " MQTT:" + textoConexion(mqttConectado());
  // Ejemplo: "24.2C 52% G:100". Con los valores más largos ocupa justo las 16 columnas
  String linea1 = String(datosMqttActual.temperatura, 1) + "C " + String(datosHumedadActual.humedad, 0) + "% G:" + String(porcentajeGasActual);
  mostrarEnLCD(linea0, linea1);
}

// Apaga el Bluetooth, empieza a conectarse al WiFi y pasa al estado DATOS_MQTT
void empezarEnvioDeDatos() {
  finalizarBluetooth();
  conectarWifi();
  estadoActual = DATOS_MQTT;
}

void setup() {
  Serial.begin(115200);

  Wire.begin(SDA_5V, SCL_5V);
  Wire1.begin(SDA_3V3, SCL_3V3, 100000);
  EEPROM.begin(EEPROM_SIZE);

  inicializarMqtt();
  inicializarBluetooth();
  inicializarSensorGas();
  inicializarSensorPresenciaHumana();
  inicializarSensorHumedad();
  inicializarSensorCorriente();
  inicializarLDR();
  inicializarInterfaz();
  inicializarLCD();

  tiempoAnterior = millis();
}

void loop() {
  actualizarSensorPresencia();
  actualizarBotones();

  // DIAGNOSTICO TEMPORAL DEL LDR
  static unsigned long tiempoDiagnostico = 0;
  if (millis() - tiempoDiagnostico >= 1000) {
    tiempoDiagnostico = millis();
    Serial.println("DIAG LDR: pin34=" + String(analogRead(34)) + " pin4=" + String(analogRead(4)) + " wifi=" + String(wifiConectado()) + " pin35=" + String(analogRead(35)) + " pin39=" + String(analogRead(39)) + " pin36=" + String(analogRead(36)) + " mV34=" + String(analogReadMilliVolts(34)));
  }

  switch (estadoActual) {
    case INICIO:
      if (millis() - tiempoAnterior < TIEMPO_MENSAJE_MS) {
        mostrarEnLCD("BIENVENIDO A ", "   IoT DOG");
      } else {
        mostrarEnLCD("PRESIONE BOTON 1", "PARA CONTINUAR");
        if (datosBotonActual.boton1) {
          estadoActual = RECIBIENDO_DATOS_BLUETOOTH;
        }
      }
      break;

    case RECIBIENDO_DATOS_BLUETOOTH:
      mostrarEnLCD("BT: <RED;CLAVE>", "CENTRAL: SALIR");
      if (SerialBT.available()) {
        // Llegó algo por Bluetooth
        datosBluetoothActual = leerDatosBluetooth();
        estadoActual = INFORMACION_RECIBIDA;
      } else if (botonCentralApretado) {
        // Se sale sin cambiar nada: se usa la red que ya está guardada
        empezarEnvioDeDatos();
      }
      break;

    case INFORMACION_RECIBIDA:
      if (datosBluetoothActual.validos) {
        mostrarEnLCD("RED: " + datosBluetoothActual.ssid, "CENTRAL: GUARDAR");
        if (botonCentralApretado) {
          tiempoAnterior = millis();
          estadoActual = GUARDANDO_DATOS;
        }
      } else {
        mostrarEnLCD("TRAMA INVALIDA", "CENTRAL: VOLVER");
        if (botonCentralApretado) {
          estadoActual = RECIBIENDO_DATOS_BLUETOOTH;
        }
      }
      break;

    case GUARDANDO_DATOS:
      mostrarEnLCD("GUARDANDO DATOS", "EN LA MEMORIA");
      if (millis() - tiempoAnterior >= TIEMPO_MENSAJE_MS) {
        if (!guardarCredencialesWifi(datosBluetoothActual.ssid, datosBluetoothActual.password)) {
          Serial.println("Error al guardar la red en la EEPROM");
        }
        empezarEnvioDeDatos();
      }
      break;

    case DATOS_MQTT:
      if(botonCentralApretado) {
        // Se vuelve a la pantalla de Bluetooth para cambiar la red
        estadoActual = RECIBIENDO_DATOS_BLUETOOTH;
      }
      actualizarMqtt();

      // Si hay WiFi pero no hay conexión con el servidor, se intenta conectar cada INTERVALO_CONEXION_MS
      if (wifiConectado() && !mqttConectado() && millis() - tiempoConexion >= INTERVALO_CONEXION_MS) {
        conectarMqtt();
        tiempoConexion = millis();  // Se toma al terminar, porque el intento puede tardar varios segundos
      }

      // Cada INTERVALO_SENSADO_MS se leen los sensores y se actualizan los LEDs
      if (millis() - tiempoSensado >= INTERVALO_SENSADO_MS) {
        tiempoSensado = millis();
        leerSensores();
        datosMqttActual = armarDatosMqtt();
        modificarEstadoLed(datosMqttActual.alarma, LED_1);   // El LED 1 se prende cuando hay alarma
        modificarEstadoLed(!datosMqttActual.alarma, LED_2);  // El LED 2 se prende cuando no hay alarma
      }

      // Cada INTERVALO_GUARDADO_MS se guarda el último sensado en la cola para enviarlo
      if (millis() - tiempoGuardado >= INTERVALO_GUARDADO_MS) {
        // Si todavía no llegó la hora de internet no se puede guardar: se vuelve a intentar en la próxima vuelta
        if (guardarDatosMqtt(datosMqttActual)) {
          tiempoGuardado = millis();
        }
      }

      // Si hay sensados en la cola se envía uno cada INTERVALO_ENVIO_MS
      if (mqttConectado() && mqttDatosPendientes() > 0 && millis() - tiempoEnvio >= INTERVALO_ENVIO_MS) {
        tiempoEnvio = millis();
        enviarDatosMqtt();
      }

      mostrarDatosEnLCD();
      break;
  }
}
