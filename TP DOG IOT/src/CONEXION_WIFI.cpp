//Grupo 6 - Ducau, Jeiman & Zonis
#include "CONEXION_WIFI.h"

bool guardarCredencialesWifi(String ssid, String password) {
    // Si los textos no entran en el lugar reservado de la EEPROM no se guarda nada
    if (ssid.length() == 0 || ssid.length() > LARGO_MAXIMO_SSID || password.length() > LARGO_MAXIMO_PASSWORD) {
        return false;
    }

    EEPROM.write(DIRECCION_MARCA, MARCA_CREDENCIALES);
    EEPROM.writeString(DIRECCION_SSID, ssid);
    EEPROM.writeString(DIRECCION_PASSWORD, password);

    // Sin commit() los datos no quedan guardados al apagar
    return EEPROM.commit();
}

credencialesWifi leerCredencialesWifi() {
    credencialesWifi credenciales;
    credenciales.validas = false;

    // La marca indica que alguna vez se guardaron credenciales
    if (EEPROM.read(DIRECCION_MARCA) == MARCA_CREDENCIALES) {
        credenciales.ssid = EEPROM.readString(DIRECCION_SSID);
        credenciales.password = EEPROM.readString(DIRECCION_PASSWORD);
        credenciales.validas = true;
    }

    return credenciales;
}

void borrarCredencialesWifi() {
    // Alcanza con borrar la marca: sin ella leerCredencialesWifi() no las toma como válidas
    EEPROM.write(DIRECCION_MARCA, 0);
    EEPROM.commit();
}

bool conectarWifi() {
    credencialesWifi credenciales = leerCredencialesWifi();

    if (!credenciales.validas) {
        return false;
    }

    // begin() solamente inicia la conexión: no espera a que termine
    WiFi.begin(credenciales.ssid, credenciales.password);
    return true;
}

bool wifiConectado() {
    return WiFi.status() == WL_CONNECTED;
}
