// Grupo 6 - Ducau, Jeiman & Zonis
import 'package:flutter/material.dart';

import 'conexion_dog.dart';
import 'pantalla_buscar.dart';
import 'pantalla_dog.dart';

void main() {
  runApp(const AppIotDog());
}

class AppIotDog extends StatefulWidget {
  const AppIotDog({super.key});

  @override
  State<AppIotDog> createState() => _AppIotDogState();
}

class _AppIotDogState extends State<AppIotDog> {
  final ConexionDog conexion = ConexionDog();

  @override
  Widget build(BuildContext context) {
    const Color semilla = Color(0xFF0F766E); // Verde azulado
    return MaterialApp(
      title: 'IoT DOG',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: semilla, useMaterial3: true),
      darkTheme: ThemeData(colorSchemeSeed: semilla, brightness: Brightness.dark, useMaterial3: true),
      // Si está conectado muestra los datos; si no, la búsqueda del ESP32
      home: ListenableBuilder(
        listenable: conexion,
        builder: (context, _) {
          if (conexion.conectado) {
            return PantallaDog(conexion: conexion);
          }
          return PantallaBuscar(conexion: conexion);
        },
      ),
    );
  }
}
