import 'package:flutter/material.dart';
import 'qr_scanner_screen.dart';

class TriviaScreen extends StatefulWidget {
  const TriviaScreen({super.key});

  @override
  _TriviaScreenState createState() => _TriviaScreenState();
}

class _TriviaScreenState extends State<TriviaScreen> {
  final List<Map<String, dynamic>> _preguntas = [
    {
      'pregunta': '¿En qué año fue fundada la UCB?',
      'tipo': 'multiple',
      'opciones': ['1966', '1975', '1982', '1990'],
      'respuesta': 0,
      'puntos': 500,
      'respondida': false,
    },
    {
      'pregunta': '¿Dónde comen los estudiantes?',
      'tipo': 'qr',
      'puntos': 1000,
      'lugar': 'Cafetería principal',
      'respondida': false,
    },
    {
      'pregunta': '¿Cuál es el lema de la universidad?',
      'tipo': 'multiple',
      'opciones': [
        'Ciencia y Virtud',
        'Educación Integral',
        'Saber para Servir',
        'Excelencia Académica',
      ],
      'respuesta': 2,
      'puntos': 750,
      'respondida': false,
    },
    {
      'pregunta': '¿Dónde se encuentra el auditorio principal?',
      'tipo': 'qr',
      'puntos': 1200,
      'lugar': 'Edificio administrativo',
      'respondida': false,
    },
    {
      'pregunta': '¿Cuántas facultades tiene la UCB?',
      'tipo': 'multiple',
      'opciones': ['8', '10', '12', '15'],
      'respuesta': 0,
      'puntos': 600,
      'respondida': false,
    },
  ];

  int _puntosTotales = 0;

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
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: pregunta['respondida'] ? Colors.grey[200] : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pregunta['pregunta'],
                      style: const TextStyle(
                        color: Color(0xFF004077),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (pregunta['tipo'] == 'multiple')
                      ...pregunta['opciones'].map((opcion) {
                        final indice = pregunta['opciones'].indexOf(opcion);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF004077),
                              minimumSize: const Size(double.infinity, 40),
                            ),
                            onPressed:
                                pregunta['respondida']
                                    ? null
                                    : () {
                                      if (indice == pregunta['respuesta']) {
                                        setState(() {
                                          pregunta['respondida'] = true;
                                          _puntosTotales +=
                                              (pregunta['puntos'] as num)
                                                  .toInt();
                                        });
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '¡Correcto! +${pregunta['puntos']} puntos',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    },
                            child: Text(
                              opcion,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }).toList()
                    else
                      Column(
                        children: [
                          Text(
                            'Escanea el QR en: ${pregunta['lugar']}',
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
                            onPressed:
                                pregunta['respondida']
                                    ? null
                                    : () => _escanearQR(pregunta),
                          ),
                        ],
                      ),
                    if (pregunta['respondida'])
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '+${pregunta['puntos']} puntos obtenidos',
                          style: const TextStyle(
                            color: Colors.green,
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
