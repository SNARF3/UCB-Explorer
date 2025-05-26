import 'package:flutter/material.dart';

class ChatWidget extends StatefulWidget {
  final VoidCallback onClose;
  
  const ChatWidget({Key? key, required this.onClose}) : super(key: key);

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isExpanded = false;
  final List<Map<String, String>> _messages = [];
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );
    
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _toggleChat() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
        widget.onClose(); // Llama al callback cuando se cierra
      }
    });
  }

  void _handleMessage(String message) {
    setState(() {
      _messages.add({
        'text': message,
        'sender': 'user',
        'time': '${DateTime.now().hour}:${DateTime.now().minute}'
      });
      
      // Respuestas mejoradas con emojis
      if (message.toLowerCase().contains('hola')) {
        _messages.add({
          'text': '¡Hola! 😊 ¿En qué puedo ayudarte hoy? 🌟',
          'sender': 'bot',
          'time': '${DateTime.now().hour}:${DateTime.now().minute}'
        });
      } else if (message.toLowerCase().contains('como estas') || 
                 message.toLowerCase().contains('cómo estás')) {
        _messages.add({
          'text': '¡Estoy genial, gracias por preguntar! 💛✨ ¿Y tú cómo te sientes hoy? 😊',
          'sender': 'bot',
          'time': '${DateTime.now().hour}:${DateTime.now().minute}'
        });
      } else {
        _messages.add({
          'text': 'No entiendo completamente, pero estoy aquí para ayudarte. 💭💡',
          'sender': 'bot',
          'time': '${DateTime.now().hour}:${DateTime.now().minute}'
        });
      }
    });
    
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isExpanded)
          Positioned(
            right: 20,
            bottom: 80,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.5,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.only(
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
                                Icon(Icons.chat_bubble_outline, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'UCB chatbot 💬',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Spacer(),
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.white),
                                  onPressed: _toggleChat,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.all(8),
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                final message = _messages[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Align(
                                    alignment: message['sender'] == 'user' 
                                        ? Alignment.centerRight 
                                        : Alignment.centerLeft,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: message['sender'] == 'user' 
                                            ? const Offset(0.5, 0) 
                                            : const Offset(-0.5, 0),
                                        end: Offset.zero,
                                      ).animate(CurvedAnimation(
                                        parent: _controller,
                                        curve: Curves.easeOut,
                                      )),
                                      child: Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: message['sender'] == 'user'
                                              ? Colors.blue.shade600
                                              : Colors.yellow.shade600,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            topRight: Radius.circular(12),
                                            bottomLeft: message['sender'] == 'user' 
                                                ? Radius.circular(12) 
                                                : Radius.circular(0),
                                            bottomRight: message['sender'] == 'user' 
                                                ? Radius.circular(0) 
                                                : Radius.circular(12),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
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
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              message['time']!,
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.7),
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _textController,
                                    decoration: InputDecoration(
                                      hintText: 'Escribe un mensaje...',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(24),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade200,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      suffixIcon: Icon(Icons.mood, color: Colors.grey),
                                    ),
                                    onSubmitted: _handleMessage,
                                  ),
                                ),
                                SizedBox(width: 8),
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
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    child: IconButton(
                                      icon: Icon(Icons.send, color: Colors.white),
                                      onPressed: () {
                                        if (_textController.text.isNotEmpty) {
                                          _handleMessage(_textController.text);
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
                    ),
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          right: 20,
          bottom: 20,
          child: GestureDetector(
            onTap: _toggleChat,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _isExpanded 
                      ? [Colors.red.shade400, Colors.red.shade600]
                      : [Colors.blue.shade600, Colors.blue.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                _isExpanded ? Icons.close : Icons.chat,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
      ],
    );
  }
}