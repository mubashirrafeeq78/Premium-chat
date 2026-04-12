import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart'; // آپ کی Config فائل

class ChatGroupPage extends StatefulWidget {
  @override
  _ChatGroupPageState createState() => _ChatGroupPageState();
}

class _ChatGroupPageState extends State<ChatGroupPage> {
  final String _masterPin = "123456";
  bool _isLocked = true;
  bool _isRegistered = false;
  String _myNumber = "";
  List _messages = [];
  
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _msgController = TextEditingController();
  final TextEditingController _numController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  _loadInitialState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? num = prefs.getString('mobile_number');
    if (num != null) {
      setState(() { _myNumber = num; _isRegistered = true; });
    }
  }

  // میسجز لوڈ کرنے کا فنکشن
  _fetchMessages() async {
    var res = await Config.send("load_msg", {});
    if (res['status'] == 'success') {
      setState(() { _messages = res['data']; });
    }
  }

  // میسج بھیجنے کا فنکشن
  _sendMessage(String type, {String? content, String? url}) async {
    if (type == 'text' && _msgController.text.isEmpty) return;
    
    var data = {
      "mobile_number": _myNumber,
      "content": content ?? _msgController.text,
      "media_url": url,
      "media_type": type
    };

    var res = await Config.send("save_msg", data);
    if (res['status'] == 'success') {
      _msgController.clear();
      _fetchMessages();
    }
  }

  // --- UI Screens ---

  // 1. وہی پریمیم پن لاک اسکرین
  Widget _buildLockScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF075E54),
      body: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("6 ہندسوں کا پن کوڈ درج کریں", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold, color: Color(0xFF075E54)),
                decoration: const InputDecoration(counterText: "", border: OutlineInputBorder()),
                onChanged: (val) {
                  if (val == _masterPin) {
                    setState(() { _isLocked = false; });
                    _fetchMessages();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 2. رجسٹریشن اسکرین
  Widget _buildRegScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF25D366),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(25),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("موبائل نمبر درج کریں", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              TextField(
                controller: _numController,
                keyboardType: TextInputType.phone,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(hintText: "03XXXXXXXXX", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF075E54), padding: const EdgeInsets.all(15)),
                  onPressed: () async {
                    if (_numController.text.length == 11) {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setString('mobile_number', _numController.text);
                      setState(() { _myNumber = _numController.text; _isRegistered = true; });
                      _fetchMessages();
                    }
                  },
                  child: const Text("آگے بڑھیں", style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // 3. اصلی چیٹ ڈیزائن (HTML والا)
  @override
  Widget build(BuildContext context) {
    if (_isLocked) return _buildLockScreen();
    if (!_isRegistered) return _buildRegScreen();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF075E54),
        title: const Text("مسائل شرعیہ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: const Icon(Icons.lock, color: Colors.white),
        actions: [IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _fetchMessages)],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: NetworkImage("https://user-images.githubusercontent.com/15075759/28719144-86dc0f70-73b1-11e7-911d-60d70fcded21.png"), fit: BoxFit.cover),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  var m = _messages[index];
                  bool isMe = m['mobile_number'] == _myNumber;
                  return _buildMessageBubble(m, isMe);
                },
              ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  // میسج ببل کا ڈیزائن
  Widget _buildMessageBubble(var m, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFDCF8C6) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, spreadRadius: 1)],
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isMe ? "آپ" : m['mobile_number'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF075E54))),
            const SizedBox(height: 5),
            if (m['media_type'] == 'text') Text(m['content'] ?? ""),
            if (m['media_type'] == 'image') ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(m['media_url'])),
            if (m['media_type'] == 'audio') Row(children: const [Icon(Icons.play_arrow), Text("وائس میسج")]),
          ],
        ),
      ),
    );
  }

  // نیچے والی ان پٹ بار (وائس اور میڈیا آپشنز کے ساتھ)
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: const Color(0xFFF0F0F0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
              child: Row(
                children: [
                  const Icon(Icons.attach_file, color: Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      decoration: const InputDecoration(hintText: "میسج لکھیں...", border: InputBorder.none),
                    ),
                  ),
                  const Icon(Icons.camera_alt, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _sendMessage("text"),
            child: const CircleAvatar(
              backgroundColor: Color(0xFF25D366),
              child: Icon(Icons.send, color: Colors.white),
            ),
          ),
          const SizedBox(width: 5),
          const CircleAvatar(
            backgroundColor: Color(0xFF075E54),
            child: Icon(Icons.mic, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
