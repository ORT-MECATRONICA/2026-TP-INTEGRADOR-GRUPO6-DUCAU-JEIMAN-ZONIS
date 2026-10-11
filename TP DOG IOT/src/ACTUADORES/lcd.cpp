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


