# Manual de usuario del IoT DOG. Uso: powershell -ExecutionPolicy Bypass -File manual_usuario.ps1 <salida.docx> [salida.pdf]
param([string]$Salida, [string]$Pdf = "")
$ErrorActionPreference = "Stop"
. "$PSScriptRoot\word.ps1"

Iniciar-Documento

T1 'Qué es el IoT DOG'
P 'El IoT DOG es un equipo que vigila el ambiente donde lo pongas. Mide la temperatura, la humedad, la luz y el gas, y se da cuenta si hay alguien cerca. Si hay demasiado gas o hace demasiado calor, te avisa.'
P 'Lo podés mirar de tres formas: en su pantalla, en tu celular con la app **IoT DOG** (por Bluetooth) o en internet, porque manda todo lo que mide a un servidor a través de tu WiFi.'
Foto 'El IoT DOG completo, con sus partes numeradas' 11
Tabla @(
    @('N°', 'Parte', 'Para qué sirve'),
    @('1', 'Pantalla', 'Muestra las conexiones y las mediciones'),
    @('2', 'Luz LED1', 'Prendida = todo bien'),
    @('3', 'Luz LED2', 'Prendida = alarma'),
    @('4', 'Sensor de temperatura y humedad', 'Mide el calor y la humedad del aire'),
    @('5', 'Sensor de gas', 'Detecta gas y humo (se pone tibio, es normal)'),
    @('6', 'Sensor de luz', 'Mide cuánta luz hay'),
    @('7', 'Sensor de presencia', 'Detecta personas hasta a 6 metros, aunque estén quietas'),
    @('8', 'Sensor de consumo', 'Mide cuánta corriente usa el equipo'),
    @('9', 'Botones 1 a 5', 'Todavía no hacen nada'),
    @('10', 'Interruptor', 'Prende y apaga el equipo'),
    @('11', 'Bornera de 12 V', 'Para conectar la fuente'),
    @('12', 'Conector USB', 'Para conectar un cargador USB (en lugar de la fuente)')
) @(8, 37, 55)

T1 'Antes de empezar'
P 'Fijate de tener todo esto a mano:'
Lista @(
    '**Una fuente de 12 V** (de al menos 1 A) **o un cargador USB de 5 V** con un cable USB tipo B, el cuadrado de las impresoras.',
    '**Una red WiFi de 2,4 GHz** con internet. Las redes de 5 GHz no andan, y tampoco las que te piden iniciar sesión en una página (como las de hoteles o bares).',
    '**El nombre y la contraseña** de esa red.',
    '**Un celular Android** con Bluetooth. La app no existe para iPhone.',
    '**La app IoT DOG**, que viene como archivo APK.'
)
P '¿Tu router tiene dos redes con nombres parecidos, y una dice “5G”? Usá la otra.'

T1 'Conexiones'
T2 'Darle energía'
P 'Elegí **una** de las dos formas. **Nunca uses las dos a la vez.**'
P '**Con la fuente de 12 V:**'
Lista -Numerada @(
    'Dejá la fuente desenchufada.',
    'Aflojá los tornillos de la bornera de 12 V.',
    'Poné el cable **positivo (+)** en el borne que dice **12V** y el **negativo (−)** en el que dice **GND**.',
    'Ajustá los tornillos y enchufá la fuente.'
)
P 'Si los conectás al revés no se rompe nada: simplemente no prende. Invertí los cables y listo.'
Foto 'La fuente conectada a la bornera, con el + y el − marcados' 8
P '**Con un cargador USB:** enchufá el cable en el conector cuadrado del equipo y el otro extremo al cargador. Funciona todo igual, salvo el consumo, que va a marcar 0.'
Foto 'El cable USB conectado al equipo' 7
T2 'Los sensores'
P 'Los sensores ya vienen conectados. Si alguno se suelta, cada uno tiene su lugar marcado en la placa y el conector entra de una sola forma.'
Tabla @(
    @('Sensor', 'Conector', 'Un consejo'),
    @('Temperatura y humedad', 'H1', 'Lejos del sol y de las partes de la placa que se calientan'),
    @('Gas', 'H11', 'Con aire circulando alrededor'),
    @('Luz', 'H2', 'Destapado, mirando al ambiente'),
    @('Presencia', 'H5', 'Apuntando a la zona que querés vigilar, sin metal adelante'),
    @('Consumo', 'H3', 'Va adentro, no hay que tocarlo'),
    @('Pantalla', 'H4', 'Que quede a la vista')
) @(28, 14, 58)
Foto 'Los sensores y sus conectores' 10

T1 'Primeros pasos'
T2 'Instalar la app'
Lista -Numerada @(
    'Pasá el archivo APK al celular y tocalo.',
    'Android te va a pedir permiso para instalar apps de origen desconocido. Aceptá (pasa con cualquier app que no viene de Google Play).',
    'Abrí la app y aceptá los permisos de Bluetooth y dispositivos cercanos.'
)
Foto 'La app buscando el equipo' 10
T2 'Prenderlo'
Lista -Numerada @(
    'Conectá la energía y mové el interruptor.',
    'En la pantalla aparece **BIENVENIDO A IoT DOG** y después la pantalla normal.',
    'Esperá unos **3 minutos** antes de confiar en la medición de gas: el sensor se tiene que calentar.'
)
T2 'Conectar el celular y cargar el WiFi'
Lista -Numerada @(
    'Prendé el Bluetooth del celular y abrí la app. Va a aparecer **IoT DOG**: tocalo.',
    'Andá a la pestaña **Configuración**.',
    'En **Red WiFi** escribí el nombre y la contraseña de tu red, tal cual (las mayúsculas importan).',
    'Tocá **Guardar red**. En la pantalla del equipo aparece **GUARDADO**.',
    'En unos segundos la pantalla tiene que mostrar `W:OK` y después `M:OK`.'
)
Foto 'La pestaña Configuración de la app' 10
P 'Listo. De acá en adelante el equipo se conecta solo cada vez que lo prendas, y ya podés cerrar la app: sigue funcionando sin el celular.'

T1 'Cómo se usa'
P 'No hay que hacer nada: una vez prendido, el equipo mide cada 2 segundos, avisa si hay un problema y manda los datos a internet solo.'
T2 'La pantalla'
P 'Se ve más o menos así:'
Codigo @('W:OK M:OK BT:NO', '24.2C 52% G:12')
Tabla @(
    @('Lo que dice', 'Qué significa'),
    @('W:OK / W:NO', 'Si está conectado al WiFi'),
    @('M:OK / M:NO', 'Si está conectado al servidor de internet'),
    @('BT:OK / BT:NO', 'Si hay un celular conectado'),
    @('24.2C', 'Temperatura, en grados'),
    @('52%', 'Humedad'),
    @('G:12', 'Gas, de 0 (aire limpio) a 100')
) @(30, 70)
T2 'Las luces'
Lista @(
    '**LED1 prendido:** todo en orden.',
    '**LED2 prendido:** hay alarma.'
)
T2 'La app'
P 'En la pestaña **En vivo** ves si hay alarma, si el equipo tiene WiFi e internet, gráficos de la temperatura y el gas de los últimos 2 minutos (con una línea que marca el límite) y la humedad, la luz, el consumo y si hay alguien cerca. En la pestaña **Configuración** cambiás los límites de la alarma y la red WiFi.'
Foto 'La pestaña En vivo de la app' 10
T2 'La alarma'
P 'Se prende cuando el **gas** o la **temperatura** pasan el límite que elegiste. Se enciende el LED2, la app lo muestra en rojo y queda registrado en internet. Cuando los valores bajan, se apaga sola.'
P '**Si la alarma es por gas:** no prendas ni apagues luces, no uses fuego, abrí las ventanas, cerrá la llave del gas si podés y salí. Desde afuera llamá a la empresa de gas o a los bomberos (100). Ojo: este equipo es un trabajo práctico y **no reemplaza a un detector de gas certificado**.'
T2 'Internet'
P 'El equipo guarda una medición por minuto y la manda al servidor. Si se corta internet, las va guardando (hasta unas 16 horas) y las manda cuando vuelve.'
T2 'Botones y relé'
P 'El equipo tiene 5 botones y una salida de relé pensados para el futuro. **Por ahora no hacen nada**, así que si apretás un botón y no pasa nada, no está roto.'

T1 'Configuración'
P 'Todo se cambia desde la pestaña **Configuración** de la app, y queda guardado aunque apagues el equipo o se corte la luz.'
T2 'Límites de la alarma'
P 'Mové la barra del **gas**, escribí la **temperatura** y tocá **Guardar umbrales**.'
Tabla @(
    @('Límite', 'Viene de fábrica en', 'Podés elegir entre'),
    @('Gas', '50', '0 y 99'),
    @('Temperatura', '40 °C', '−20 y 100 °C')
) @(30, 35, 35)
P 'Un límite de gas bajo avisa antes, pero puede dar falsas alarmas. Para la temperatura, elegí unos grados más que lo normal del lugar.'
T2 'Red WiFi'
P 'Si cambiaste la contraseña del router o mudaste el equipo, cargá la red de nuevo como en “Primeros pasos”. La nueva reemplaza a la anterior. El nombre de la red puede tener hasta 32 caracteres y la contraseña hasta 63.'
T2 'Lo que no se cambia desde la app'
P 'El nombre Bluetooth (**IoT DOG**), cada cuánto mide y los datos del servidor de internet. Eso lo cambia un técnico (está en el manual técnico).'

T1 'Qué hacer si…'
Tabla @(
    @('Problema', 'Qué hacer'),
    @('No prende', 'Revisá que la fuente esté enchufada, que el + y el − estén bien puestos y que el interruptor esté prendido.'),
    @('La app no encuentra el equipo', 'Prendé el Bluetooth, aceptá los permisos de la app y acercate. Si en la pantalla dice BT:OK, hay otro celular conectado: desconectalo.'),
    @('Dice W:NO', 'Volvé a cargar la red revisando mayúsculas y minúsculas. Fijate que sea de 2,4 GHz y que el equipo esté cerca del router.'),
    @('Dice W:OK pero M:NO', 'Fijate que esa red tenga internet. El equipo reintenta solo cada 10 segundos.'),
    @('La alarma suena sin motivo', 'Esperá 3 minutos después de prenderlo y ventilá (los aerosoles y productos de limpieza también la activan). Si sigue, subí el límite de gas.'),
    @('Temperatura y humedad en 0', 'Apagalo, revisá que el sensor esté bien enchufado en H1 y volvé a prenderlo.'),
    @('La presencia no cambia nunca', 'Revisá el conector H5 y que nada metálico tape el radar. Ojo: sigue marcando “Sí” unos 5 segundos después de que te vas.'),
    @('El consumo marca 0', 'Es normal si lo alimentás por USB.'),
    @('La app se desconecta sola', 'Te alejaste mucho. Acercate y volvé a conectarte.')
) @(30, 70)

T1 'Cuidados'
T2 'Seguridad'
Lista @(
    'Mantenelo **lejos del agua**: nada de baños, exterior ni manos mojadas. Si se moja, desenchufalo y no lo prendas.',
    'Usá solo una fuente de **12 V** o un cargador **USB de 5 V**. **Nunca lo conectes directo a 220 V.**',
    'No uses la fuente y el USB al mismo tiempo.',
    'Conectá y desconectá cables siempre con la fuente desenchufada.',
    'Algunas partes se calientan: no las toques con el equipo prendido y no lo tapes.',
    'No lo apoyes sobre metal: puede hacer cortocircuito por abajo.',
    'Lejos de chicos y mascotas.'
)
T2 'Mantenimiento'
Lista @(
    '**Una vez por mes:** sacale el polvo con un pincel seco, con el equipo desenchufado. Nada de agua ni aerosoles.',
    '**Cada 3 meses:** revisá que los cables estén firmes y probá la alarma acercando un encendedor **sin prenderlo** (solo largando el gas) un par de segundos. El LED2 se tiene que prender.',
    '**Cada 2 o 3 años:** conviene cambiar el sensor de gas, porque pierde sensibilidad con el tiempo.'
)

Terminar-Documento $Salida $Pdf
Write-Output "OK: $Salida"
