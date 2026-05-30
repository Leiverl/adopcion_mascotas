import 'package:flutter/material.dart';
import 'package:petcare_mobile/models/adoption_request.dart';
import 'package:petcare_mobile/models/mensaje.dart';
import 'package:petcare_mobile/providers/auth_provider.dart';
import 'package:petcare_mobile/providers/chat_provider.dart';
import 'package:petcare_mobile/utils/app_colors.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatelessWidget {
  final AdoptionRequest adoptionRequest;

  const ChatScreen({super.key, required this.adoptionRequest});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider(),
      child: ChatView(adoptionRequest: adoptionRequest),
    );
  }
}

class ChatView extends StatefulWidget {
  final AdoptionRequest adoptionRequest;

  const ChatView({super.key, required this.adoptionRequest});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      final userId = authProvider.userId;
      final conversationId = widget.adoptionRequest.conversacion?.id;

      if (userId != null && conversationId != null) {
        chatProvider.connectAndLoadHistory(
          userId,
          conversationId,
          widget.adoptionRequest.id,
        );
      }
    });
  }

  @override
  void dispose() {
    Provider.of<ChatProvider>(context, listen: false).dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.sendMessage(
      _messageController.text.trim(),
      widget.adoptionRequest.id,
    );
    _messageController.clear();
    Future.delayed(const Duration(milliseconds: 50), () {
        if (_scrollController.hasClients) {
             _scrollController.animateTo(
                0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
            );
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<AuthProvider>(context, listen: false).userId;
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat sobre ${widget.adoptionRequest.mascota.nombre}'),
        backgroundColor: AppColors.background,
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true, // Mantiene la lista anclada abajo
                  padding: const EdgeInsets.all(8.0),
                  itemCount: provider.mensajes.length,
                  itemBuilder: (context, index) {
                    // --- CORRECCIÓN AQUÍ ---
                    // Accedemos a la lista de mensajes en orden inverso
                    final message = provider.mensajes.reversed.toList()[index];
                    final isMe = message.remitenteId == userId;
                    return _MessageBubble(message: message, isMe: isMe);
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 3,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  border: InputBorder.none,
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: AppColors.primary),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Mensaje message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: isMe ? AppColors.primary : Colors.grey[300],
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
              bottomRight: isMe ? Radius.zero : const Radius.circular(12),
            ),
          ),
          child: Text(
            message.cuerpo,
            style: TextStyle(color: isMe ? Colors.white : Colors.black87),
          ),
        ),
      ],
    );
  }
}