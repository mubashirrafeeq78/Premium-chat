import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'dart:async';
import 'dart:io';

class ChatGroupScreen extends StatefulWidget {
  @override
  _ChatGroupScreenState createState() => _ChatGroupScreenState();
}

class _ChatGroupScreenState extends State<ChatGroupScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final ImagePicker _picker = ImagePicker();
  
  bool _isRecording = false;
  bool _isTyping = false;
  Map<String, dynamic>? _replyingTo;
  int _recordDuration = 0;
  Timer? _timer;

  List<Map<String, dynamic>> _messages = [
    {"id": "1", "user": "System", "text": "خوش آمدید! مسائل شرعیہ گروپ میں آپ کا خیر مقدم ہے۔", "isMe": false, "type": "text", "time": "10:00 AM"},
  ];

  // فوٹو یا ویڈیو سینڈ کرنے کی لاجک
  Future<void> _pickMedia(ImageSource source, {bool isVideo = false}) async {
    final XFile? file = isVideo 
        ? await _picker.pickVideo(source: source) 
        : await _picker.pickImage(source: source);

    if (file != null) {
      _addMessage(
        text: isVideo ? "🎥 Video" : "🖼️ Photo",
        type: isVideo ? "video" : "image",
        mediaPath: file.path,
      );
      Navigator.pop(context); // باٹم شیٹ بند کرنے کے لیے
    }
  }

  // وائس ریکارڈنگ شروع کرنا
  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        setState(() {
          _isRecording = true;
          _recordDuration = 0;
        });
        _timer = Timer.periodic(Duration(seconds: 1), (t) => setState(() => _recordDuration++));
        await _audioRecorder.start(const RecordConfig(), path: 'recording.m4a');
      }
    } catch (e) {
      print(e);
    }
  }

  // وائس ریکارڈنگ روکنا اور سینڈ کرنا
  Future<void> _stopRecording() async {
    _timer?.cancel();
    final path = await _audioRecorder.stop();
    setState(() => _isRecording = false);

    if (path != null) {
      _addMessage(text: "🎤 Voice Message", type: "voice", mediaPath: path);
    }
  }

  void _addMessage({required String text, required String type, String? mediaPath}) {
    setState(() {
      _messages.add({
        "id": DateTime.now().toString(),
        "user": "You",
        "text": text,
        "isMe": true,
        "type": type,
        "mediaPath": mediaPath,
        "time": "${DateTime.now().hour}:${DateTime.now().minute}",
        "replyTo": _replyingTo,
      });
      _replyingTo = null;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Timer(Duration(milliseconds: 100), () {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F5F5), Color(0xFFE0F7FA), Color(0xFFFFE0B2)],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 45),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                itemCount: _messages.length,
                itemBuilder: (context, index) => _buildMessageBubble(_messages[index]),
              ),
            ),
            if (_replyingTo != null) _buildReplyPreview(),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    bool isMe = msg['isMe'];
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? Color(0xFFDCF8C6) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
        ),
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(msg['user'], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF075E54))),
            if (msg['type'] == 'image') 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(msg['mediaPath']))),
              ),
            Text(msg['text'], style: TextStyle(fontSize: 15)),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(msg['time'], style: TextStyle(fontSize: 10, color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.all(10),
      color: Color(0xFFF0F0F0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
              child: Row(
                children: [
                  IconButton(icon: Icon(Icons.attach_file, color: Color(0xFF667781)), onPressed: _showMediaOptions),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onChanged: (v) => setState(() => _isTyping = v.isNotEmpty),
                      decoration: InputDecoration(
                        hintText: _isRecording ? "Recording... ${_recordDuration}s" : "Type a message...",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onLongPress: _startRecording,
            onLongPressUp: _stopRecording,
            onTap: _isTyping ? () {
              _addMessage(text: _messageController.text, type: "text");
              _messageController.clear();
              setState(() => _isTyping = false);
            } : null,
            child: CircleAvatar(
              radius: 25,
              backgroundColor: _isRecording ? Colors.red : Color(0xFF25D366),
              child: Icon(_isTyping ? Icons.send : Icons.mic, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showMediaOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 150,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _mediaAction(Icons.image, "Gallery", () => _pickMedia(ImageSource.gallery)),
            _mediaAction(Icons.camera_alt, "Camera", () => _pickMedia(ImageSource.camera)),
            _mediaAction(Icons.videocam, "Video", () => _pickMedia(ImageSource.camera, isVideo: true)),
          ],
        ),
      ),
    );
  }

  Widget _mediaAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 25, backgroundColor: Color(0xFF075E54), child: Icon(icon, color: Colors.white)),
          SizedBox(height: 5),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildReplyPreview() { /* پچھلا ریپلائی ڈیزائن یہاں آئے گا */ return SizedBox(); }
}
