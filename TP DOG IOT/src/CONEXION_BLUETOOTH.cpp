//Grupo 6 - Ducau, Jeiman & Zonis
#include "CONEXION_BLUETOOTH.h"

BluetoothSerial SerialBT;

void inicializarBluetooth() {
    if (!SerialBT.begin(NOMBRE_BLUETOOTH)) {
        Serial.println("Error al inicializar el Bluetooth");
    }

    // Tiempo que se espera a que termine de llegar un mensaje
    SerialBT.setTimeout(TIMEOUT_BLUETOOTH_MS);
}

datosBluetooth leerDatosBluetooth() {
    datosBluetooth datos;
    datos.validos = false;

    // Lee todo lo que llegó
    String trama = SerialBT.readString();

    // Busca los tres caracteres que arman la trama: <nombre;contraseña>
    int inicio = trama.indexOf(INICIO_TRAMA);
    int separador = trama.indexOf(SEPARADOR_TRAMA);
    int fin = trama.lastIndexOf(FIN_TRAMA);

    // La trama está bien si los tres caracteres están y en ese orden
    if (inicio != -1 && separador > inicio && fin > separador) {
        datos.ssid = trama.substring(inicio + 1, separador);
        datos.password = trama.substring(separador + 1, fin);

        // El nombre y la contraseña tienen que entrar en el lugar reservado de la EEPROM
        if (datos.ssid.length() > 0 && datos.ssid.length() <= LARGO_MAXIMO_SSID && datos.password.length() <= LARGO_MAXIMO_PASSWORD) {
            datos.validos = true;
        }
    }

    return datos;
}

void finalizarBluetooth() {
    SerialBT.end();
}
