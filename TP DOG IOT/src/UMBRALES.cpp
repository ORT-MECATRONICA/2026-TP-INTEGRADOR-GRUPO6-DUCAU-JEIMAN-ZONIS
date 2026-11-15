//Grupo 6 - Ducau, Jeiman & Zonis
#include "UMBRALES.h"

bool guardarUmbrales(umbralesAlarma umbrales) {
    // Si los valores están fuera de rango no se guarda nada
    if (umbrales.gas < 0 || umbrales.gas > UMBRAL_GAS_MAXIMO) {
        return false;
    }
    if (umbrales.temperatura < UMBRAL_TEMPERATURA_MINIMA || umbrales.temperatura > UMBRAL_TEMPERATURA_MAXIMA) {
        return false;
    }

    EEPROM.write(DIRECCION_MARCA_UMBRALES, MARCA_UMBRALES);
    EEPROM.writeInt(DIRECCION_UMBRAL_GAS, umbrales.gas);
    EEPROM.writeFloat(DIRECCION_UMBRAL_TEMPERATURA, umbrales.temperatura);

    // Sin commit() los datos no quedan guardados al apagar
    return EEPROM.commit();
}

umbralesAlarma leerUmbrales() {
    umbralesAlarma umbrales;
    umbrales.gas = UMBRAL_GAS_INICIAL;
    umbrales.temperatura = UMBRAL_TEMPERATURA_INICIAL;

    // La marca indica que alguna vez se guardaron umbrales
    if (EEPROM.read(DIRECCION_MARCA_UMBRALES) == MARCA_UMBRALES) {
        umbrales.gas = EEPROM.readInt(DIRECCION_UMBRAL_GAS);
        umbrales.temperatura = EEPROM.readFloat(DIRECCION_UMBRAL_TEMPERATURA);
    }

    return umbrales;
}
