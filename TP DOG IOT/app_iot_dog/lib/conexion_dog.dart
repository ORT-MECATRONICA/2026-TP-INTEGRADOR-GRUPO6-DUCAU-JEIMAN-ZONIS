// Grupo 6 - Ducau, Jeiman & Zonis
// Conexión Bluetooth (BLE) con el ESP32 del IoT DOG.
//
// El ESP32 usa el "Nordic UART Service": la app escribe tramas de texto en RX
// y el ESP32 avisa (notify) por TX. Las tramas van entre '<' y '>' y pueden llegar en pedazos.
//   App -> ESP32:  <WIFI;red;clave>   <UMBRALES;gas;temperatura>   <LEER>
//   ESP32 -> App:  <DATOS;...>   <CONFIG;gas;temperatura;red>   <OK;WIFI>   <ERROR;UMBRALES>

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'modelos.dart';

// Tienen que coincidir con config.h del ESP32
final Guid uuidServicio = Guid('6e400001-b5a3-f393-e0a9-e50e24dcca9e');
final Guid uuidRx = Guid('6e400002-b5a3-f393-e0a9-e50e24dcca9e');
final Guid uuidTx = Guid('6e400003-b5a3-f393-e0a9-e50e24dcca9e');
const int largoMaximoSsid = 32;
const int largoMaximoPassword = 63;

class ConexionDog extends ChangeNotifier {
  BluetoothDevice? dispositivo;
  BluetoothCharacteristic? _rx;
  bool conectado = false;
  bool conectando = false;

  DatosDog? datos; // Último sensado recibido
  ConfigDog? config; // Última configuración recibida
  final List<double> historialTemperatura = [];
  final List<double> historialGas = [];
  static const int largoHistorial = 60; // 60 sensados = 2 minutos (el ESP32 envía cada 2 s)

  // Respuestas <OK;...> y <ERROR;...> para mostrar avisos en pantalla
  final StreamController<String> _respuestas = StreamController.broadcast();
  Stream<String> get respuestas => _respuestas.stream;

  String _buffer = '';
  StreamSubscription? _subConexion;
  StreamSubscription? _subDatos;

  Future<void> conectar(BluetoothDevice nuevo) async {
    conectando = true;
    notifyListeners();
    try {
      dispositivo = nuevo;
      // License.nonprofit: la licencia de flutter_blue_plus es gratuita para uso educativo
      await nuevo.connect(license: License.nonprofit, timeout: const Duration(seconds: 15));

      _subConexion = nuevo.connectionState.listen((estado) {
        if (estado == BluetoothConnectionState.disconnected) {
          _limpiar();
        }
      });

      List<BluetoothService> servicios = await nuevo.discoverServices();
      BluetoothService servicio = servicios.firstWhere((s) => s.uuid == uuidServicio);
      _rx = servicio.characteristics.firstWhere((c) => c.uuid == uuidRx);
      BluetoothCharacteristic tx = servicio.characteristics.firstWhere((c) => c.uuid == uuidTx);

      _subDatos = tx.onValueReceived.listen(_recibir);
      await tx.setNotifyValue(true);

      conectado = true;
      await leerConfiguracion();
    } catch (e) {
      await nuevo.disconnect();
      _limpiar();
      rethrow;
    } finally {
      conectando = false;
      notifyListeners();
    }
  }

  Future<void> desconectar() async {
    await dispositivo?.disconnect();
    _limpiar();
  }

  void _limpiar() {
    _subConexion?.cancel();
    _subDatos?.cancel();
    _rx = null;
    conectado = false;
    _buffer = '';
    notifyListeners();
  }

  // Junta los pedazos que llegan y procesa cada trama completa
  void _recibir(List<int> bytes) {
    _buffer += utf8.decode(bytes, allowMalformed: true);
    while (true) {
      int inicio = _buffer.indexOf('<');
      if (inicio == -1) {
        _buffer = '';
        return;
      }
      int fin = _buffer.indexOf('>', inicio);
      if (fin == -1) {
        _buffer = _buffer.substring(inicio);
        return;
      }
      _procesarTrama(_buffer.substring(inicio + 1, fin));
      _buffer = _buffer.substring(fin + 1);
    }
  }

  void _procesarTrama(String trama) {
    List<String> campos = trama.split(';');
    String comando = campos.first;
    List<String> resto = campos.sublist(1);

    if (comando == 'DATOS') {
      DatosDog? nuevos = DatosDog.desdeCampos(resto);
      if (nuevos != null) {
        datos = nuevos;
        _agregar(historialTemperatura, nuevos.temperatura);
        _agregar(historialGas, nuevos.gas);
      }
    } else if (comando == 'CONFIG') {
      config = ConfigDog.desdeCampos(resto);
    } else if (comando == 'OK' || comando == 'ERROR') {
      _respuestas.add(trama);
    }
    notifyListeners();
  }

  void _agregar(List<double> lista, double valor) {
    lista.add(valor);
    if (lista.length > largoHistorial) {
      lista.removeAt(0);
    }
  }

  // Envía una trama. Si es más larga que lo que entra en un mensaje BLE, va en pedazos
  // (el ESP32 los junta hasta recibir '>')
  Future<void> _enviar(String texto) async {
    BluetoothCharacteristic? rx = _rx;
    if (rx == null || dispositivo == null) {
      throw Exception('No hay conexión con el IoT DOG');
    }
    List<int> bytes = utf8.encode('<$texto>');
    int tamanio = dispositivo!.mtuNow - 3;
    for (int i = 0; i < bytes.length; i += tamanio) {
      int fin = i + tamanio;
      if (fin > bytes.length) {
        fin = bytes.length;
      }
      await rx.write(bytes.sublist(i, fin));
    }
  }

  Future<void> leerConfiguracion() => _enviar('LEER');

  Future<void> cambiarWifi(String red, String clave) => _enviar('WIFI;$red;$clave');

  Future<void> cambiarUmbrales(int gas, double temperatura) =>
      _enviar('UMBRALES;$gas;${temperatura.toStringAsFixed(1)}');
}
