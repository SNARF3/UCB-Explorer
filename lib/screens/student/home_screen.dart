import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/punto_card.dart';
import 'qr_scanner_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  bool _isChatOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.15),
        child: AppBar(
          backgroundColor: const Color.fromARGB(255, 0, 64, 117),
          elevation: 0,
          flexibleSpace: Center(
            child: Container(
              height: screenHeight * 0.12,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/banner.jpg'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Contenido principal
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '¡Bienvenido!',
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 73, 134),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Explora la UCB, gana puntos y canjea premios.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      const PuntoCard(puntos: 120),
                      const SizedBox(height: 24),
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 3,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          padding: const EdgeInsets.all(8),
                          children: [
                            CustomButton(
                              icon: Icons.qr_code_scanner,
                              text: 'Escanear QR',
                              onTap: () => Navigator.pushNamed(context, '/qr'),
                              color: const Color(0xFFFFD700),
                            ),
                            CustomButton(
                              icon: Icons.card_giftcard,
                              text: 'Premios',
                              onTap: () => Navigator.pushNamed(context, '/premios'),
                              color: const Color(0xFFFFD700),
                            ),
                            CustomButton(
                              icon: Icons.videogame_asset,
                              text: 'Juegos',
                              onTap: () => Navigator.pushNamed(context, '/juegos'),
                              color: const Color(0xFFFFD700),
                            ),
                            CustomButton(
                              icon: Icons.map,
                              text: 'Mapa',
                              onTap: () => Navigator.pushNamed(context, '/mapa'),
                              color: const Color(0xFFFFD700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Chat Widget - Solución mejorada
          if (_isChatOpen) ...[
            GestureDetector(
              onTap: () => setState(() => _isChatOpen = false),
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: Material(
                borderRadius: BorderRadius.circular(16),
                elevation: 8,
                child: Container(
                  width: screenWidth * 0.9,
                  height: screenHeight * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ChatWidget(
                    onClose: () => setState(() => _isChatOpen = false),
                  ),
                ),
              ),
            ),
          ] else ...[
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: () => setState(() => _isChatOpen = true),
                child: const Icon(Icons.chat, color: Colors.blue, size: 30),
              ),
            ),
          ],
        ],
      ),
    );
  }
}