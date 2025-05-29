import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- Agrega esto
import 'package:shared_preferences/shared_preferences.dart';

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
import '../screens/admin/admin_ver_qr_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 🌐 Inicializa Supabase
  await Supabase.initialize(
    url:
        'https://cdcpyhnpvscspezhxzra.supabase.co', // ← Reemplaza con tu URL real
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNkY3B5aG5wdnNjc3Blemh4enJhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgzMTI3NDAsImV4cCI6MjA2Mzg4ODc0MH0.TCgUIhT6OmT9ilY_sQHP62zLS-RodnOCZ5UKulu0jy4', // ← Reemplaza con tu anon key
  );

  runApp(const MainApp());
  // Inicializa Supabase
  await Supabase.initialize(
    url: 'https://cdcpyhnpvscspezhxzra.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNkY3B5aG5wdnNjc3Blemh4enJhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgzMTI3NDAsImV4cCI6MjA2Mzg4ODc0MH0.TCgUIhT6OmT9ilY_sQHP62zLS-RodnOCZ5UKulu0jy4',
  );

  // Verifica si el usuario ya está registrado
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId');

  runApp(MainApp(initialRoute: userId == null ? '/register' : '/home'));
}

class MainApp extends StatelessWidget {
  final String initialRoute;
  const MainApp({super.key, this.initialRoute = '/register'});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UCB Explorer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF005CA7),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {
        '/loading': (context) => const LoadingScreen(),
        '/': (context) => const RegisterScreen(),
        '/register': (context) => const RegisterScreen(),
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
        '/admin-ver-qr': (context) => const AdminVerQRScreen(),
      },
    );
  }
}
