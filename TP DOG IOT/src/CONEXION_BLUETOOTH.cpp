//Grupo 6 - Ducau, Jeiman & Zonis
#include "CONEXION_BLUETOOTH.h"

// Las funciones de "callbacks" las llama la librería BLE desde su propia tarea, no desde el loop.
// Por eso lo que llega se copia a tramaRecibida con la protección "candado" y el loop lo lee después.

static BLEServer* servidor = NULL;
static BLECharacteristic* caracteristicaTx = NULL;   // Por acá el ESP32 le envía datos a la aplicación
static uint16_t idConexion = 0;                      // Número de la conexión actual (para preguntar el MTU)

static char tramaArmando[LARGO_MAXIMO_TRAMA];        // Trama que está llegando de a pedazos (solo la usa la tarea BLE)
static int largoArmando = 0;
static bool armandoTrama = false;                    // true después de recibir '<' y antes de recibir '>'

static char tramaRecibida[LARGO_MAXIMO_TRAMA];       // Última trama completa, sin '<' ni '>'
static volatile bool tramaNueva = false;             // true cuando hay una trama que el loop todavía no leyó
static portMUX_TYPE candado = portMUX_INITIALIZER_UNLOCKED;

// Avisos de conexión y desconexión de la aplicación
class CallbacksServidor : public BLEServerCallbacks {
    void onConnect(BLEServer* servidorBle, esp_ble_gatts_cb_param_t* parametros) {
        idConexion = parametros->connect.conn_id;
        Serial.println("Bluetooth: aplicacion conectada");
    }

    void onDisconnect(BLEServer* servidorBle) {
        Serial.println("Bluetooth: aplicacion desconectada");
        // Vuelve a aparecer en el celular para que la aplicación se pueda conectar de nuevo
        servidorBle->startAdvertising();
    }
};

// Aviso de que la aplicación escribió algo. Un mensaje largo puede llegar en varios pedazos
class CallbacksRx : public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic* caracteristica) {
        String valor = String(caracteristica->getValue().c_str());

        for (int i = 0; i < valor.length(); i++) {
            char letra = valor[i];

            if (letra == INICIO_TRAMA) {
                // Empieza una trama nueva: lo anterior se descarta
                armandoTrama = true;
                largoArmando = 0;
            } else if (letra == FIN_TRAMA && armandoTrama) {
                // Terminó la trama: se copia para que la lea el loop
                tramaArmando[largoArmando] = '\0';
                portENTER_CRITICAL(&candado);
                strcpy(tramaRecibida, tramaArmando);
                tramaNueva = true;
                portEXIT_CRITICAL(&candado);
                armandoTrama = false;
            } else if (armandoTrama) {
                // Se guarda la letra. Si la trama es demasiado larga se descarta
                if (largoArmando < LARGO_MAXIMO_TRAMA - 1) {
                    tramaArmando[largoArmando] = letra;
                    largoArmando++;
                } else {
                    armandoTrama = false;
                }
            }
        }
    }
};

void inicializarBluetooth() {
    BLEDevice::init(NOMBRE_BLUETOOTH);
    BLEDevice::setMTU(MTU_BLE);

    servidor = BLEDevice::createServer();
    servidor->setCallbacks(new CallbacksServidor());

    BLEService* servicio = servidor->createService(UUID_SERVICIO_BLE);

    // Característica donde escribe la aplicación
    BLECharacteristic* caracteristicaRx = servicio->createCharacteristic(
        UUID_RX_BLE, BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_WRITE_NR);
    caracteristicaRx->setCallbacks(new CallbacksRx());

    // Característica por la que el ESP32 le avisa a la aplicación
    caracteristicaTx = servicio->createCharacteristic(UUID_TX_BLE, BLECharacteristic::PROPERTY_NOTIFY);
    caracteristicaTx->addDescriptor(new BLE2902());   // Necesario para que la aplicación pueda activar los avisos

    servicio->start();

    // Empieza a aparecer en el celular, mostrando el servicio para que la aplicación lo encuentre
    BLEAdvertising* anuncio = BLEDevice::getAdvertising();
    anuncio->addServiceUUID(UUID_SERVICIO_BLE);
    anuncio->setScanResponse(true);
    BLEDevice::startAdvertising();
}

bool bluetoothConectado() {
    return servidor != NULL && servidor->getConnectedCount() > 0;
}

bool hayMensajeBluetooth() {
    return tramaNueva;
}

datosBluetooth leerDatosBluetooth() {
    datosBluetooth datos;
    datos.validos = false;

    // Se copia la trama protegida con el candado, porque la tarea BLE la puede estar escribiendo
    char copia[LARGO_MAXIMO_TRAMA];
    portENTER_CRITICAL(&candado);
    strcpy(copia, tramaRecibida);
    tramaNueva = false;
    portEXIT_CRITICAL(&candado);

    String trama = String(copia);

    // Se separa en COMANDO;campo1;campo2. Todo lo que queda después del segundo ';' es campo2
    int separador1 = trama.indexOf(SEPARADOR_TRAMA);
    if (separador1 == -1) {
        datos.comando = trama;
        datos.campo1 = "";
        datos.campo2 = "";
    } else {
        datos.comando = trama.substring(0, separador1);
        int separador2 = trama.indexOf(SEPARADOR_TRAMA, separador1 + 1);
        if (separador2 == -1) {
            datos.campo1 = trama.substring(separador1 + 1);
            datos.campo2 = "";
        } else {
            datos.campo1 = trama.substring(separador1 + 1, separador2);
            datos.campo2 = trama.substring(separador2 + 1);
        }
    }

    if (datos.comando.length() > 0) {
        datos.validos = true;
    }

    return datos;
}

void enviarBluetooth(String texto) {
    if (!bluetoothConectado()) {
        return;
    }

    String trama = String(INICIO_TRAMA) + texto + String(FIN_TRAMA);

    // Cada aviso BLE lleva como mucho (MTU - 3) bytes: si la trama es más larga se envía en pedazos
    int tamanioPedazo = servidor->getPeerMTU(idConexion) - 3;
    if (tamanioPedazo < 20) {
        tamanioPedazo = 20;
    }

    for (int inicio = 0; inicio < trama.length(); inicio = inicio + tamanioPedazo) {
        String pedazo = trama.substring(inicio, inicio + tamanioPedazo);
        caracteristicaTx->setValue((uint8_t*)pedazo.c_str(), pedazo.length());
        caracteristicaTx->notify();
    }
}
