// Grupo 6 - Ducau, Jeiman & Zonis
// Datos que llegan del ESP32 por Bluetooth.

// Trama <DATOS;temperatura;humedad;luz;gas;corriente;presencia;opto;alarma;wifi;mqtt>
// Son los mismos valores que el ESP32 envía por MQTT (menos la hora).
class DatosDog {
  final double temperatura; // En grados
  final double humedad; // 0 a 99 (por MQTT viaja en el campo "presión")
  final double luz; // 0 a 99
  final double gas; // 0 a 99
  final double corriente; // 0 a 99 (0 a 3,2 A)
  final bool presencia;
  final bool opto;
  final bool alarma;
  final bool wifi; // true si el ESP32 está conectado al WiFi
  final bool mqtt; // true si el ESP32 está conectado al servidor MQTT
  final DateTime recibido;

  DatosDog({
    required this.temperatura,
    required this.humedad,
    required this.luz,
    required this.gas,
    required this.corriente,
    required this.presencia,
    required this.opto,
    required this.alarma,
    required this.wifi,
    required this.mqtt,
    required this.recibido,
  });

  /// Recibe los campos que vienen después de "DATOS". Devuelve null si faltan campos.
  static DatosDog? desdeCampos(List<String> campos) {
    if (campos.length < 10) {
      return null;
    }
    return DatosDog(
      temperatura: double.tryParse(campos[0]) ?? 0,
      humedad: double.tryParse(campos[1]) ?? 0,
      luz: double.tryParse(campos[2]) ?? 0,
      gas: double.tryParse(campos[3]) ?? 0,
      corriente: double.tryParse(campos[4]) ?? 0,
      presencia: campos[5] == '1',
      opto: campos[6] == '1',
      alarma: campos[7] == '1',
      wifi: campos[8] == '1',
      mqtt: campos[9] == '1',
      recibido: DateTime.now(),
    );
  }
}

// Trama <CONFIG;umbralGas;umbralTemperatura;nombreRed>: lo que está guardado en la EEPROM.
class ConfigDog {
  final int umbralGas;
  final double umbralTemperatura;
  final String red; // Vacío si no hay red guardada

  ConfigDog({required this.umbralGas, required this.umbralTemperatura, required this.red});

  /// Recibe los campos que vienen después de "CONFIG". La red va al final porque puede tener ';'
  static ConfigDog? desdeCampos(List<String> campos) {
    if (campos.length < 3) {
      return null;
    }
    return ConfigDog(
      umbralGas: int.tryParse(campos[0]) ?? 0,
      umbralTemperatura: double.tryParse(campos[1]) ?? 0,
      red: campos.sublist(2).join(';'),
    );
  }
}
