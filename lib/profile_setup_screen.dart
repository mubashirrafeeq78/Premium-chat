import 'dart:io';
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
  final _api = ApiClient();
  final _nameController = TextEditingController();

  String _role = 'buyer'; // buyer/provider
  bool _loading = false;

  File? _profileImage;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 70);
      if (picked == null) return;

      setState(() => _profileImage = File(picked.path));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image pick failed: $e')),
      );
    }
  }

  Future<void> _saveAndContinue() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name required')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      // ابھی avatarUrl null رکھ رہے ہیں (بعد میں upload API بنائیں گے)
      await _api.saveProfile(
        phone: widget.phone,
        role: _role,
        name: name,
        avatarUrl: null,
      );

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Profile Setup'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: _card(),
          ),
        ),
      ),
    );
  }

  Widget _card() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 18, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Phone: ${widget.phone}',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),

          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null
                      ? const Icon(Icons.person, size: 44, color: Colors.black54)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: () => _showPickSheet(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF00C853),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          const Text('Full Name', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Enter your name',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),

          const SizedBox(height: 16),

          const Text('Account Type', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _roleChip(
                  title: 'Buyer',
                  value: 'buyer',
                  selected: _role == 'buyer',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _roleChip(
                  title: 'Provider',
                  value: 'provider',
                  selected: _role == 'provider',
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _loading ? null : _saveAndContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C853),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _loading ? 'Saving...' : 'Continue',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleChip({
    required String title,
    required String value,
    required bool selected,
  }) {
    return InkWell(
      onTap: () => setState(() => _role = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? const Color(0xFF00C853) : Colors.grey.shade300, width: 2),
          color: selected ? const Color(0xFFE8F5E9) : Colors.white,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: selected ? const Color(0xFF00C853) : Colors.black87,
          ),
        ),
      ),
    );
  }

  void _showPickSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }
}