//Grupo 6 - Ducau, Jeiman & Zonis
#pragma once

enum ESTADOS {
    INICIO,
    RECIBIENDO_DATOS_BLUETOOTH,
    INFORMACION_RECIBIDA,
    GUARDANDO_DATOS,
    DATOS_MQTT,
}; ESTADOS estadoActual;