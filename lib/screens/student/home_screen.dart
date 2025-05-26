import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/punto_card.dart';
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

    return SafeArea( // <-- Agrega SafeArea aquí
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(screenHeight * 0.12),
          child: AppBar(
            backgroundColor: const Color(0xFF004077),
            elevation: 0,
            flexibleSpace: Center( // Centra verticalmente el banner
              child: Container(
                height: screenHeight * 0.10, // Igual que preferredSize
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('lib/assets/images/banner.jpg'),
                    fit: BoxFit.contain,
                    alignment: Alignment.center, // Centrado vertical y horizontal
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '¡Bienvenido!',
                          style: TextStyle(
                            color: Color(0xFF004077),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Explora la UCB, gana puntos y canjea premios.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const PuntoCard(puntos: 120),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: GridView(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          childAspectRatio: 1.05,
                        ),
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
                            onTap: () => Navigator.pushNamed(context, '/trivia'),
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
                  ),
                ),
              ],
            ),
            // Chat Widget
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
                  child: const Icon(Icons.chat, color: Color(0xFF004077), size: 30),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}