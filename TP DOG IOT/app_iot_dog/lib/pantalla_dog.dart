// Grupo 6 - Ducau, Jeiman & Zonis
// Pantalla principal cuando la app está conectada: datos en vivo y configuración.
import 'dart:async';

import 'package:flutter/material.dart';

import 'conexion_dog.dart';
import 'modelos.dart';

class PantallaDog extends StatefulWidget {
  final ConexionDog conexion;
  const PantallaDog({super.key, required this.conexion});

  @override
  State<PantallaDog> createState() => _PantallaDogState();
}

class _PantallaDogState extends State<PantallaDog> {
  int pestania = 0;
  late StreamSubscription _subRespuestas;

  @override
  void initState() {
    super.initState();
    // Avisa en pantalla lo que contesta el ESP32 al guardar
    _subRespuestas = widget.conexion.respuestas.listen((respuesta) {
      String texto = respuesta;
      if (respuesta == 'OK;WIFI') texto = 'Red WiFi guardada. El IoT DOG se está conectando.';
      if (respuesta == 'OK;UMBRALES') texto = 'Umbrales guardados en la EEPROM.';
      if (respuesta == 'ERROR;WIFI') texto = 'El IoT DOG rechazó la red (nombre vacío o demasiado largo).';
      if (respuesta == 'ERROR;UMBRALES') texto = 'El IoT DOG rechazó los umbrales (fuera de rango).';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
    });
  }

  @override
  void dispose() {
    _subRespuestas.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT DOG'),
        actions: [
          IconButton(
            tooltip: 'Desconectar',
            icon: const Icon(Icons.bluetooth_disabled),
            onPressed: widget.conexion.desconectar,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.conexion,
        builder: (context, _) {
          if (pestania == 0) {
            return _PestaniaEnVivo(conexion: widget.conexion);
          }
          return _PestaniaConfiguracion(conexion: widget.conexion);
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: pestania,
        onDestinationSelected: (i) => setState(() => pestania = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.sensors), label: 'En vivo'),
          NavigationDestination(icon: Icon(Icons.tune), label: 'Configuración'),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- En vivo

class _PestaniaEnVivo extends StatelessWidget {
  final ConexionDog conexion;
  const _PestaniaEnVivo({required this.conexion});

  @override
  Widget build(BuildContext context) {
    DatosDog? d = conexion.datos;
    if (d == null) {
      return const Center(child: Text('Esperando el primer sensado…'));
    }
    ConfigDog? c = conexion.config;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _EstadoAlarma(alarma: d.alarma),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _Conexion(nombre: 'WiFi', conectado: d.wifi, icono: Icons.wifi)),
          const SizedBox(width: 8),
          Expanded(child: _Conexion(nombre: 'MQTT', conectado: d.mqtt, icono: Icons.cloud_outlined)),
        ]),
        const SizedBox(height: 12),
        _Grafico(
          titulo: 'Temperatura',
          valor: '${d.temperatura.toStringAsFixed(1)} °C',
          valores: conexion.historialTemperatura,
          umbral: c?.umbralTemperatura,
          superado: c != null && d.temperatura > c.umbralTemperatura,
        ),
        const SizedBox(height: 12),
        _Grafico(
          titulo: 'Gas',
          valor: d.gas.toStringAsFixed(0),
          valores: conexion.historialGas,
          umbral: c?.umbralGas.toDouble(),
          superado: c != null && d.gas > c.umbralGas,
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.9,
          children: [
            _Dato(icono: Icons.water_drop_outlined, nombre: 'Humedad', valor: '${d.humedad.toStringAsFixed(0)} %'),
            _Dato(icono: Icons.light_mode_outlined, nombre: 'Luz', valor: d.luz.toStringAsFixed(0)),
            _Dato(icono: Icons.bolt_outlined, nombre: 'Corriente', valor: d.corriente.toStringAsFixed(0)),
            _Dato(icono: Icons.directions_walk, nombre: 'Presencia', valor: d.presencia ? 'Sí' : 'No'),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Escala de 0 a 99, igual que lo que se envía por MQTT. Último sensado: '
          '${d.recibido.hour.toString().padLeft(2, '0')}:${d.recibido.minute.toString().padLeft(2, '0')}:${d.recibido.second.toString().padLeft(2, '0')}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _EstadoAlarma extends StatelessWidget {
  final bool alarma;
  const _EstadoAlarma({required this.alarma});

  @override
  Widget build(BuildContext context) {
    ColorScheme colores = Theme.of(context).colorScheme;
    Color fondo = alarma ? colores.errorContainer : colores.primaryContainer;
    Color texto = alarma ? colores.onErrorContainer : colores.onPrimaryContainer;
    return Card(
      color: fondo,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(children: [
          Icon(alarma ? Icons.warning_amber_rounded : Icons.verified_outlined, color: texto, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(alarma ? 'ALARMA' : 'Todo normal',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: texto, fontWeight: FontWeight.bold)),
              Text(alarma ? 'Se superó un umbral de gas o temperatura' : 'Ningún umbral superado',
                  style: TextStyle(color: texto)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Conexion extends StatelessWidget {
  final String nombre;
  final bool conectado;
  final IconData icono;
  const _Conexion({required this.nombre, required this.conectado, required this.icono});

  @override
  Widget build(BuildContext context) {
    ColorScheme colores = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(children: [
          Icon(icono, size: 20),
          const SizedBox(width: 8),
          Text(nombre),
          const Spacer(),
          Icon(Icons.circle, size: 10, color: conectado ? Colors.green : colores.error),
          const SizedBox(width: 6),
          Text(conectado ? 'OK' : 'NO'),
        ]),
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  final IconData icono;
  final String nombre;
  final String valor;
  const _Dato({required this.icono, required this.nombre, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(children: [Icon(icono, size: 18), const SizedBox(width: 6), Text(nombre)]),
          const SizedBox(height: 4),
          Text(valor, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

/// Valor actual y gráfico de los últimos sensados, con la línea del umbral
class _Grafico extends StatelessWidget {
  final String titulo;
  final String valor;
  final List<double> valores;
  final double? umbral;
  final bool superado;
  const _Grafico({required this.titulo, required this.valor, required this.valores, this.umbral, required this.superado});

  @override
  Widget build(BuildContext context) {
    ColorScheme colores = Theme.of(context).colorScheme;
    Color colorLinea = superado ? colores.error : colores.primary;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(titulo, style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            if (umbral != null)
              Text('Umbral ${umbral!.toStringAsFixed(umbral! % 1 == 0 ? 0 : 1)}', style: Theme.of(context).textTheme.bodySmall),
          ]),
          Text(valor, style: Theme.of(context).textTheme.displaySmall?.copyWith(color: colorLinea, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SizedBox(
            height: 64,
            width: double.infinity,
            child: CustomPaint(
              painter: _PintorLinea(valores: valores, umbral: umbral, color: colorLinea, colorUmbral: colores.outline),
            ),
          ),
        ]),
      ),
    );
  }
}

class _PintorLinea extends CustomPainter {
  final List<double> valores;
  final double? umbral;
  final Color color;
  final Color colorUmbral;
  _PintorLinea({required this.valores, this.umbral, required this.color, required this.colorUmbral});

  @override
  void paint(Canvas canvas, Size size) {
    if (valores.length < 2) return;
    double minimo = valores.reduce((a, b) => a < b ? a : b);
    double maximo = valores.reduce((a, b) => a > b ? a : b);
    if (umbral != null) {
      if (umbral! < minimo) minimo = umbral!;
      if (umbral! > maximo) maximo = umbral!;
    }
    if (maximo - minimo < 1) maximo = minimo + 1;

    double y(double v) => size.height - (v - minimo) / (maximo - minimo) * size.height;
    double paso = size.width / (ConexionDog.largoHistorial - 1);
    double inicioX = size.width - paso * (valores.length - 1);

    if (umbral != null) {
      Paint pintura = Paint()
        ..color = colorUmbral
        ..strokeWidth = 1;
      // Línea punteada del umbral
      for (double x = 0; x < size.width; x += 8) {
        canvas.drawLine(Offset(x, y(umbral!)), Offset(x + 4, y(umbral!)), pintura);
      }
    }

    Path camino = Path();
    for (int i = 0; i < valores.length; i++) {
      Offset punto = Offset(inicioX + paso * i, y(valores[i]));
      if (i == 0) {
        camino.moveTo(punto.dx, punto.dy);
      } else {
        camino.lineTo(punto.dx, punto.dy);
      }
    }
    canvas.drawPath(
      camino,
      Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _PintorLinea viejo) => true;
}

// ---------------------------------------------------------------- Configuración

class _PestaniaConfiguracion extends StatefulWidget {
  final ConexionDog conexion;
  const _PestaniaConfiguracion({required this.conexion});

  @override
  State<_PestaniaConfiguracion> createState() => _PestaniaConfiguracionState();
}

class _PestaniaConfiguracionState extends State<_PestaniaConfiguracion> {
  final TextEditingController red = TextEditingController();
  final TextEditingController clave = TextEditingController();
  final TextEditingController temperatura = TextEditingController();
  double gas = 50;
  bool verClave = false;
  bool cargado = false; // true cuando ya se copiaron los valores que mandó el ESP32
  bool enviando = false;

  @override
  void initState() {
    super.initState();
    _cargarConfig();
  }

  @override
  void didUpdateWidget(covariant _PestaniaConfiguracion viejo) {
    super.didUpdateWidget(viejo);
    _cargarConfig();
  }

  // Copia en los campos lo que está guardado en la EEPROM (solamente la primera vez que llega)
  void _cargarConfig() {
    ConfigDog? c = widget.conexion.config;
    if (c != null && !cargado) {
      cargado = true;
      gas = c.umbralGas.toDouble();
      temperatura.text = c.umbralTemperatura.toStringAsFixed(1);
      red.text = c.red;
    }
  }

  @override
  void dispose() {
    red.dispose();
    clave.dispose();
    temperatura.dispose();
    super.dispose();
  }

  Future<void> _ejecutar(Future<void> Function() accion) async {
    setState(() => enviando = true);
    try {
      await accion();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo enviar: $e')));
    } finally {
      if (mounted) setState(() => enviando = false);
    }
  }

  void guardarUmbrales() {
    double? t = double.tryParse(temperatura.text.replaceAll(',', '.'));
    if (t == null || t < -20 || t > 100) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La temperatura tiene que estar entre -20 y 100 °C')));
      return;
    }
    _ejecutar(() => widget.conexion.cambiarUmbrales(gas.round(), t));
  }

  void guardarWifi() {
    if (red.text.isEmpty || red.text.contains(';') || red.text.contains('>')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nombre de red vacío o con caracteres no permitidos (; >)')));
      return;
    }
    if (clave.text.contains('>')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La contraseña no puede tener el carácter >')));
      return;
    }
    _ejecutar(() => widget.conexion.cambiarWifi(red.text, clave.text));
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textos = Theme.of(context).textTheme;
    ConfigDog? c = widget.conexion.config;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.warning_amber_rounded),
                const SizedBox(width: 8),
                Text('Umbrales de alarma', style: textos.titleMedium),
              ]),
              const SizedBox(height: 4),
              Text('La alarma se activa si se supera alguno.', style: textos.bodySmall),
              const SizedBox(height: 16),
              Row(children: [
                const Text('Gas'),
                const Spacer(),
                Text(gas.round().toString(), style: textos.titleMedium),
              ]),
              Slider(value: gas, min: 0, max: 99, divisions: 99, label: gas.round().toString(), onChanged: (v) => setState(() => gas = v)),
              TextField(
                controller: temperatura,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: const InputDecoration(labelText: 'Temperatura', suffixText: '°C', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: enviando ? null : guardarUmbrales,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Guardar umbrales'),
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.wifi),
                const SizedBox(width: 8),
                Text('Red WiFi', style: textos.titleMedium),
              ]),
              const SizedBox(height: 4),
              Text(
                c == null || c.red.isEmpty ? 'No hay ninguna red guardada.' : 'Red guardada: ${c.red}',
                style: textos.bodySmall,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: red,
                maxLength: largoMaximoSsid,
                decoration: const InputDecoration(labelText: 'Nombre de la red', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: clave,
                maxLength: largoMaximoPassword,
                obscureText: !verClave,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(verClave ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => verClave = !verClave),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: enviando ? null : guardarWifi,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Guardar red'),
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: enviando ? null : () => _ejecutar(widget.conexion.leerConfiguracion),
          icon: const Icon(Icons.refresh),
          label: const Text('Volver a leer la EEPROM'),
        ),
      ],
    );
  }
}
