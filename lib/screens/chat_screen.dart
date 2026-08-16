import 'package:flutter/material.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'sender': 'bot',
      'text': 'Hello! Welcome to Velora Brew Support. How can we assist you today?'
    }
  ];
  bool _isLoading = false;

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isLoading = true;
    });
    _controller.clear();

    Timer(const Duration(milliseconds: 1500), () {
      _generateBotResponse(text);
    });
  }

  void _generateBotResponse(String userMessage) {
    String lowerMsg = userMessage.toLowerCase();
    String botReply = "I'm sorry, I didn't quite catch that. You can ask me about our coffee menu, cakes, prices, or opening hours!";

    
    if (lowerMsg.contains('hi') || lowerMsg.contains('hello') || lowerMsg.contains('hey')) {
      botReply = "Hi there! What can I get brewing for you today?";
    } else if (lowerMsg.contains('menu') || lowerMsg.contains('coffee') || lowerMsg.contains('coffe') || lowerMsg.contains('latte') || lowerMsg.contains('espresso')) {
      botReply = "Our signature menu features rich Espressos, creamy Lattes, and our special Velora Cold Brew. Would you like to place an order?";
    } else if (lowerMsg.contains('cake') || lowerMsg.contains('food') || lowerMsg.contains('eat') || lowerMsg.contains('sweet')) {
      botReply = "We have a selection of delicious chocolate and red velvet cakes! But be careful, at Velora Brew, sometimes even a coffee cup might just be a hyper-realistic cake in disguise! 😉 What slice can I get you?";
    } else if (lowerMsg.contains('time') || lowerMsg.contains('open') || lowerMsg.contains('hours') || lowerMsg.contains('close')) {
      botReply = "We are open from 7:00 AM to 10:00 PM every day. We'd love to see you at Velora Brew!";
    } else if (lowerMsg.contains('price') || lowerMsg.contains('cost') || lowerMsg.contains('how much')) {
      botReply = "Our coffees start at \$3, and our delicious cake slices start at \$5. You can check the full menu for exact prices!";
    } else if (lowerMsg.contains('order') || lowerMsg.contains('buy') || lowerMsg.contains('want')) {
      botReply = "Awesome! Please head over to our Menu page to select your favorites and place the order directly.";
    } else if (lowerMsg.contains('thank') || lowerMsg.contains('thnx') || lowerMsg.contains('thanks')) {
      botReply = "You're very welcome! Have a wonderful day ahead.";
    } else if (lowerMsg.contains('bye') || lowerMsg.contains('goodbye')) {
      botReply = "Goodbye! Hope to see you again soon.";
    }

    setState(() {
      _messages.add({
        'sender': 'bot',
        'text': botReply
      });
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Live Customer Support',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isBot = message['sender'] == 'bot';
                return _buildMessageBubble(message['text']!, isBot);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: Colors.orange),
            ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isBot) {
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isBot ? const Color(0xFF1E1E1E) : Colors.orange,
          borderRadius: BorderRadius.circular(12.0),
          border: isBot ? Border.all(color: Colors.orange.withOpacity(0.5)) : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isBot ? Colors.white : Colors.black,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      color: const Color(0xFF1A1A1A),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.black),
              onPressed: () => _sendMessage(_controller.text),
            ),
          ),
        ],
      ),
    );
  }
}