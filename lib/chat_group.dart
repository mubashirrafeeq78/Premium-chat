import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ChatGroupPage extends StatefulWidget {
  @override
  _ChatGroupPageState createState() => _ChatGroupPageState();
}

class _ChatGroupPageState extends State<ChatGroupPage> {
  final TextEditingController _msgController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  // عارضی لسٹ ڈیزائن ٹیسٹ کرنے کے لیے
  final List<Map<String, dynamic>> _dummyMessages = [
    {
      "type": "text",
      "content": "السلام علیکم! یہ پریمیم ڈیزائن اب بالکل ٹھیک کام کرے گا۔",
      "time": "12:10 PM",
      "date": "13 April 2026",
      "isMe": false
    },
    {
      "type": "audio",
      "content": "Voice Message",
      "time": "12:12 PM",
      "date": "13 April 2026",
      "isMe": true
    }
  ];

  void _addDummyMessage(String type, {String? content}) {
    setState(() {
      _dummyMessages.insert(0, {
        "type": type,
        "content": content ?? _msgController.text,
        "time": DateFormat('hh:mm a').format(DateTime.now()),
        "date": DateFormat('dd MMMM yyyy').format(DateTime.now()),
        "isMe": true
      });
      _msgController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF075E54),
        title: Row(
          children: [
            const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("مسائل شرعیہ گروپ", style: TextStyle(color: Colors.white, fontSize: 16)),
                Text("آن لائن", style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ],
        ),
        actions: const [
          Icon(Icons.videocam, color: Colors.white),
          SizedBox(width: 15),
          Icon(Icons.call, color: Colors.white),
          Icon(Icons.more_vert, color: Colors.white)
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: NetworkImage("https://user-images.githubusercontent.com/15075759/28719144-86dc0f70-73b1-11e7-911d-60d70fcded21.png"),
            fit: BoxFit.cover,
            opacity: 0.08,
          ),
          color: const Color(0xFFE5DDD5),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(12),
                itemCount: _dummyMessages.length,
                itemBuilder: (context, index) => _buildMessageItem(_dummyMessages[index]),
              ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> msg) {
    bool isMe = msg['isMe'];
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFDCF8C6) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(0),
            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(12),
          ),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 1)],
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (msg['type'] == 'text') Text(msg['content'], style: const TextStyle(fontSize: 15)),
            if (msg['type'] == 'audio') Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_arrow, color: Colors.grey),
                Container(width: 100, height: 2, color: Colors.grey[300]),
                const Icon(Icons.mic, size: 16, color: Colors.blue)
              ],
            ),
            const SizedBox(height: 4), // یہاں اب کوئی ایرر نہیں آئے گا
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("${msg['date']} | ${msg['time']}", style: const TextStyle(fontSize: 9, color: Colors.black45)),
                if (isMe) const SizedBox(width: 4),
                if (isMe) const Icon(Icons.done_all, size: 15, color: Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
              child: Row(
                children: [
                  IconButton(icon: Icon(Icons.emoji_emotions_outlined, color: Colors.grey[600]), onPressed: () {}),
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      onChanged: (v) => setState(() {}),
                      decoration: const InputDecoration(hintText: "میسج لکھیں...", border: InputBorder.none),
                    ),
                  ),
                  IconButton(icon: Icon(Icons.attach_file, color: Colors.grey[600]), onPressed: () {}),
                  IconButton(icon: Icon(Icons.camera_alt, color: Colors.grey[600]), onPressed: () {}),
                ],
              ),
            ),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: () {
              if (_msgController.text.isNotEmpty) _addDummyMessage("text");
            },
            child: CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF075E54),
              child: Icon(_msgController.text.isEmpty ? Icons.mic : Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
