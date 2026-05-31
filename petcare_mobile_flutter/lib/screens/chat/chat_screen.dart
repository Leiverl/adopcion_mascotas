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
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final chat = Provider.of<ChatProvider>(context, listen: false);
      final userId = auth.userId;
      final conversationId = widget.adoptionRequest.conversacion?.id;
      if (userId != null && conversationId != null) {
        chat.connectAndLoadHistory(userId, conversationId, widget.adoptionRequest.id);
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
    Provider.of<ChatProvider>(context, listen: false)
        .sendMessage(_messageController.text.trim(), widget.adoptionRequest.id);
    _messageController.clear();
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(0.0,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<AuthProvider>(context, listen: false).userId;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = AppColors.bg(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Chat sobre ${widget.adoptionRequest.mascota.nombre}'),
        backgroundColor: bgColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) return const Center(child: CircularProgressIndicator());
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: provider.mensajes.length,
                  itemBuilder: (context, index) {
                    final message = provider.mensajes.reversed.toList()[index];
                    final isMe = message.remitenteId == userId;
                    return _MessageBubble(message: message, isMe: isMe, isDark: isDark);
                  },
                );
              },
            ),
          ),
          _buildMessageInput(isDark),
        ],
      ),
    );
  }

  Widget _buildMessageInput(bool isDark) {
    final inputBg = isDark ? AppColors.darkSurface : Theme.of(context).cardColor;
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: inputBg,
        border: isDark
            ? Border(top: BorderSide(color: AppColors.darkDivider))
            : null,
        boxShadow: isDark ? [] : [
          BoxShadow(offset: const Offset(0, -1), blurRadius: 3,
              color: Colors.black.withOpacity(0.1)),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                style: TextStyle(color: AppColors.text(context)),
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  hintStyle: TextStyle(color: AppColors.textSub(context)),
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
  final bool isDark;
  const _MessageBubble({required this.message, required this.isMe, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final otherBubble = isDark ? AppColors.darkSurface : Colors.grey[300]!;
    final otherText = isDark ? AppColors.darkTextDark : Colors.black87;

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: isMe ? AppColors.primary : otherBubble,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
              bottomRight: isMe ? Radius.zero : const Radius.circular(12),
            ),
          ),
          child: Text(
            message.cuerpo,
            style: TextStyle(color: isMe ? Colors.white : otherText),
          ),
        ),
      ],
    );
  }
}
