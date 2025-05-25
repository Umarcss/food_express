import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class DriverProfilePage extends StatefulWidget {
  final String driverName;
  final String driverPhone;
  final String driverImage;
  final String driverRating;

  const DriverProfilePage({
    super.key,
    required this.driverName,
    required this.driverPhone,
    required this.driverImage,
    required this.driverRating,
  });

  @override
  State<DriverProfilePage> createState() => _DriverProfilePageState();
}

class _DriverProfilePageState extends State<DriverProfilePage> {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: '1');
  final _driver = const types.User(id: '2');
  final _textController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    // Simulate loading previous messages
    setState(() {
      _messages.addAll([
        types.TextMessage(
          author: _driver,
          id: const Uuid().v4(),
          text: 'Hello! I\'m your delivery driver. How can I help you?',
          createdAt: DateTime.now()
              .subtract(const Duration(minutes: 5))
              .millisecondsSinceEpoch,
        ),
      ]);
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      id: const Uuid().v4(),
      text: message.text,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    _addMessage(textMessage);
    _simulateDriverResponse();
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _simulateDriverResponse() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        final textMessage = types.TextMessage(
          author: _driver,
          id: const Uuid().v4(),
          text: 'I\'ll get back to you shortly!',
          createdAt: DateTime.now().millisecondsSinceEpoch,
        );
        _addMessage(textMessage);
        setState(() => _isLoading = false);
      }
    });
  }

  Future<void> _makePhoneCall() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: widget.driverPhone,
    );

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch phone call'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: _makePhoneCall,
          ),
        ],
      ),
      body: Column(
        children: [
          // Driver Profile Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(widget.driverImage),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.driverName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(widget.driverRating),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Chat Section
          Expanded(
            child: Chat(
              messages: _messages,
              onSendPressed: _handleSendPressed,
              user: _user,
              showUserAvatars: true,
              showUserNames: true,
              inputOptions: InputOptions(
                enabled: !_isLoading,
                sendButtonVisibilityMode: SendButtonVisibilityMode.always,
              ),
              theme: DefaultChatTheme(
                primaryColor: Theme.of(context).colorScheme.primary,
                secondaryColor: Theme.of(context).colorScheme.secondary,
                backgroundColor: Theme.of(context).colorScheme.background,
                userAvatarNameColors: [Theme.of(context).colorScheme.primary],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
