import 'package:flutter/material.dart';

class MapaScreen extends StatelessWidget {
  const MapaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colores = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.cyan,
      Colors.amber,
      Colors.deepPurple,
      Colors.teal,
      Colors.pink,
      Colors.brown,
      Colors.indigo,
      Colors.lime,
      Colors.deepOrange,
      const Color.fromARGB(255, 3, 121, 52),
    ];

    final puntos = [
      PuntoMapa(
        offset: const Offset(180, 110),
        nombre: 'Coliseo UCB',
        descripcion: 'El gran coliseo de la UCB, uno de los mejores coliseos del país, si entras en esta universidad tu bienvenida será en este lugar 😉.',
        foto: 'lib/assets/images/coliseo.jpeg',
      ),
      PuntoMapa(offset: const Offset(320, 30), nombre: 'Bloque B', descripcion: 'Descripción del Edificio B', foto: 'lib/assets/images/UCB.png'),
      PuntoMapa(offset: const Offset(450, 20), nombre: 'Bloque C', descripcion: 'Descripción del Edificio C', foto: 'lib/assets/images/UCB.png'),
      PuntoMapa(offset: const Offset(70, 270), nombre: 'Bloque D', descripcion: 'Descripción del Edificio D', foto: 'lib/assets/images/UCB.png'),
      PuntoMapa(offset: const Offset(230, 170), nombre: 'Agora', descripcion: 'Descripción del Ágora', foto: 'lib/assets/images/UCB.png'),
      PuntoMapa(offset: const Offset(520, 120), nombre: 'Bloque F', descripcion: 'Descripción del Edificio F', foto: 'lib/assets/images/UCB.png'),
      PuntoMapa(offset: const Offset(160, 290), nombre: 'Bloque G1', descripcion: 'Descripción del Edificio G1', foto: 'lib/assets/images/UCB.png'),
      PuntoMapa(offset: const Offset(300, 200), nombre: 'Bloque G2', descripcion: 'Descripción del Edificio G2', foto: 'lib/assets/images/UCB.png'),
      PuntoMapa(offset: const Offset(380, 240), nombre: 'Bloque H', descripcion: 'Descripción del Edificio H', foto: 'lib/assets/images/UCB.png'),
      PuntoMapa(offset: const Offset(500, 280), nombre: 'Bloque I', descripcion: 'Descripción del Edificio I', foto: 'lib/assets/images/UCB.png'),
      PuntoMapa(offset: const Offset(130, 360), nombre: 'Bloque J', descripcion: 'Descripción del Edificio J', foto: 'lib/assets/images/UCB.png'),
      PuntoMapa(offset: const Offset(200, 390), nombre: 'Atrio', descripcion: 'Descripción del Edificio K', foto: 'lib/assets/images/UCB.png'),
      PuntoMapa(offset: const Offset(530, 430), nombre: 'Rectorado', descripcion: 'Descripción del Edificio L', foto: 'lib/assets/images/UCB.png'),
      PuntoMapa(offset: const Offset(390, 345), nombre: 'Capilla', descripcion: 'Descripción de la Capilla', foto: 'lib/assets/images/UCB.png'),
      PuntoMapa(offset: const Offset(370, 430), nombre: 'Miamicito', descripcion: 'Descripción de Miamicito', foto: 'lib/assets/images/UCB.png'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mapa del Campus',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF005CA7),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(100),
              minScale: 0.5,
              maxScale: 3.0,
              child: Stack(
                children: [
                  Image.asset(
                    'lib/assets/images/mapa1.jpeg',
                    fit: BoxFit.contain,
                  ),
                  ...puntos.asMap().entries.map((entry) {
                    final index = entry.key;
                    final punto = entry.value;
                    final color = colores[index % colores.length];
                    return Positioned(
                      left: punto.offset.dx,
                      top: punto.offset.dy,
                      child: Column(
                        children: [
                          IconButton(
                            icon: Icon(Icons.location_on, color: color, size: 30),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: Colors.yellow[700], // Fondo más amarillo
                                  title: Text(
                                    punto.nombre,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        punto.descripcion,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.justify,
                                      ),
                                      const SizedBox(height: 8),
                                      Image.asset(
                                        punto.foto,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text(
                                        "Cerrar",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          Text(
                            punto.nombre,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              backgroundColor: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                botonNavegacion(context, 'Trivia', '/trivia'),
                botonNavegacion(context, 'Premios', '/premios'),
                botonNavegacion(context, 'QR', '/qr'),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget botonNavegacion(BuildContext context, String texto, String ruta) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, ruta);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF005CA7),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(texto, style: const TextStyle(color: Colors.white)),
    );
  }
}

class PuntoMapa {
  final Offset offset;
  final String nombre;
  final String descripcion;
  final String foto;

  PuntoMapa({
    required this.offset,
    required this.nombre,
    required this.descripcion,
    required this.foto,
  });
}
