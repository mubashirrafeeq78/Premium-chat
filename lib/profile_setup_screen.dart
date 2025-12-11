import 'dart:io';

import 'package:flutter/foundation.dart'; import 'package:flutter/material.dart'; import 'package:image_picker/image_picker.dart';

// A clean, memory-friendly front-end only Profile Setup screen. // - Uses image_picker to take/select images. // - Reduces image size (maxWidth/maxHeight, imageQuality) for low-RAM and slow networks. // - No backend/database: all data is in-memory and will be lost on refresh as requested. // - Submit button stays disabled (grey) until name + profile + cnic front + cnic back are provided.

class ProfileSetupScreen extends StatefulWidget { const ProfileSetupScreen({super.key});

@override State<ProfileSetupScreen> createState() => _ProfileSetupScreenState(); }

class _ProfileSetupScreenState extends State<ProfileSetupScreen> { final TextEditingController _nameController = TextEditingController(); final ImagePicker _picker = ImagePicker();

XFile? _profileImage; XFile? _cnicFront; XFile? _cnicBack;

bool _isProvider = false; // false = buyer, true = provider

bool get _isFormValid { return _nameController.text.trim().isNotEmpty && _profileImage != null && _cnicFront != null && _cnicBack != null; }

// Pick or capture an image with camera/gallery. // We use reduced resolution and quality to keep memory & upload small. Future<XFile?> _pickImage({required ImageSource source}) async { try { final XFile? file = await _picker.pickImage( source: source, maxWidth: 1200, // reduce to limit memory usage maxHeight: 1200, imageQuality: 70, // 0-100, lower keeps file small for slow networks ); return file; } catch (e) { // In case of errors (permissions, available cameras, etc.) return null if (kDebugMode) print('Image pick error: $e'); return null; } }

Future<void> _onPickProfilePicture() async { final XFile? file = await showModalBottomSheet<XFile?>( context: context, builder: (ctx) => _ImageSourceSheet(onPick: (src) async { final result = await _pickImage(source: src); Navigator.of(ctx).pop(result); }), );

if (file != null) {
  setState(() => _profileImage = file);
}

}

Future<void> _onCaptureCnic({required bool isFront}) async { // For "live" capture we open the camera directly. final XFile? file = await _pickImage(source: ImageSource.camera); if (file != null) { setState(() { if (isFront) { _cnicFront = file; } else { _cnicBack = file; } }); } }

void _onSubmit() { if (!_isFormValid) return;

// Front-end only: show success and clear screen (simulate refresh)
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Profile submitted (front-end only).')),
);

// Reset everything to simulate a full refresh (data lost as requested)
setState(() {
  _nameController.clear();
  _profileImage = null;
  _cnicFront = null;
  _cnicBack = null;
  _isProvider = false;
});

}

@override void dispose() { _nameController.dispose(); super.dispose(); }

Widget _imagePreview(XFile? file, {double size = 90, bool circular = false}) { if (file == null) { return Container( width: size, height: size, decoration: BoxDecoration( color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(circular ? size / 2 : 8), border: Border.all(color: const Color(0xFFDDDDDD)), ), child: Icon( Icons.image, size: size * 0.4, color: const Color(0xFF9E9E9E), ), ); }

// Use Image.file for local preview; keep BoxFit.cover to avoid large memory peak.
return ClipRRect(
  borderRadius: BorderRadius.circular(circular ? size / 2 : 8),
  child: Image.file(
    File(file.path),
    width: size,
    height: size,
    fit: BoxFit.cover,
  ),
);

}

@override Widget build(BuildContext context) { return Scaffold( body: Container( decoration: const BoxDecoration( gradient: LinearGradient( colors: [Color(0xFFE0F7FA), Color(0xFFC8E6C9), Color(0xFFFFF9C4)], begin: Alignment.topLeft, end: Alignment.bottomRight, ), ), alignment: Alignment.center, padding: const EdgeInsets.symmetric(vertical: 20), child: SingleChildScrollView( child: Center( child: ConstrainedBox( constraints: const BoxConstraints(maxWidth: 420), // keep usable on tablets child: Container( width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20), decoration: BoxDecoration( gradient: const LinearGradient( colors: [Colors.white, Color(0xFFF0F0F0)], ), borderRadius: BorderRadius.circular(16), boxShadow: const [ BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 8)) ], ), child: Column( mainAxisSize: MainAxisSize.min, children: [ const Text('Profile Setup', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF3F51B5))), const SizedBox(height: 8), const Text('Provide name, profile picture and CNIC images', style: TextStyle(fontSize: 13, color: Color(0xFF90A4AE))), const SizedBox(height: 18),

// Profile image picker
                GestureDetector(
                  onTap: _onPickProfilePicture,
                  child: Column(
                    children: [
                      _imagePreview(_profileImage, size: 100, circular: true),
                      const SizedBox(height: 8),
                      const Text('Upload Profile Picture', style: TextStyle(color: Color(0xFF3F51B5))),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Name input
                TextField(
                  controller: _nameController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Profile Name',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFCFD8DC))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF3F51B5))),
                  ),
                ),

                const SizedBox(height: 16),

                // User Type buttons
                Row(
                  children: [
                    Expanded(
                      child: _typeButton(
                          label: 'I\'m a Service Provider',
                          icon: Icons.handyman,
                          selected: _isProvider,
                          onTap: () => setState(() => _isProvider = true)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _typeButton(
                          label: 'I\'m a Service Buyer',
                          icon: Icons.handshake,
                          selected: !_isProvider,
                          onTap: () => setState(() => _isProvider = false)),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Provider-only uploads (show when provider)
                AnimatedCrossFade(
                  firstChild: _providerUploadSection(),
                  secondChild: const SizedBox.shrink(),
                  crossFadeState: _isProvider ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 180),
                ),

                const SizedBox(height: 20),

                // Submit button: grey when disabled, green when enabled
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: GestureDetector(
                    onTap: _isFormValid ? _onSubmit : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: _isFormValid
                            ? const LinearGradient(colors: [Color(0xFF00C853), Color(0xFF00E676)])
                            : null,
                        color: _isFormValid ? null : const Color(0xFFBDBDBD),
                        boxShadow: _isFormValid
                            ? const [
                                BoxShadow(color: Color.fromARGB(50, 0, 200, 83), blurRadius: 8, offset: Offset(0, 4))
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          _isProvider ? 'Submit for Review' : 'Go To Application',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
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

Widget _typeButton({required String label, required IconData icon, required bool selected, required VoidCallback onTap}) { final Color borderColor = selected ? const Color(0xFF3F51B5) : const Color(0xFFCFD8DC); final Color bgColor = selected ? const Color(0xFFE8EAF6) : const Color(0xFFF7F7F7); final Color textColor = selected ? const Color(0xFF3F51B5) : const Color(0xFF333333);

return GestureDetector(
  onTap: onTap,
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 150),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: borderColor, width: 2),
    ),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 16, color: textColor), const SizedBox(width: 6), Flexible(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor), textAlign: TextAlign.center))]),
  ),
);

}

Widget _providerUploadSection() { return Column( children: [ const SizedBox(height: 6), const Text('Live Verification (Mandatory for Provider)', style: TextStyle(color: Color(0xFF3F51B5))), const SizedBox(height: 12),

// CNIC front
    _uploadCard(
      title: 'CNIC Front Side',
      subtitle: 'Tap to take live photo',
      preview: _cnicFront,
      onTapCamera: () => _onCaptureCnic(isFront: true),
      onTapGallery: () async {
        final XFile? file = await _pickImage(source: ImageSource.gallery);
        if (file != null) setState(() => _cnicFront = file);
      },
    ),

    const SizedBox(height: 12),

    // CNIC back
    _uploadCard(
      title: 'CNIC Back Side',
      subtitle: 'Tap to take live photo',
      preview: _cnicBack,
      onTapCamera: () => _onCaptureCnic(isFront: false),
      onTapGallery: () async {
        final XFile? file = await _pickImage(source: ImageSource.gallery);
        if (file != null) setState(() => _cnicBack = file);
      },
    ),

    const SizedBox(height: 12),

    // (Optional) live selfie preview - here we reuse profile image as selfie if user chooses
    Row(children: [Expanded(child: Container())]),
  ],
);

}

Widget _uploadCard({required String title, required String subtitle, required XFile? preview, required VoidCallback onTapCamera, required VoidCallback onTapGallery}) { return Container( width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFBDBDBD)), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]), child: Column( crossAxisAlignment: CrossAxisAlignment.center, children: [ Row(mainAxisAlignment: MainAxisAlignment.center, children: [ _imagePreview(preview, size: 100, circular: false), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 6), Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF90A4AE)))])) ]), const SizedBox(height: 10), Row(mainAxisAlignment: MainAxisAlignment.center, children: [ ElevatedButton.icon( onPressed: onTapCamera, icon: const Icon(Icons.camera_alt), label: const Text('Camera'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F51B5)), ), const SizedBox(width: 10), OutlinedButton.icon( onPressed: onTapGallery, icon: const Icon(Icons.photo_library), label: const Text('Gallery'), ), ]) ], ), ); } }

// Small bottom sheet to pick camera or gallery for profile picture class _ImageSourceSheet extends StatelessWidget { final Future<void> Function(ImageSource) onPick;

const _ImageSourceSheet({required this.onPick});

@override Widget build(BuildContext context) { return SafeArea( child: Column(mainAxisSize: MainAxisSize.min, children: [ ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Take Photo'), onTap: () => onPick(ImageSource.camera)), ListTile(leading: const Icon(Icons.photo_library), title: const Text('Choose From Gallery'), onTap: () => onPick(ImageSource.gallery)), const SizedBox(height: 8), ]), ); } }
