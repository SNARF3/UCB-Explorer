import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'qr_scanner_screen.dart';

class TriviaScreen extends StatefulWidget {
  const TriviaScreen({super.key});

  @override
  _TriviaScreenState createState() => _TriviaScreenState();
}

class _TriviaScreenState extends State<TriviaScreen> {
  List<Map<String, dynamic>> _preguntas = [];
  int _puntosTotales = 0;
  bool _cargando = true;

  // Guarda la opción seleccionada por pregunta
  final Map<int, String> _opcionSeleccionada = {};

  @override
  void initState() {
    super.initState();
    _cargarPreguntas();
  }

  Future<void> _cargarPreguntas() async {
    final snapshot = await FirebaseFirestore.instance.collection('preguntas').get();
    final preguntas = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        ...data,
        'respondida': false,
      };
    }).toList();

    preguntas.shuffle(Random());
    setState(() {
      _preguntas = preguntas.take(20).toList();
      _cargando = false;
    });
  }

  Future<void> _escanearQR(Map<String, dynamic> pregunta) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );

    if (resultado != null && resultado == pregunta['lugar']) {
      setState(() {
        pregunta['respondida'] = true;
        _puntosTotales += (pregunta['puntos'] as num).toInt();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Correcto! Ganaste ${pregunta['puntos']} puntos'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Trivia Universitaria',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF004077),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _preguntas.length,
          itemBuilder: (context, index) {
            final pregunta = _preguntas[index];
            final preguntaTexto = pregunta['Pregunta'] ?? 'Pregunta no disponible';
            final tipo = pregunta['tipo'] ?? '';
            final opciones = (pregunta['opciones'] as List?) ?? [];
            final respuesta = pregunta['respuesta'] ?? '';
            final puntos = (pregunta['puntos'] as num?)?.toInt() ?? 0;
            final lugar = pregunta['lugar'] ?? '';

            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              // NO cambies el color del Card al responder, mantenlo blanco
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preguntaTexto,
                      style: const TextStyle(
                        color: Color(0xFF004077),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (tipo == 'multiple')
                      ...List<Widget>.from(opciones.map((opcion) {
                        final seleccionada = _opcionSeleccionada[index] == opcion;
                        final esCorrecta = opcion == respuesta;
                        Color colorBoton = const Color(0xFF004077);

                        if (pregunta['respondida']) {
                          if (seleccionada && esCorrecta) {
                            colorBoton = Colors.green;
                          } else if (seleccionada && !esCorrecta) {
                            colorBoton = Colors.red;
                          } else {
                            colorBoton = const Color(0xFF004077); // Siempre azul para las no seleccionadas
                          }
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorBoton,
                              minimumSize: const Size(double.infinity, 40),
                            ),
                            onPressed: () {
                              if (!pregunta['respondida']) {
                                setState(() {
                                  _opcionSeleccionada[index] = opcion;
                                  pregunta['respondida'] = true;
                                  if (opcion == respuesta) {
                                    _puntosTotales += puntos;
                                  }
                                });
                              }
                            },
                            child: Text(
                              opcion?.toString() ?? '',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }))
                    else
                      Column(
                        children: [
                          Text(
                            'Escanea el QR en: $lugar',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            icon: const Icon(
                              Icons.qr_code_scanner,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Escanear QR',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF004077),
                            ),
                            onPressed: pregunta['respondida']
                                ? null
                                : () => _escanearQR(pregunta),
                          ),
                        ],
                      ),
                    if (pregunta['respondida'])
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _opcionSeleccionada[index] == respuesta
                              ? '+$puntos puntos obtenidos'
                              : 'Respuesta incorrecta',
                          style: TextStyle(
                            color: _opcionSeleccionada[index] == respuesta
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context, _puntosTotales);
        },
        label: const Text(
          'Reclamar Puntos',
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.check, color: Colors.white),
        backgroundColor: const Color(0xFF004077),
      ),
    );
  }
}
