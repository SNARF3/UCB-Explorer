import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/punto_card.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool _isChatOpen = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuad,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleChat() {
    setState(() {
      _isChatOpen = !_isChatOpen;
      if (_isChatOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
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
                  image: AssetImage('lib/assets/images/banner.jpg'), // Ruta corregida
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
          
          // Chat Widget con animaciones
          if (_isChatOpen)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: FadeTransition(
                        opacity: _opacityAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Material(
                            borderRadius: BorderRadius.circular(16),
                            elevation: 8,
                            child: Container(
                              margin: const EdgeInsets.only(top: 0), // Reduce el margen superior
                              width: screenWidth * 0.9,
                              height: screenHeight * 0.8, // Ajusta la altura si es necesario
                              child: ChatWidget(
                                onClose: _toggleChat,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          
          // Botón de chat flotante
          Positioned(
            right: 16,
            bottom: 16,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: FloatingActionButton(
                key: ValueKey<bool>(_isChatOpen),
                backgroundColor: _isChatOpen ? Colors.red : Colors.blue,
                onPressed: _toggleChat,
                child: Icon(
                  _isChatOpen ? Icons.close : Icons.chat,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}