// lib/profile_setup_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'api_client.dart';
import 'home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String phone;

  const ProfileSetupScreen({super.key, required this.phone});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _api = const ApiClient();
  final _nameCtrl = TextEditingController();
  final _aboutCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  String _role = 'buyer'; // buyer | provider
  bool _loading = false;
  String? _error;

  final _picker = ImagePicker();
  Uint8List? _avatarBytes;
  Uint8List? _cnicFrontBytes;
  Uint8List? _cnicBackBytes;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _aboutCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage({
    required bool fromCamera,
    required void Function(Uint8List bytes) onBytes,
  }) async {
    final x = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 70, // ✅ basic compression
      maxWidth: 1024,
    );
    if (x == null) return;
    final bytes = await x.readAsBytes();
    onBytes(bytes);
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Name ضروری ہے');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // ابھی images DB میں نہیں ڈال رہے (Performance کیلئے)
      await _api.saveProfile(
        phone: widget.phone,
        role: _role,
        name: name,
        about: _aboutCtrl.text.trim().isEmpty ? null : _aboutCtrl.text.trim(),
        city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(phone: widget.phone),
        ),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Setup'),
        backgroundColor: const Color(0xFF00C853),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _topCard(),
            const SizedBox(height: 14),
            _formCard(),
            const SizedBox(height: 14),
            if (_error != null) _errorBox(_error!),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Save & Continue',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: Colors.grey.shade200,
            backgroundImage:
                _avatarBytes == null ? null : MemoryImage(_avatarBytes!),
            child: _avatarBytes == null
                ? const Icon(Icons.person, size: 38, color: Colors.black54)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Setup your profile',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Phone: ${widget.phone}',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _loading
                          ? null
                          : () => _pickImage(
                                fromCamera: false,
                                onBytes: (b) => _avatarBytes = b,
                              ),
                      icon: const Icon(Icons.photo),
                      label: const Text('Avatar'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _loading
                          ? null
                          : () => _pickImage(
                                fromCamera: true,
                                onBytes: (b) => _avatarBytes = b,
                              ),
                      icon: const Icon(Icons.photo_camera),
                      label: const Text('Camera'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _formCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Account Type', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('Buyer'),
                  selected: _role == 'buyer',
                  onSelected: _loading ? null : (_) => setState(() => _role = 'buyer'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Provider'),
                  selected: _role == 'provider',
                  onSelected: _loading ? null : (_) => setState(() => _role = 'provider'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cityCtrl,
            decoration: const InputDecoration(
              labelText: 'City (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _aboutCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'About (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          const Text('CNIC (Front/Back)', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _docBox(
                  title: 'Front',
                  bytes: _cnicFrontBytes,
                  onGallery: _loading
                      ? null
                      : () => _pickImage(fromCamera: false, onBytes: (b) => _cnicFrontBytes = b),
                  onCamera: _loading
                      ? null
                      : () => _pickImage(fromCamera: true, onBytes: (b) => _cnicFrontBytes = b),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _docBox(
                  title: 'Back',
                  bytes: _cnicBackBytes,
                  onGallery: _loading
                      ? null
                      : () => _pickImage(fromCamera: false, onBytes: (b) => _cnicBackBytes = b),
                  onCamera: _loading
                      ? null
                      : () => _pickImage(fromCamera: true, onBytes: (b) => _cnicBackBytes = b),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'نوٹ: ابھی CNIC images server پر upload نہیں ہو رہیں (بعد میں storage + URLs).',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _docBox({
    required String title,
    required Uint8List? bytes,
    required VoidCallback? onGallery,
    required VoidCallback? onCamera,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Container(
            height: 86,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              image: bytes == null
                  ? null
                  : DecorationImage(image: MemoryImage(bytes), fit: BoxFit.cover),
            ),
            child: bytes == null
                ? const Icon(Icons.credit_card, size: 34, color: Colors.black45)
                : null,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onGallery,
                  child: const Text('Gallery'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: onCamera,
                  child: const Text('Camera'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _errorBox(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Text(
        msg,
        style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.w700),
      ),
    );
  }
}