# Manual técnico del IoT DOG. Uso: powershell -ExecutionPolicy Bypass -File manual_tecnico.ps1 <salida.docx> [salida.pdf]
param([string]$Salida, [string]$Pdf = "")
$ErrorActionPreference = "Stop"
. "$PSScriptRoot\word.ps1"
$img = "$PSScriptRoot\img"

Iniciar-Documento

T1 'Cómo está hecho'
P 'El IoT DOG gira alrededor de un **ESP32** (placa DevKitC de 30 pines). Cada 2 segundos lee sus sensores, actualiza la pantalla y los LEDs, y decide si hay alarma comparando el gas y la temperatura con dos umbrales. Los datos salen por dos lados: por **Bluetooth Low Energy** hacia la app de Android y por **WiFi** hacia un servidor **MQTT** en la nube.'
P 'Este manual es para quien tenga que reparar, medir o modificar el equipo.'
Foto 'El equipo completo, con cada parte numerada según la tabla' 11
Tabla @(
    @('N°', 'Parte', 'Ref.', 'Modelo y datos'),
    @('1', 'Microcontrolador', 'U4', 'ESP32 DevKitC. 3,3 V, ADC de 12 bits, WiFi 2,4 GHz y BLE'),
    @('2', 'Pantalla', 'H4', 'LCD 16×2 con adaptador I2C PCF8574, dirección 0x27, 5 V'),
    @('3', 'Temperatura y humedad', 'H1', 'AHT10, I2C 0x38. −40 a 85 °C (±0,3 °C), 0 a 100 % HR (±2 %)'),
    @('4', 'Gas', 'H11', 'MQ-2: GLP, propano, metano, humo (300 a 10000 ppm). Calefactor de 5 V, ≈ 150 mA'),
    @('5', 'Luz', 'H2', 'LDR en divisor con 10 kΩ'),
    @('6', 'Presencia', 'H5', 'Radar HLK-LD2410C, 24 GHz, hasta 6 m. UART a 256000 baudios, 5 V, ≈ 80 mA'),
    @('7', 'Consumo', 'H3', 'INA219, I2C 0x40, shunt de 0,1 Ω. Hasta 26 V y ±3,2 A'),
    @('8', 'LEDs', 'J4, J3', 'LED1 (normal) y LED2 (alarma), con 220 Ω'),
    @('9', 'Botones', 'H6 a H10', '5 pulsadores con pull-up de 10 kΩ. Sin función en el firmware actual'),
    @('10', 'Relé', 'U5, P3', 'SRD-05VDC-SL-C, 10 A / 250 V CA. Sin función en el firmware actual'),
    @('11', 'Entrada 12 V', 'P2', 'Bornera, con diodo 1N4007 contra polaridad invertida'),
    @('12', 'Entrada USB', 'U1', 'USB tipo B, solo alimentación (5 V)'),
    @('13', 'Reguladores', 'U2, U3', '7809 y 7805 en cascada (TO-220)'),
    @('14', 'Interruptor', 'U6', 'Corta la línea de 5 V'),
    @('15', 'Puntos de prueba', 'J5, J7, J6', 'TP12V, TP5V y TPGND, para el multímetro')
) @(6, 22, 12, 60)

T1 'La placa'
P 'La PCB mide 100 × 88 mm y es de **simple faz**: todas las pistas van abajo, y la única conexión que no entraba se resolvió con un puente por arriba (la línea roja). Los sensores no van soldados: se conectan con cables a conectores Molex, así se cambian fácil.'
Imagen "$img\pcb.png" 13 'Diseño de la PCB en EasyEDA'
Foto 'La placa real, del lado de los componentes' 9
Foto 'La placa real, del lado de la soldadura' 9

T1 'Conexiones eléctricas'
T2 'Alimentación'
P 'Entra por la bornera de **12 V** o por el **USB de 5 V** (una sola a la vez). Los 12 V pasan primero por el **INA219**, que así mide el consumo de todo el equipo; después por el diodo **D2**, que protege si se invierte la polaridad, y después bajan en dos escalones: el **7809** a 9 V y el **7805** a 5 V. Se usan dos reguladores para repartir el calor: un regulador lineal quema toda la diferencia de tensión, y uno solo bajando de 11 a 5 V se calentaría bastante más.'
P 'El USB entra directo a la salida del 7805, así que por ahí no se mide consumo. El interruptor lleva los 5 V al ESP32, la pantalla, el radar, el MQ-2 y el relé. Los **3,3 V** salen del regulador de la placa del ESP32 y alimentan al AHT10, al INA219, a la LDR y a los pull-ups.'
Imagen "$img\bloques.png" 15.5 'Diagrama en bloques'
P 'Consumo típico: entre **350 y 450 mA** (el ESP32 con WiFi, el calefactor del MQ-2 y el radar son lo que más gasta). Por eso conviene una fuente de 1 A. El 7805 disipa alrededor de 1,5 W y se calienta: es normal.'
T2 'Pines del ESP32'
Tabla @(
    @('GPIO', 'Conectado a', 'Notas'),
    @('36', 'MQ-2 (salida AO)', 'Entrada analógica, pasa por un divisor 10 kΩ / 18 kΩ'),
    @('34', 'LDR', 'Entrada analógica, divisor con 10 kΩ y capacitor de 100 nF'),
    @('16 / 17', 'Radar: RX / TX', 'UART'),
    @('21 / 22', 'AHT10 e INA219 (SDA / SCL)', 'Bus I2C de 3,3 V (Wire1)'),
    @('18 / 19', 'Pantalla (SDA / SCL)', 'Bus I2C de 5 V (Wire)'),
    @('12', 'LED1', '220 Ω'),
    @('14', 'LED2', '220 Ω'),
    @('13', 'Relé', 'A través del transistor Q1'),
    @('26, 25, 33, 32, 35', 'Botones 1 a 5', 'Pull-up de 10 kΩ, activos en bajo'),
    @('VIN / 3V3', 'Alimentación', '5 V de entrada / 3,3 V de salida')
) @(22, 35, 43)
P 'Las dos entradas analógicas están en el **ADC1** a propósito: el ADC2 del ESP32 deja de funcionar cuando el WiFi está prendido.'
T2 'Algunos detalles del circuito'
Lista @(
    '**Gas:** el MQ-2 entrega hasta 5 V, pero el ESP32 aguanta 3,3 V. El divisor de 10 kΩ y 18 kΩ multiplica la señal por 0,643, así que 5 V llegan como 3,2 V.',
    '**Luz:** la LDR va a 3,3 V y la resistencia de 10 kΩ a GND. Con más luz baja la resistencia de la LDR y sube la tensión en el pin.',
    '**Relé:** el ESP32 no puede manejar la bobina directamente (necesita 72 mA a 5 V), así que lo hace un transistor 2N3904. Una resistencia de 10 kΩ lo mantiene apagado durante el arranque, y el diodo D1 absorbe el pico de tensión de la bobina al apagarse.',
    '**I2C:** hay dos buses separados porque la pantalla necesita 5 V y su adaptador trae pull-ups a 5 V. Así los sensores de 3,3 V nunca ven 5 V.'
)
T2 'Conectores'
Tabla @(
    @('Conector', 'Pines'),
    @('P2 (12 V)', '1 = GND · 2 = +12 V'),
    @('P1 (5 V)', '1 = 5 V · 2 = GND'),
    @('P3 (relé)', 'COM · NA · NC'),
    @('H1 (AHT10)', '3,3 V · GND · SDA · SCL'),
    @('H2 (LDR)', '3,3 V · señal'),
    @('H3 (INA219)', 'VCC · GND · SCL · SDA · VIN− · VIN+'),
    @('H4 (pantalla)', 'GND · 5 V · SDA · SCL'),
    @('H5 (radar)', 'VCC 5 V · GND · OUT (sin usar) · RX · TX'),
    @('H11 (MQ-2)', 'VCC 5 V · GND · DO (sin usar) · AO'),
    @('H6 a H10 (botones)', 'señal · GND'),
    @('J4, J3 (LEDs)', 'GND · ánodo')
) @(30, 70)
T2 'Esquemático'
Imagen "$img\esquematico.png" 16 'Esquemático completo'
P 'Un detalle a tener en cuenta: en `config.h` los LEDs tienen los nombres cruzados respecto de la placa. `LED_1` es el pin 14, o sea el LED2 de la placa (alarma), y `LED_2` es el pin 12, el LED1 (normal). Los pines de los botones en `config.h` tampoco coinciden con la placa, pero hoy no importa porque no se usan.'

T1 'Valores normales y cómo medirlos'
P 'Todas las tensiones se miden en continua, con la punta negra del multímetro en **TPGND** y el equipo prendido.'
T2 'Tensiones'
Tabla @(
    @('Dónde', 'Tiene que dar', 'Si no da'),
    @('TP12V', '11,5 a 13 V', 'Revisar la fuente y la polaridad'),
    @('Salida del 7809', '8,6 a 9,4 V', 'Revisar U2 y sus capacitores, o el INA219 (la corriente pasa por él)'),
    @('TP5V', '4,75 a 5,25 V', 'Revisar U3 y el interruptor. Si U3 quema, hay un corto en 5 V'),
    @('Pin 3V3 del ESP32', '3,2 a 3,4 V', 'Revisar si algún sensor de 3,3 V está en corto')
) @(25, 25, 50)
T2 'Sensores'
Tabla @(
    @('Sensor', 'Valor normal', 'Cómo probarlo'),
    @('AHT10', '18 a 30 °C y 30 a 70 % en interiores', 'Comparar con un termómetro (hasta 1 °C de diferencia). Soplarle cerca: la humedad tiene que subir. Si marca 0, revisar el cable de H1.'),
    @('MQ-2', 'Bajo, lejos del umbral (50) en aire limpio. AO entre 0,3 y 1 V', 'Esperar 3 minutos de calentamiento. Acercar un encendedor apagado, largando gas: AO tiene que subir hacia 3 o 4 V y prenderse la alarma.'),
    @('LDR', '≈ 0,1 V a oscuras, ≈ 1,6 V con luz normal, ≈ 3 V con luz fuerte (en GPIO34)', 'Tapar e iluminar la LDR y medir. Si no cambia, desconectarla y medir su resistencia: ≈ 1 MΩ a oscuras, 1 a 10 kΩ con luz.'),
    @('Radar', '“No” sin gente, “Sí” con una persona a menos de 6 m', 'Medir 5 V en H5. Salir de la habitación 10 s y volver: tiene que cambiar en menos de 1 s.'),
    @('INA219', '≈ 12 V y 350 a 450 mA', 'Medir la caída entre VIN+ y VIN−: cada 10 mV son 100 mA.'),
    @('Botones', '3,3 V sueltos, 0 V apretados', 'Medir el pin del ESP32 apretando y soltando.')
) @(15, 35, 50)
T2 'El monitor serie'
P 'Conectando el ESP32 a la compu por su micro-USB y abriendo el monitor serie a **115200 baudios** se ve qué pasa adentro: si encontró cada sensor al arrancar (`AHT encontrado`, `Radar OK`, `INA219 encontrado`), la lectura del gas y de la corriente cada 2 segundos y cada mensaje que manda al servidor.'
P 'Si el servidor no conecta, aparece un código `rc`: **−2** es que no llega (sin internet o poca RAM libre), **−4** que no contestó a tiempo, **4** que el usuario o la contraseña están mal y **5** que el usuario no tiene permiso.'
P 'Para probar el hardware sin red está el programa `src/pruebaSensores.txt`: se pone en lugar del `main.cpp`, escanea los buses I2C (tienen que aparecer 0x38, 0x40 y 0x27) y muestra todos los sensores cada segundo. Desde el teclado se prenden los LEDs (`1`, `2`) y la luz de la pantalla (`b`).'

T1 'El código'
T2 'Cómo está organizado'
P 'El firmware está en C++ con Arduino y se compila con **PlatformIO**. Cada dispositivo tiene su módulo: un `.h` con su estructura de datos y un `.cpp` con `inicializarX()`, que se llama una vez en el `setup()`, y `leerX()` o `actualizarX()`, que se llaman desde el `loop()`.'
Lista @(
    '`config.h`: todas las constantes (pines, tiempos, umbrales de fábrica, Bluetooth, EEPROM y servidor).',
    '`main.cpp`: la máquina de estados y el loop.',
    '`SENSORES/` y `ACTUADORES/`: un módulo por sensor, más los LEDs, los botones y la pantalla.',
    '`CONEXION_BLUETOOTH`, `CONEXION_WIFI`, `MQTT` y `UMBRALES`: las comunicaciones y lo que se guarda en memoria.'
)
P 'Para el Bluetooth se usa **NimBLE** en lugar de la librería que trae Arduino, porque esa ocupa tanta RAM que después no alcanza para la conexión cifrada con el servidor.'
T2 'La máquina de estados'
Imagen "$img\estados.png" 13 'Estados del programa'
P 'Arranca en **INICIO**, que muestra la bienvenida 2 segundos y empieza a conectarse al WiFi. Después pasa a **DATOS_MQTT**, donde se queda casi siempre haciendo todo el trabajo. Cuando la app guarda algo, va 2 segundos a **GUARDANDO_DATOS** para mostrarlo en pantalla y vuelve.'
P 'La regla de oro del código: **nada bloquea el loop**. No hay `delay()` ni `while` esperando. Cada tarea se fija con `millis()` cuánto pasó desde la última vez. Es clave porque el radar manda unas 10 tramas por segundo y la app puede escribir en cualquier momento: si el programa se quedara esperando, se perderían datos.'
Codigo @(
    'if (millis() - tiempoSensado >= INTERVALO_SENSADO_MS) {',
    '  tiempoSensado = millis();',
    '  leerSensores();',
    '  datosMqttActual = armarDatosMqtt();',
    '  modificarEstadoLed(datosMqttActual.alarma, LED_1);',
    '  modificarEstadoLed(!datosMqttActual.alarma, LED_2);',
    '  enviarDatosBluetooth();',
    '}'
)
T2 'Sensores y alarma'
P 'El servidor espera casi todos los valores de 0 a 99, así que `pasarARango()` los convierte con una regla de tres. Si un sensor no responde, el resultado no es un número (`NaN`) y se reemplaza por 0. La alarma es una sola línea:'
Codigo @('datos.alarma = datos.gas > umbralesActuales.gas || datos.temperatura > umbralesActuales.temperatura;')
P 'El MQ-2 se calibra con dos números de `config.h`: `GAS_LECTURA_MINIMA` (la lectura del ADC en aire limpio, que se muestra como 0) y `GAS_LECTURA_MAXIMA` (la que se muestra como 100). Para ajustarlos alcanza con mirar la línea `Gas: lectura ...` del monitor serie. Como el servidor tiene un campo de presión y el equipo no tiene barómetro, ahí se manda la humedad.'
T2 'Bluetooth'
P 'El ESP32 publica el servicio **Nordic UART**, el estándar para mandar texto por BLE: la app escribe en una característica (RX) y el ESP32 le contesta por notificaciones en otra (TX). Los mensajes son texto entre `<` y `>`, con los campos separados por `;`:'
Tabla @(
    @('Mensaje', 'Para qué'),
    @('<LEER>', 'La app pide la configuración guardada'),
    @('<WIFI;red;clave>', 'La app guarda una red nueva'),
    @('<UMBRALES;gas;temp>', 'La app guarda los umbrales'),
    @('<DATOS;temp;hum;luz;gas;corr;pres;opto;alarma;wifi;mqtt>', 'El ESP32 manda las lecturas cada 2 s'),
    @('<CONFIG;gas;temp;red>', 'El ESP32 manda lo que tiene guardado'),
    @('<OK;...> / <ERROR;...>', 'Confirmación o rechazo')
) @(65, 35)
P 'Dos cosas no tan obvias: la librería recibe los datos en **otra tarea** del sistema (FreeRTOS), así que la trama se pasa al loop protegida con una sección crítica (`portENTER_CRITICAL`) para no leerla a medio escribir. Y como cada mensaje BLE tiene un tamaño máximo (el MTU), los mensajes largos se mandan en pedazos y del otro lado se juntan hasta encontrar el `>`.'
T2 'WiFi y memoria'
P 'La red y los umbrales se guardan en la **EEPROM** (en realidad, un pedazo de la flash) para que sobrevivan a un apagado. Cada bloque tiene un byte de “marca”: si la marca no está, es que nunca se guardó nada y se usan los valores de fábrica.'
Tabla @(
    @('Dirección', 'Qué guarda'),
    @('0', 'Marca de red guardada (0xA5)'),
    @('1 a 33', 'Nombre de la red (hasta 32 caracteres)'),
    @('34 a 97', 'Contraseña (hasta 63 caracteres)'),
    @('98', 'Marca de umbrales guardados (0x5A)'),
    @('99 a 106', 'Umbral de gas y umbral de temperatura')
) @(25, 75)
P 'La conexión al WiFi no frena el programa: `conectarWifi()` solo la arranca, y después se pregunta con `wifiConectado()`. Si se corta, el ESP32 se reconecta solo.'
T2 'El servidor (MQTT)'
P 'MQTT funciona con un intermediario, el **broker**: el equipo **publica** sus datos en un **tópico** (`/esp32/datos_sensores`) y el servidor de la materia está **suscripto** a ese tópico. El broker es EMQX Cloud, con conexión cifrada (TLS, puerto 8883) y usuario y contraseña.'
P '**Las credenciales** están en `src/config.h`, en `MQTT_HOST`, `MQTT_PORT`, `MQTT_USERNAME` y `MQTT_PASSWORD`. `NUMERO_DISPOSITIVO` identifica al equipo dentro del servidor. Para cambiarlas:'
Lista -Numerada @(
    'Crear el usuario en el panel del broker (o pedirlo) y anotar la dirección y el puerto.',
    'Cambiar esas constantes en `config.h`.',
    'Compilar y cargar el programa desde PlatformIO.',
    'En el monitor serie tiene que aparecer `MQTT conectado`.'
)
P 'Ojo: no conviene subir las credenciales a un repositorio público. Si ya pasó, lo mejor es cambiar la contraseña desde el panel del broker.'
P 'Para no perder datos cuando se corta internet, los sensados pasan por una **cola circular** de 1000 lugares: cada 60 s se guarda uno con su hora y cada 30 s se manda el más viejo. Solo se borra si se envió bien. La hora se pide por internet (NTP) y, hasta que llega, no se guarda nada. Cada mensaje tiene esta forma:'
Codigo @('dispositivo&hora&temperatura&humedad&luz&gas&corriente&presencia&opto&alarma', '136&1795716000&24.20&52.00&61.00&30.00&12.00&1&0&0')
P 'El campo `opto` lo pide el formato del servidor; este equipo siempre manda 0.'
T2 'La app'
P 'Está hecha en **Flutter** (carpeta `app_iot_dog`) con la librería `flutter_blue_plus`, y se instala con un APK, solo en Android. `conexion_dog.dart` se encarga de la conexión y de armar y desarmar los mensajes; `pantalla_buscar.dart` busca equipos (filtrando por el servicio, así solo aparecen IoT DOG) y `pantalla_dog.dart` tiene las pestañas **En vivo** y **Configuración**.'

Terminar-Documento $Salida $Pdf
Write-Output "OK: $Salida"
