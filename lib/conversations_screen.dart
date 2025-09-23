// lib/conversations_screen.dart
import 'package:flutter/material.dart';
import 'package:emecexpo/model/conversation_model.dart';
import 'package:emecexpo/model/scanned_badge_model.dart';
import 'package:emecexpo/model/message_model.dart';
import 'package:emecexpo/messages_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  List<Conversation> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  void _loadConversations() async {
    // Simulate fetching conversations from a backend
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _conversations = [
        Conversation(
          participant: ScannedBadge(
            name: 'Mr Alieu Jagne',
            title: 'Founder CEO',
            company: 'LocaleNLP',
            profilePicturePath: 'assets/profile_alieu.png',
            companyLogoPath: 'assets/logo_localenlp.png',
            tags: ['EXHIBITOR'],
            scanDateTime: DateTime(2025, 4, 15, 18, 14),
            initials: 'AJ',
          ),
          lastMessage: Message(
            senderId: 'user_me',
            text: 'Sounds good! Looking forward to it.',
            timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
            isMe: true,
          ),
        ),
        Conversation(
          participant: ScannedBadge(
            name: 'Dr. Jane Doe',
            title: 'Head of Research',
            company: 'Innovate Labs',
            profilePicturePath: 'assets/profile_jane.png',
            companyLogoPath: 'assets/logo_innovate.png',
            tags: ['Speaker'],
            scanDateTime: DateTime(2025, 4, 16, 10, 30),
            initials: 'JD',
          ),
          lastMessage: Message(
            senderId: 'Dr. Jane Doe',
            text: 'I\'ll send you the details shortly.',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            isMe: false,
          ),
        ),
        Conversation(
          participant: ScannedBadge(
            name: 'Othniel ATSE',
            title: 'Technical Director',
            company: 'IMPROTECH',
            profilePicturePath: 'assets/profile_othniel.png',
            companyLogoPath: 'assets/logo_improtech.png',
            tags: ['EXHIBITOR'],
            scanDateTime: DateTime(2025, 4, 14, 17, 44),
            initials: 'OA',
          ),
          lastMessage: Message(
            senderId: 'user_me',
            text: 'Thanks for the presentation!',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            isMe: true,
          ),
        ),
        Conversation(
          participant: ScannedBadge(
            name: 'Ms Zhor Yasmine Mahdi',
            title: 'Data scientist',
            company: 'Smartly AI',
            profilePicturePath: null,
            companyLogoPath: 'assets/logo_smartlyai.png',
            tags: ['EXHIBITOR'],
            scanDateTime: DateTime(2025, 4, 14, 17, 13),
            initials: 'ZM',
          ),
          lastMessage: Message(
            senderId: 'Ms Zhor Yasmine Mahdi',
            text: 'Okay, I will check and get back to you.',
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
            isMe: false,
          ),
        ),
      ];
      _isLoading = false;
    });
  }

  // Helper to format message timestamp for conversation list
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}'; // HH:mm
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // FIX: Use a list of weekday names instead of substringing the number
      final List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      // DateTime.weekday returns 1 for Monday, 7 for Sunday.
      // We need to subtract 1 for 0-based indexing of the list.
      return weekdays[timestamp.weekday - 1];
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year.toString().substring(2,4)}'; // DD/MM/YY
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: const Color(0xff261350),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xff00c1c1)),
      )
          : _conversations.isEmpty
          ? const Center(
        child: Text(
          'No conversations yet.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          final conversation = _conversations[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MessagesScreen(
                    recipientBadge: conversation.participant,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.grey.shade200,
                    child: conversation.participant.profilePicturePath != null && conversation.participant.profilePicturePath!.isNotEmpty
                        ? ClipOval(
                      child: Image.asset(
                        conversation.participant.profilePicturePath!,
                        fit: BoxFit.cover,
                        width: 56,
                        height: 56,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              conversation.participant.initials,
                              style: const TextStyle(fontSize: 20, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    )
                        : Center(
                      child: Text(
                        conversation.participant.initials,
                        style: const TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                conversation.participant.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              _formatTimestamp(conversation.lastMessage.timestamp),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          conversation.lastMessage.text,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}