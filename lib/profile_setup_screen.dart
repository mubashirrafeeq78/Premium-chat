import 'dart:io';

import 'package:flutter/material.dart'; import 'package:image_picker/image_picker.dart';

// ProfileSetupScreen // - Allows picking profile picture (camera or gallery) // - Allows taking live camera photos for CNIC front, CNIC back and Live Selfie // - Keeps everything in-memory (no backend). Screen refresh will clear data. // - Optimized for low-memory / slow networks: images are captured/compressed via image_picker options. // - Button is disabled until required fields are filled.

class ProfileSetupScreen extends StatefulWidget { const ProfileSetupScreen({Key? key}) : super(key: key);

@override State<ProfileSetupScreen> createState() => _ProfileSetupScreenState(); }

class _ProfileSetupScreenState extends State<ProfileSetupScreen> { final TextEditingController _nameController = TextEditingController(); final ImagePicker _picker = ImagePicker();

// In-memory files (will be null until user picks/takes photos) XFile? _profileImage; XFile? _cnicFront; XFile? _cnicBack; XFile? _liveSelfie;

String? _nameError; bool _isProvider = false; // false = buyer, true = provider bool _submitting = false;

@override void dispose() { _nameController.dispose(); super.dispose(); }

// Helper: picks image from camera or gallery with lightweight settings Future<XFile?> _pickImage({required ImageSource source, bool fromCamera = false}) async { try { // imageQuality and maxWidth ensure smaller memory footprint final XFile? file = await _picker.pickImage( source: source, imageQuality: 70, // compress quality (0-100). Good compromise for low-net & low-RAM devices maxWidth: 1024, // limit dimensions maxHeight: 1024, ); return file; } catch (e) { // If permission denied or other error, show a small message if (mounted) { ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Failed to get image: ${e.toString()}')), ); } return null; } }

// Public pickers used by UI Future<void> pickProfileImage() async { showModalBottomSheet( context: context, builder: () => SafeArea( child: Column( mainAxisSize: MainAxisSize.min, children: [ ListTile( leading: const Icon(Icons.camera_alt), title: const Text('Take photo'), onTap: () async { Navigator.pop(context); final file = await _pickImage(source: ImageSource.camera, fromCamera: true); if (file != null) setState(() => _profileImage = file); }, ), ListTile( leading: const Icon(Icons.photo_library), title: const Text('Choose from gallery'), onTap: () async { Navigator.pop(context); final file = await _pickImage(source: ImageSource.gallery); if (file != null) setState(() => _profileImage = file); }, ), ], ), ), ); }

Future<void> _captureCnicFront() async { final file = await _pickImage(source: ImageSource.camera, fromCamera: true); if (file != null) setState(() => _cnicFront = file); }

Future<void> _captureCnicBack() async { final file = await _pickImage(source: ImageSource.camera, fromCamera: true); if (file != null) setState(() => _cnicBack = file); }

Future<void> _captureLiveSelfie() async { final file = await _pickImage(source: ImageSource.camera, fromCamera: true); if (file != null) setState(() => _liveSelfie = file); }

bool get _isFormValid { final hasName = _nameController.text.trim().isNotEmpty; final hasProfile = _profileImage != null; if (!_isProvider) { // Buyer: require name + profile picture return hasName && hasProfile; } // Provider: require name + profile + cnic front/back + live selfie return hasName && hasProfile && _cnicFront != null && _cnicBack != null && _liveSelfie != null; }

void _onSubmit() { setState(() { _nameError = _nameController.text.trim().isEmpty ? 'Name is required' : null; });

if (!_isFormValid) return;

// Front-end only: show a success snackbar and clear (simulate refresh) after short delay
setState(() => _submitting = true);
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(_isProvider ? 'Profile submitted for review' : 'Profile completed')),
);

// Simulate brief processing then clear form (since there is no backend)
Future.delayed(const Duration(milliseconds: 700), () {
  if (!mounted) return;
  setState(() {
    _nameController.clear();
    _profileImage = null;
    _cnicFront = null;
    _cnicBack = null;
    _liveSelfie = null;
    _isProvider = false;
    _submitting = false;
  });
});

}

Widget _filePreview(XFile? file, {double size = 90, bool circular = false, String placeholder = ''}) { if (file == null) { return Container( width: size, height: size, decoration: BoxDecoration( color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(circular ? size / 2 : 6), border: Border.all(color: const Color(0xFFEEEEEE)), ), child: Center( child: Text( placeholder, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF90A4AE)), ), ), ); }

return ClipRRect(
  borderRadius: BorderRadius.circular(circular ? size / 2 : 6),
  child: Image.file(
    File(file.path),
    width: size,
    height: size,
    fit: BoxFit.cover,
  ),
);

}

@override Widget build(BuildContext context) { return Scaffold( body: Container( decoration: const BoxDecoration( gradient: LinearGradient( colors: [Color(0xFFE0F7FA), Color(0xFFC8E6C9), Color(0xFFFFF9C4)], begin: Alignment.topLeft, end: Alignment.bottomRight, ), ), alignment: Alignment.center, padding: const EdgeInsets.symmetric(vertical: 20), child: SingleChildScrollView( child: Center( child: ConstrainedBox( constraints: const BoxConstraints(maxWidth: 420), child: Container( width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24), decoration: BoxDecoration( gradient: const LinearGradient( colors: [Colors.white, Color(0xFFF0F0F0)], begin: Alignment.topLeft, end: Alignment.bottomRight, ), borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 24, offset: Offset(0, 8))], ), child: Column( mainAxisSize: MainAxisSize.min, children: [ const Text('👤 Profile Setup', style: TextStyle(color: Color(0xFF3F51B5), fontSize: 22, fontWeight: FontWeight.w700)), const SizedBox(height: 8), const Text('Complete your profile and choose your user type.', style: TextStyle(color: Color(0xFF90A4AE), fontSize: 13)), const SizedBox(height: 18),

// Profile picture row (preview + action)
                GestureDetector(
                  onTap: _pickProfileImage,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _filePreview(_profileImage, size: 90, circular: true, placeholder: 'Upload\nProfile'),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Upload Profile Picture', style: TextStyle(color: Color(0xFF3F51B5), fontSize: 14, fontWeight: FontWeight.w600)),
                          SizedBox(height: 6),
                          Text('Tap to choose or take photo', style: TextStyle(fontSize: 12, color: Color(0xFF90A4AE))),
                        ],
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Name field
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Profile Name',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCFD8DC))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCFD8DC))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF3F51B5))),
                    errorText: _nameError,
                  ),
                  onChanged: (_) => setState(() {}),
                ),

                const SizedBox(height: 14),

                // Type buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildTypeButton(label: "I'm a Service Provider", icon: Icons.handyman, selected: _isProvider, onTap: () => setState(() => _isProvider = true)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTypeButton(label: "I'm a Service Buyer", icon: Icons.handshake, selected: !_isProvider, onTap: () => setState(() => _isProvider = false)),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Provider uploads
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  crossFadeState: _isProvider ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                  firstChild: _buildProviderUploadsWidget(),
                  secondChild: const SizedBox.shrink(),
                ),

                const SizedBox(height: 18),

                // Submit button - grey until valid
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isFormValid && !_submitting ? _onSubmit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFormValid ? Colors.green : const Color(0xFFBDBDBD),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 6,
                    ),
                    child: Text(
                      _isProvider ? 'Submit for Review' : 'Go To Application',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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

Widget _buildTypeButton({required String label, required IconData icon, required bool selected, required VoidCallback onTap}) { final borderColor = selected ? const Color(0xFF3F51B5) : const Color(0xFFCFD8DC); final bgColor = selected ? const Color(0xFFE8EAF6) : const Color(0xFFF7F7F7); final textColor = selected ? const Color(0xFF3F51B5) : const Color(0xFF333333);

return GestureDetector(
  onTap: onTap,
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 150),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10), border: Border.all(color: borderColor, width: 2)),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 16, color: textColor), const SizedBox(width: 6), Flexible(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor), textAlign: TextAlign.center))]),
  ),
);

}

Widget _buildProviderUploadsWidget() { return Column( children: [ const SizedBox(height: 6), const Text('Live Verification (Mandatory for Provider)', style: TextStyle(color: Color(0xFF3F51B5), fontSize: 13)), const SizedBox(height: 12),

// CNIC Front
    _buildUploadCard(
      title: 'CNIC Front Side',
      subtitle: '(Tap to take Live Photo)',
      file: _cnicFront,
      onTap: _captureCnicFront,
    ),
    const SizedBox(height: 12),

    // CNIC Back
    _buildUploadCard(
      title: 'CNIC Back Side',
      subtitle: '(Tap to take Live Photo)',
      file: _cnicBack,
      onTap: _captureCnicBack,
    ),
    const SizedBox(height: 12),

    // Live Selfie
    _buildUploadCard(
      title: 'Live Selfie',
      subtitle: '(Tap to take Live Photo)',
      file: _liveSelfie,
      onTap: _captureLiveSelfie,
      circularPreview: true,
    ),
  ],
);

}

Widget _buildUploadCard({required String title, required String subtitle, XFile? file, required VoidCallback onTap, bool circularPreview = false}) { return GestureDetector( onTap: onTap, child: Container( width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white, border: Border.all(color: const Color(0xFFBDBDBD)), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]), child: Column( children: [ Icon(Icons.credit_card, size: 28, color: const Color(0xFF3F51B5)), const SizedBox(height: 6), Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF616161))), Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF90A4AE))), const SizedBox(height: 8), circularPreview ? _filePreview(file, size: 90, circular: true, placeholder: 'Live\nSelfie') : _filePreview(file, size: 140, circular: false, placeholder: 'Preview here'), ], ), ), ); } }
