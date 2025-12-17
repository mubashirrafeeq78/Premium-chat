import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

import 'api_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String phone; // OTP verify کے بعد phone پاس کریں
  const ProfileSetupScreen({super.key, required this.phone});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameCtrl = TextEditingController();

  bool isProvider = false;

  Uint8List? avatarBytes;
  Uint8List? cnicFrontBytes;
  Uint8List? cnicBackBytes;
  Uint8List? selfieBytes;

  bool saving = false;
  String? errorText;

  final picker = ImagePicker();

  // ---------- Image helpers (low bandwidth) ----------
  Future<Uint8List?> _pickImage({required bool camera, ImageSource? forceSource}) async {
    final source = forceSource ?? (camera ? ImageSource.camera : ImageSource.gallery);
    final XFile? f = await picker.pickImage(source: source, imageQuality: 85);
    if (f == null) return null;
    final raw = await f.readAsBytes();
    return _compressToJpeg(raw, maxWidth: 900, quality: 65);
  }

  Uint8List _compressToJpeg(Uint8List input, {required int maxWidth, required int quality}) {
    final decoded = img.decodeImage(input);
    if (decoded == null) return input;

    final resized = decoded.width > maxWidth
        ? img.copyResize(decoded, width: maxWidth)
        : decoded;

    final jpg = img.encodeJpg(resized, quality: quality);
    return Uint8List.fromList(jpg);
  }

  String? _toBase64(Uint8List? bytes) => bytes == null ? null : base64Encode(bytes);

  // ---------- UI cards ----------
  Widget _uploadCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Uint8List? bytes,
    required VoidCallback onTap,
    bool circular = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 4),
              color: Colors.black.withOpacity(0.06),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 34, color: const Color(0xFF3F51B5)),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            const SizedBox(height: 10),
            if (bytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(circular ? 999 : 10),
                child: Image.memory(
                  bytes,
                  height: circular ? 90 : 110,
                  width: circular ? 90 : double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() {
      errorText = null;
      saving = true;
    });

    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() {
        saving = false;
        errorText = "Profile name required";
      });
      return;
    }

    if (isProvider) {
      if (cnicFrontBytes == null || cnicBackBytes == null || selfieBytes == null) {
        setState(() {
          saving = false;
          errorText = "Provider کے لیے CNIC Front/Back اور Selfie لازمی ہے";
        });
        return;
      }
    }

    try {
      final resp = await ApiService.saveProfile(
        phone: widget.phone,
        role: isProvider ? "provider" : "buyer",
        name: name,
        avatarBase64: _toBase64(avatarBytes),
        cnicFrontBase64: _toBase64(cnicFrontBytes),
        cnicBackBase64: _toBase64(cnicBackBytes),
        selfieBase64: _toBase64(selfieBytes),
      );

      if (resp["success"] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resp["message"]?.toString() ?? "Saved")),
        );
        Navigator.pushReplacementNamed(context, '/home', arguments: {"phone": widget.phone});
      } else {
        setState(() {
          errorText = resp["message"]?.toString() ?? "Save failed";
        });
      }
    } catch (e) {
      setState(() {
        errorText = e.toString();
      });
    } finally {
      setState(() {
        saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFE0F7FA), Color(0xFFC8E6C9), Color(0xFFFFF9C4)],
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: bg),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              child: Container(
                width: 360,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0.94),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                      color: Colors.black.withOpacity(0.12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text("👤 Profile Setup",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF3F51B5))),
                    const SizedBox(height: 6),
                    Text("Complete your profile and choose your user type.",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    const SizedBox(height: 18),

                    // Avatar
                    GestureDetector(
                      onTap: () async {
                        final bytes = await _pickImage(camera: false);
                        if (bytes != null) setState(() => avatarBytes = bytes);
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 92,
                            height: 92,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade300, width: 3),
                              image: avatarBytes == null
                                  ? const DecorationImage(
                                      image: NetworkImage("https://via.placeholder.com/90?text=Pic"),
                                      fit: BoxFit.cover,
                                    )
                                  : DecorationImage(image: MemoryImage(avatarBytes!), fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text("Upload Profile Picture",
                              style: TextStyle(color: Color(0xFF3F51B5), fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Name
                    TextField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                        hintText: "Profile Name",
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),

                    if (errorText != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.withOpacity(0.35)),
                        ),
                        child: Text(errorText!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // User type buttons
                    Row(
                      children: [
                        Expanded(
                          child: _typeBtn(
                            selected: isProvider,
                            icon: Icons.build,
                            text: "I’m a Service Provider",
                            onTap: () => setState(() => isProvider = true),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _typeBtn(
                            selected: !isProvider,
                            icon: Icons.handshake,
                            text: "I’m a Service buyer",
                            onTap: () => setState(() => isProvider = false),
                          ),
                        ),
                      ],
                    ),

                    if (isProvider) ...[
                      const SizedBox(height: 18),
                      const Divider(),
                      const SizedBox(height: 10),
                      const Text("Live Verification (Mandatory for Provider)",
                          style: TextStyle(color: Color(0xFF3F51B5), fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 12),

                      _uploadCard(
                        title: "CNIC Front Side",
                        subtitle: "(Tap to take Live Photo)",
                        icon: Icons.badge,
                        bytes: cnicFrontBytes,
                        onTap: () async {
                          final bytes = await _pickImage(camera: true);
                          if (bytes != null) setState(() => cnicFrontBytes = bytes);
                        },
                      ),
                      const SizedBox(height: 12),
                      _uploadCard(
                        title: "CNIC Back Side",
                        subtitle: "(Tap to take Live Photo)",
                        icon: Icons.credit_card,
                        bytes: cnicBackBytes,
                        onTap: () async {
                          final bytes = await _pickImage(camera: true);
                          if (bytes != null) setState(() => cnicBackBytes = bytes);
                        },
                      ),
                      const SizedBox(height: 12),
                      _uploadCard(
                        title: "Live Selfie",
                        subtitle: "(Tap to take Live Photo)",
                        icon: Icons.camera_alt,
                        bytes: selfieBytes,
                        circular: true,
                        onTap: () async {
                          final bytes = await _pickImage(camera: true, forceSource: ImageSource.camera);
                          if (bytes != null) setState(() => selfieBytes = bytes);
                        },
                      ),
                    ],

                    const SizedBox(height: 18),

                    // Submit
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: saving ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFF00C853),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: saving
                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text(isProvider ? "Submit for Review" : "Go To Application",
                                style: const TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _typeBtn({
    required bool selected,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE8EAF6) : const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? const Color(0xFF3F51B5) : Colors.grey.shade300, width: 2),
          boxShadow: selected
              ? [BoxShadow(blurRadius: 10, offset: const Offset(0, 3), color: Colors.black.withOpacity(0.08))]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: selected ? const Color(0xFF3F51B5) : Colors.black87),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? const Color(0xFF3F51B5) : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}