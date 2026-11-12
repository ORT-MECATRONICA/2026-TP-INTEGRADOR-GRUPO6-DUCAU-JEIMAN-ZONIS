//Grupo 6 - Ducau, Jeiman & Zonis
#include "MQTT.h"

WiFiClientSecure espClient;
PubSubClient mqttClient(espClient);

// Cola donde se guardan los sensados hasta que se puedan enviar
static datosMqtt cola[TAMANIO_COLA_MQTT];
static int indiceEntra = 0;      // Lugar donde se guarda el próximo sensado
static int indiceSaca = 0;       // Lugar del sensado más viejo, que es el próximo a enviar
static int cantidadEnCola = 0;   // Sensados guardados que todavía no se enviaron

static bool horaPedida = false;  // true cuando ya se le pidió la hora al servidor NTP

// Devuelve el lugar siguiente de la cola. Después del último vuelve al primero
static int siguienteLugar(int lugar) {
    lugar++;
    if (lugar >= TAMANIO_COLA_MQTT) {
        lugar = 0;
    }
    return lugar;
}

void inicializarMqtt() {
    // Conexión cifrada (SSL) sin verificar el certificado del servidor
    espClient.setInsecure();

    // Espera máxima en cada paso de la conexión, para que un servidor que no responde no trabe el loop
    espClient.setTimeout(TIMEOUT_MQTT_SEG);
    espClient.setHandshakeTimeout(TIMEOUT_MQTT_SEG);
    mqttClient.setSocketTimeout(TIMEOUT_MQTT_SEG);

    mqttClient.setServer(MQTT_HOST, MQTT_PORT);
}

bool conectarMqtt() {
    // Sin WiFi no se puede conectar
    if (WiFi.status() != WL_CONNECTED) {
        return false;
    }

    // La primera vez que hay WiFi se pide la hora por internet. Llega sola unos segundos después
    if (!horaPedida) {
        configTime(GMT_OFFSET_SEG, 0, SERVIDOR_NTP);
        horaPedida = true;
    }

    // El nombre del cliente tiene que ser único: se arma con el número de grupo y la MAC del ESP32
    String idCliente = "ESP32_Grupo_" + String(NUMERO_DISPOSITIVO) + "_" + WiFi.macAddress();

    if (mqttClient.connect(idCliente.c_str(), MQTT_USERNAME, MQTT_PASSWORD)) {
        Serial.println("MQTT conectado");
        return true;
    } else {
        // rc: -4 el servidor no respondió, -2 no se llegó al servidor, 4 usuario o contraseña mal, 5 no autorizado
        Serial.print("MQTT: fallo la conexion, rc=");
        Serial.println(mqttClient.state());
        return false;
    }
}

bool mqttConectado() {
    return mqttClient.connected();
}

void actualizarMqtt() {
    mqttClient.loop();
}

bool guardarDatosMqtt(datosMqtt datos) {
    long horaActual = time(NULL);

    // Hasta que no llega la hora de internet no se guarda: el sensado quedaría con una hora incorrecta
    if (horaActual < HORA_MINIMA_VALIDA) {
        return false;
    }
    datos.hora = horaActual;

    // Si la cola está llena se descarta el sensado más viejo para hacerle lugar al nuevo
    if (cantidadEnCola == TAMANIO_COLA_MQTT) {
        indiceSaca = siguienteLugar(indiceSaca);
        cantidadEnCola--;
    }

    cola[indiceEntra] = datos;
    indiceEntra = siguienteLugar(indiceEntra);
    cantidadEnCola++;
    return true;
}

bool enviarDatosMqtt() {
    // No hay nada para enviar
    if (cantidadEnCola == 0) {
        return false;
    }

    datosMqtt datos = cola[indiceSaca];

    char mensaje[150];
    snprintf(mensaje, sizeof(mensaje), "%d&%ld&%.2f&%.2f&%.2f&%.2f&%.2f&%d&%d&%d",
             NUMERO_DISPOSITIVO, datos.hora, datos.temperatura, datos.presion, datos.luz,
             datos.gas, datos.corriente, datos.presencia, datos.opto, datos.alarma);

    // El sensado se saca de la cola recién cuando se pudo enviar.
    // Si el envío falla (por ejemplo sin conexión) queda guardado para el próximo intento
    if (mqttClient.publish(MQTT_PUB, mensaje)) {
        indiceSaca = siguienteLugar(indiceSaca);
        cantidadEnCola--;
        Serial.print("MQTT enviado: ");
        Serial.println(mensaje);
        return true;
    } else {
        return false;
    }
}

int mqttDatosPendientes() {
    return cantidadEnCola;
}
