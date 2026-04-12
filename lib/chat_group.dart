import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'config.dart';

class ChatGroupPage extends StatefulWidget {
  @override
  _ChatGroupPageState createState() => _ChatGroupPageState();
}

class _ChatGroupPageState extends State<ChatGroupPage> {
  final TextEditingController _msgController = TextEditingController();
  List _messages = [];
  String _myNumber = "";
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUser();
    // ہر 2 سیکنڈ بعد چیٹ اپڈیٹ کرنے کے لیے
    Stream.periodic(Duration(seconds: 2)).listen((_) => _fetchMessages());
  }

  _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() { _myNumber = prefs.getString('mobile_number') ?? "03000000000"; });
  }

  // میسج لوڈ کرنا
  _fetchMessages() async {
    var res = await Config.send("load_msg", {});
    if (res != null && res['status'] == 'success') {
      setState(() { _messages = res['data']; });
    }
  }

  // میسج بھیجنے کی لاجک
  _send(String type, {String? content, String? url}) async {
    if (type == 'text' && _msgController.text.isEmpty) return;
    
    var data = {
      "mobile_number": _myNumber,
      "content": content ?? _msgController.text,
      "media_url": url ?? "",
      "media_type": type
    };

    var res = await Config.send("save_msg", data);
    if (res['status'] == 'success') {
      _msgController.clear();
      _fetchMessages(); // فوری لوڈ کریں
    }
  }

  // کیمرہ یا گیلری سے تصویر لینا
  _pickMedia(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      // یہاں آپ کو فائل اپلوڈ کرنے کی ضرورت ہوگی، فی الحال ہم صرف لنک بھیج رہے ہیں
      _send("image", url: "https://paxochat.com/uploads/${image.name}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF075E54),
        title: const Text("مسائل شرعیہ", style: TextStyle(color: Colors.white)),
        actions: [const Icon(Icons.more_vert, color: Colors.white), const SizedBox(width: 10)],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFE5DDD5), // واٹس ایپ والا کلاسک رنگ
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
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

  Widget _buildBubble(var m, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFDCF8C6) : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (m['media_type'] == 'text') Text(m['content']),
            if (m['media_type'] == 'image') Image.network(m['media_url'], width: 200),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("10:48", style: TextStyle(fontSize: 10, color: Colors.grey)),
                if (isMe) const SizedBox(width: 5),
                if (isMe) const Icon(Icons.done_all, size: 15, color: Colors.blue), // نیلے ٹک
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
              child: Row(
                children: [
                  const Icon(Icons.emoji_emotions_outlined, color: Colors.grey),
                  const SizedBox(width: 5),
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      onChanged: (v) => setState(() {}),
                      decoration: const InputDecoration(hintText: "میسج لکھیں...", border: InputBorder.none),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.attach_file, color: Colors.grey), onPressed: () => _pickMedia(ImageSource.gallery)),
                  IconButton(icon: const Icon(Icons.camera_alt, color: Colors.grey), onPressed: () => _pickMedia(ImageSource.camera)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: () => _send("text"),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF075E54),
              child: Icon(_msgController.text.isEmpty ? Icons.mic : Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
