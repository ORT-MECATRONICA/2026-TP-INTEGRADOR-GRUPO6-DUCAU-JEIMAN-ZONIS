//Grupo 6 - Ducau, Jeiman & Zonis
#include "lcd.h"

LiquidCrystal_I2C lcd(0x27 , 16, 2);

void inicializarLCD() {
    lcd.init();
    lcd.backlight();
}

void setearLCD() {
    lcd.clear();
    // Puedes agregar más configuraciones iniciales aquí
}

void printearLCD(String mensaje, int linea) {
    lcd.setCursor(0, linea);
    lcd.print(mensaje);
}

void escanearI2C() {
    byte error, address;
    int nDevices = 0;

    Serial.println("Escaneando bus I2C...");

    Wire.begin();
    for (address = 1; address < 127; address++) {
        Wire.beginTransmission(address);
        error = Wire.endTransmission();

        if (error == 0) {
            Serial.print("Dispositivo I2C encontrado en la direccion 0x");
            if (address < 16) {
                Serial.print("0");
            }
            Serial.println(address, HEX);
            nDevices++;
        } else if (error == 4) {
            Serial.print("Error desconocido en la direccion 0x");
            if (address < 16) {
                Serial.print("0");
            }
            Serial.println(address, HEX);
        }
    }

    if (nDevices == 0) {
        Serial.println("No se encontraron dispositivos I2C\n");
    } else {
        Serial.println("Escaneo I2C finalizado\n");
    }
}
