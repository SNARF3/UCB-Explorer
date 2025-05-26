import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import '../screens/student/home_screen.dart';
import '../screens/student/qr_scanner_screen.dart';
import '../screens/student/register_screen.dart';
import '../screens/student/loading_screen.dart';
import '../screens/student/trivia_screen.dart';
import '../screens/student/mapa_screen.dart';
import '../screens/student/premios_screen.dart';
import '../screens/admin/login_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/crear_pregunta_screen.dart';
import '../screens/admin/ver_preguntas_screen.dart';
import '../screens/admin/crear_qr_simple_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
        '/login': (context) => const LoginScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
        '/admin-crear-pregunta': (context) => const CrearPreguntaScreen(),
        '/admin-ver-preguntas': (context) => const VerPreguntasScreen(),
        '/admin-crear-qr': (context) => const CrearQRSimpleScreen(),
      },
    );
  }
}
