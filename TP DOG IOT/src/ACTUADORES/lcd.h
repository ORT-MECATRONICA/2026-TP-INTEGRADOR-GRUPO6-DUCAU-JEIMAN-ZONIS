//Grupo 6 - Ducau, Jeiman & Zonis
#pragma once

#include <Arduino.h>
#include <LiquidCrystal_I2C.h>
#include <Wire.h>

// Objeto LCD (por defecto: dirección 0x27, 16 columnas, 2 filas)
extern LiquidCrystal_I2C lcd;

void inicializarLCD();
void setearLCD();
void printearLCD(String mensaje, int linea);
// Escanea el bus I2C indicado e imprime por Serial las direcciones que responden
void escanearI2C(TwoWire &bus);
