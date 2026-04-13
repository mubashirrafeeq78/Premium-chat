import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: ChatScreen(), debugShowCheckedModeBanner: false));

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // بیک گراؤنڈ گریڈینٹ جو آپ کی امیج سے مماثل ہے
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF3F7F9),
              Color(0xFFE6F3F5),
              Color(0xFFFDF1E1),
            ],
          ),
        ),
        child: Column(
          children: [
            // میسجز کی لسٹ
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(10, 60, 10, 10),
                children: [
                  _buildMessage("السلام علیکم، کیا حال ہے؟", "10:30 AM", true, type: "text"),
                  _buildMessage("وعلیکم السلام، میں بالکل ٹھیک ہوں۔ تم سناؤ؟", "10:30 AM", false, type: "text"),
                  _buildMessage("یہ سنیں، کل والا کام", "10:32 AM", true, type: "voice"),
                  _buildMessage("یہ یاد ہے؟", "10:30 AM", false, type: "image"),
                  _buildMessage("بالکل یاد ہے! بہت زبردست تصویر ہے!", "10:32 AM", true, type: "text"),
                ],
              ),
            ),
            // نیچے والا ان پٹ بار
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  // میسج ببل بنانے کا فنکشن
  Widget _buildMessage(String content, String time, bool isMe, {required String type}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: type == "image" ? const EdgeInsets.all(4) : const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFFE1FFC7) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(0),
                bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(12),
              ),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1))],
            ),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (type == "image")
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://picsum.photos/400/300', // یہاں اپنی امیج کا لنک یا فائل پاتھ دیں
                      fit: BoxFit.cover,
                    ),
                  ),
                if (type == "voice")
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.play_arrow, color: Color(0xFF4FA9E2), size: 30),
                      Image.asset('assets/wave.png', width: 100, errorBuilder: (c, e, s) => const Icon(Icons.linear_scale, color: Colors.grey)),
                      const Text("0:12", style: TextStyle(fontSize: 12)),
                    ],
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 5),
                  child: Text(
                    content,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    if (isMe) const SizedBox(width: 4),
                    if (isMe) const Icon(Icons.done_all, size: 14, color: Color(0xFF4FA9E2)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // نچلا حصہ (Type a message)
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
              ),
              child: Row(
                children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.attach_file, color: Colors.grey)),
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            backgroundColor: Color(0xFF25D366),
            radius: 25,
            child: Icon(Icons.mic, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
