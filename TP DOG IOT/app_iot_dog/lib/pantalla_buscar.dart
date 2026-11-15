// Grupo 6 - Ducau, Jeiman & Zonis
// Busca el ESP32 por Bluetooth y se conecta.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'conexion_dog.dart';

class PantallaBuscar extends StatefulWidget {
  final ConexionDog conexion;
  const PantallaBuscar({super.key, required this.conexion});

  @override
  State<PantallaBuscar> createState() => _PantallaBuscarState();
}

class _PantallaBuscarState extends State<PantallaBuscar> {
  List<ScanResult> encontrados = [];
  bool buscando = false;
  BluetoothAdapterState estadoBluetooth = BluetoothAdapterState.unknown;
  late StreamSubscription _subResultados;
  late StreamSubscription _subBuscando;
  late StreamSubscription _subAdaptador;

  @override
  void initState() {
    super.initState();
    _subResultados = FlutterBluePlus.onScanResults.listen((r) => setState(() => encontrados = r));
    _subBuscando = FlutterBluePlus.isScanning.listen((b) => setState(() => buscando = b));
    _subAdaptador = FlutterBluePlus.adapterState.listen((estado) {
      setState(() => estadoBluetooth = estado);
      if (estado == BluetoothAdapterState.on) {
        buscar();
      }
    });
  }

  @override
  void dispose() {
    _subResultados.cancel();
    _subBuscando.cancel();
    _subAdaptador.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  Future<void> buscar() async {
    try {
      // Solamente aparecen los dispositivos que tienen el servicio del IoT DOG
      await FlutterBluePlus.startScan(withServices: [uuidServicio], timeout: const Duration(seconds: 10));
    } catch (e) {
      _avisar('No se pudo buscar: $e');
    }
  }

  Future<void> conectar(BluetoothDevice dispositivo) async {
    await FlutterBluePlus.stopScan();
    try {
      await widget.conexion.conectar(dispositivo);
    } catch (e) {
      _avisar('No se pudo conectar: $e');
    }
  }

  void _avisar(String texto) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colores = Theme.of(context).colorScheme;
    bool bluetoothApagado = estadoBluetooth == BluetoothAdapterState.off;

    return Scaffold(
      appBar: AppBar(title: const Text('IoT DOG')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: buscando || bluetoothApagado ? null : buscar,
        icon: buscando
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.bluetooth_searching),
        label: Text(buscando ? 'Buscando…' : 'Buscar'),
      ),
      body: ListenableBuilder(
        listenable: widget.conexion,
        builder: (context, _) {
          if (widget.conexion.conectando) {
            return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Conectando con el IoT DOG…'),
            ]));
          }
          if (bluetoothApagado) {
            return _Mensaje(icono: Icons.bluetooth_disabled, texto: 'Prendé el Bluetooth del celular para buscar el IoT DOG');
          }
          if (encontrados.isEmpty) {
            return _Mensaje(
              icono: Icons.pets,
              texto: buscando ? 'Buscando el IoT DOG…' : 'No se encontró ningún IoT DOG.\nVerificá que esté prendido y tocá Buscar.',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Dispositivos encontrados', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              for (ScanResult r in encontrados)
                Card(
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: colores.primaryContainer, child: const Icon(Icons.pets)),
                    title: Text(r.device.platformName.isEmpty ? 'IoT DOG' : r.device.platformName),
                    subtitle: Text('${r.device.remoteId}  ·  ${r.rssi} dBm'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => conectar(r.device),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Mensaje extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _Mensaje({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icono, size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(texto, textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}
