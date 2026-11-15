# App IoT DOG — Grupo 6 (Ducau, Jeiman & Zonis)

Aplicación Flutter (Android / iOS) que se conecta por **Bluetooth Low Energy** al ESP32 del IoT DOG para:

- ver en vivo los mismos datos que el ESP32 envía por MQTT (cada 2 s),
- cambiar los **umbrales de la alarma** (gas y temperatura) guardados en la EEPROM,
- cambiar la **red WiFi** guardada en la EEPROM.

## Cómo correrla

```bash
cd app_iot_dog
flutter pub get
flutter run
```

Hace falta un celular real: los emuladores no tienen Bluetooth.

## Protocolo BLE

El ESP32 publica el *Nordic UART Service* (UUIDs en `src/config.h` y `lib/conexion_dog.dart`):

| Característica | UUID | Uso |
|---|---|---|
| Servicio | `6e400001-b5a3-f393-e0a9-e50e24dcca9e` | |
| RX (write) | `6e400002-…` | la app escribe |
| TX (notify) | `6e400003-…` | el ESP32 avisa |

Los mensajes son texto entre `<` y `>`, separados por `;`. Pueden llegar en varios pedazos: los dos lados juntan hasta recibir `>`.

**App → ESP32**

| Trama | Qué hace |
|---|---|
| `<LEER>` | pide la configuración guardada |
| `<WIFI;red;clave>` | guarda la red en la EEPROM y se conecta |
| `<UMBRALES;gas;temperatura>` | guarda los umbrales (gas 0–99, temperatura -20 a 100 °C) |

**ESP32 → App**

| Trama | Cuándo |
|---|---|
| `<DATOS;temp;humedad;luz;gas;corriente;presencia;opto;alarma;wifi;mqtt>` | cada sensado |
| `<CONFIG;umbralGas;umbralTemp;red>` | al pedir `LEER` o después de guardar |
| `<OK;WIFI>` `<OK;UMBRALES>` | se guardó |
| `<ERROR;WIFI>` `<ERROR;UMBRALES>` `<ERROR;COMANDO>` | no se guardó |

Limitaciones: el nombre de la red no puede tener `;` y ni el nombre ni la clave pueden tener `>`.
