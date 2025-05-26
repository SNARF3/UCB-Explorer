import 'package:flutter/material.dart';
import '../screens/student/home_screen.dart';
import '../screens/student/qr_scanner_screen.dart';
import '../screens/student/register_screen.dart';
import '../screens/student/loading_screen.dart';
import '../screens/student/trivia_screen.dart';
import '../screens/student/mapa_screen.dart';
import '../screens/student/premios_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UCB Explorer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF005CA7),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/loading', // Inicia con la pantalla de carga
      routes: {
        '/loading': (context) => const LoadingScreen(),
        '/': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/qr': (context) => const QRScannerScreen(),
        '/trivia': (context) => const TriviaScreen(),
        '/mapa': (context) => const MapaScreen(),
        '/premios': (context) => const PremiosScreen(),
      },
    );
  }
}