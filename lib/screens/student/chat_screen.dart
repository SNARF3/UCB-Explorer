import 'package:flutter/material.dart';
import '../../services/gemini_service.dart';

class ChatWidget extends StatefulWidget {
  final VoidCallback onClose;

  const ChatWidget({super.key, required this.onClose});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> with SingleTickerProviderStateMixin {
  final List<Map<String, String>> messages = [];
  final TextEditingController textController = TextEditingController();
  final GeminiService geminiService = GeminiService();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Inicializar la animación
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Mensaje de bienvenida
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        messages.add({
          'text':
              'Hola como estas, bienvenido a UCB Explorer donde puedes preguntar cualquier cosa sobre la Universidad Católica Boliviana "San Pablo"',
          'sender': 'bot',
          'time': '${DateTime.now().hour}:${DateTime.now().minute}'
        });
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleMessage(String message) async {
    setState(() {
      messages.add({
        'text': message,
        'sender': 'user',
        'time': '${DateTime.now().hour}:${DateTime.now().minute}'
      });
      _isLoading = true;
    });

    try {
      final response = await geminiService.getResponse(message);

      setState(() {
        messages.add({
          'text': response,
          'sender': 'bot',
          'time': '${DateTime.now().hour}:${DateTime.now().minute}'
        });
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        messages.add({
          'text': 'Error al obtener respuesta: $e',
          'sender': 'bot',
          'time': '${DateTime.now().hour}:${DateTime.now().minute}'
        });
        _isLoading = false;
      });
    }
  }

  void _handleClose() async {
    await _animationController.forward(); // Ejecuta la animación de escala
    widget.onClose(); // Luego cierra el chat
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(35),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.chat_bubble_outline, color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  'UCB chatbot 💬',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: _handleClose,
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.all(25),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Align(
                        alignment: message['sender'] == 'user'
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: message['sender'] == 'user'
                                ? Colors.blue.shade600
                                : Colors.yellow.shade600,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft: message['sender'] == 'user'
                                  ? const Radius.circular(12)
                                  : Radius.zero,
                              bottomRight: message['sender'] == 'user'
                                  ? Radius.zero
                                  : const Radius.circular(12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: message['sender'] == 'user'
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                message['text']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15, // Aumenta el tamaño de la fuente
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                message['time']!,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12, // Puedes ajustar este tamaño también si es necesario
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0).copyWith(bottom: 60), // Ajusta el padding inferior a 50
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixIcon: const Icon(Icons.mood, color: Colors.grey),
                    ),
                    onSubmitted: (message) async {
                      if (message.isNotEmpty) {
                        await _handleMessage(message);
                        textController.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade600, Colors.blue.shade400],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () async {
                        if (textController.text.isNotEmpty) {
                          await _handleMessage(textController.text);
                          textController.clear();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
