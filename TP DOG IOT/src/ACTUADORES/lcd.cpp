//Grupo 6 - Ducau, Jeiman & Zonis
#include "lcd.h"

LiquidCrystal_I2C lcd(0x27 , 16, 2);

void inicializarLCD() {
    lcd.init();
    lcd.backlight();
}

void setearLCD() {
    lcd.clear();
}

void printearLCD(String mensaje, int linea) {
    lcd.setCursor(0, linea);
    lcd.print(mensaje);
}

void escanearI2C(TwoWire &bus) {
    Serial.println("Escaneando bus I2C...");
    int encontrados = 0;

    for (uint8_t direccion = 1; direccion < 127; direccion++) {
        bus.beginTransmission(direccion);
        uint8_t error = bus.endTransmission();

        if (error == 0) {
            Serial.printf("Dispositivo encontrado en 0x%02X\n", direccion);
            encontrados++;
        } else if (error == 4) {
            Serial.printf("Error desconocido en 0x%02X\n", direccion);
        }
    }

    if (encontrados == 0) {
        Serial.println("No se encontraron dispositivos I2C");
    } else {
        Serial.printf("Escaneo terminado: %d dispositivo(s)\n", encontrados);
    }
}


