import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart'; // آپ کی کنفگ فائل

class ChatGroupPage extends StatefulWidget {
  @override
  _ChatGroupPageState createState() => _ChatGroupPageState();
}

class _ChatGroupPageState extends State<ChatGroupPage> {
  final TextEditingController _msgController = TextEditingController();
  final TextEditingController _numController = TextEditingController();
  List _messages = [];
  String _myNumber = "";
  bool _isRegistered = false;

  @override
  void initState() {
    super.initState();
    _checkRegistration();
    // ہر 3 سیکنڈ بعد چیٹ خود بخود اپڈیٹ ہوگی
    Stream.periodic(Duration(seconds: 3)).listen((_) => _loadMessages());
  }

  _checkRegistration() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? num = prefs.getString('mobile_number');
    if (num != null) {
      setState(() { _myNumber = num; _isRegistered = true; });
      _loadMessages();
    }
  }

  // میسجز لوڈ کرنا
  _loadMessages() async {
    var res = await Config.send("load_msg", {});
    if (res['status'] == 'success') {
      setState(() { _messages = res['data']; });
    }
  }

  // میسج بھیجنا (ٹیکسٹ، میڈیا، وائس)
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
      _loadMessages();
    }
  }

  // میسج ڈیلیٹ کرنا
  _deleteMessage(int id) async {
    var res = await Config.send("delete_msg", {"message_id": id});
    if (res['status'] == 'success') _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isRegistered) return _buildRegistration();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF075E54),
        title: const Text("مسائل شرعیہ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: Icon(Icons.more_vert, color: Colors.white), onPressed: () {})],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage("https://i.pinimg.com/originals/ab/ab/60/abab600fbc396d36e2f694e820eb608c.jpg"),
            fit: BoxFit.cover,
            opacity: 0.1,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true, // نئے میسج نیچے آئیں گے
                padding: EdgeInsets.all(10),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  var m = _messages[index];
                  bool isMe = m['mobile_number'] == _myNumber;
                  return _buildBubble(m, isMe);
                },
              ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  // میسج ببل ڈیزائن (Double Tick کے ساتھ)
  Widget _buildBubble(var m, bool isMe) {
    return GestureDetector(
      onLongPress: () => _deleteMessage(m['id']),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 4),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isMe ? Color(0xFFDCF8C6) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: isMe ? Radius.circular(12) : Radius.circular(0),
              bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
            ),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 1)],
          ),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isMe) Text(m['mobile_number'], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              
              if (m['media_type'] == 'text') Text(m['content'] ?? ""),
              if (m['media_type'] == 'image') ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(m['media_url'])),
              if (m['media_type'] == 'video') Icon(Icons.play_circle_fill, size: 40, color: Colors.grey),
              if (m['media_type'] == 'audio') Row(children: [Icon(Icons.mic, size: 16), Text(" Voice Message")]),

              Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("12:00 PM", style: TextStyle(fontSize: 9, color: Colors.grey)), // ٹائم (آپ کالم ایڈ کر سکتے ہیں)
                    if (isMe) SizedBox(width: 4),
                    if (isMe) Icon(Icons.done_all, size: 14, color: Colors.blue), // Double Tick
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ان پٹ بار (وائس اور میڈیا بٹنز کے ساتھ)
  Widget _buildInputBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
              child: Row(
                children: [
                  IconButton(icon: Icon(Icons.emoji_emotions_outlined, color: Colors.grey), onPressed: () {}),
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      decoration: InputDecoration(hintText: "میسج لکھیں...", border: InputBorder.none),
                    ),
                  ),
                  IconButton(icon: Icon(Icons.attach_file, color: Colors.grey), onPressed: () => _sendMessage("image", url: "https://example.com/test.jpg")),
                  IconButton(icon: Icon(Icons.camera_alt, color: Colors.grey), onPressed: () {}),
                ],
              ),
            ),
          ),
          SizedBox(width: 5),
          GestureDetector(
            onTap: () => _sendMessage("text"),
            child: CircleAvatar(
              backgroundColor: Color(0xFF075E54),
              child: Icon(_msgController.text.isEmpty ? Icons.mic : Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // رجسٹریشن اسکرین
  Widget _buildRegistration() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("خوش آمدید! موبائل نمبر درج کریں", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              TextField(controller: _numController, keyboardType: TextInputType.phone, decoration: InputDecoration(hintText: "03XXXXXXXXX", border: OutlineInputBorder())),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_numController.text.length >= 10) {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setString('mobile_number', _numController.text);
                    _checkRegistration();
                  }
                },
                child: Text("آگے بڑھیں"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
