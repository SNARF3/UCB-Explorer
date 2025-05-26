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

    _animationController.forward(); // <-- Agrega esta línea
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
            FadeTransition(
              opacity: _opacityAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner scrolleable
                    Container(
                      height: MediaQuery.of(context).size.height * 0.12,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFF004077),
                        image: DecorationImage(
                          image: AssetImage('lib/assets/images/banner.jpg'),
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.feedback, color: Colors.black),
                          label: const Text(
                            'Dejar Feedback',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 3,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/feedback');
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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