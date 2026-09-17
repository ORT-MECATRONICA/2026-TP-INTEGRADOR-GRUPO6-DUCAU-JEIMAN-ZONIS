//Grupo 6 - Ducau, Jeiman & Zonis
#include "interfaz.h"

void inicializarInterfaz() {
    // Configuración de pines para botones y LEDs
    pinMode(BOTON_1, INPUT_PULLUP);
    pinMode(BOTON_2, INPUT_PULLUP);
    pinMode(BOTON_3, INPUT_PULLUP);
    pinMode(BOTON_4, INPUT_PULLUP);
    pinMode(BOTON_5, INPUT_PULLUP);
    pinMode(BOTON_6, INPUT_PULLUP);
    
    pinMode(LED_1, OUTPUT);
    pinMode(LED_2, OUTPUT);
}

estadoBotones leerBotones() {

    estadoBotones estados;
    estados.boton1 = digitalRead(BOTON_1) == LOW; // Botón presionado
    estados.boton2 = digitalRead(BOTON_2) == LOW;
    estados.boton3 = digitalRead(BOTON_3) == LOW;
    estados.boton4 = digitalRead(BOTON_4) == LOW;
    estados.boton5 = digitalRead(BOTON_5) == LOW;
    estados.boton6 = digitalRead(BOTON_6) == LOW;

    return estados;
}

void modificarEstadoLed(bool estado, int pinLed) {
    digitalWrite(pinLed, estado ? HIGH : LOW);
}