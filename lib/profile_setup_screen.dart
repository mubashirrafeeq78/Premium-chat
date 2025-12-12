import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _nameError;
  bool _isProvider = false;

  Uint8List? _profileImage;
  Uint8List? _cnicFrontImage;
  Uint8List? _cnicBackImage;
  Uint8List? _selfieImage;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    final hasName = _nameController.text.trim().isNotEmpty;
    final hasProfile = _profileImage != null;

    if (!hasName || !hasProfile) return false;

    if (_isProvider) {
      return _cnicFrontImage != null &&
          _cnicBackImage != null &&
          _selfieImage != null;
    }

    return true;
  }

  Future<void> _pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 70,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        if (!mounted) return;
        setState(() {
          _profileImage = bytes;
        });
      }
    } catch (_) {
      _showError('Failed to pick profile picture');
    }
  }

  Future<void> _captureCnicFront() async {
    await _captureFromCamera(
      thenSaveTo: (bytes) => _cnicFrontImage = bytes,
      errorMessage: 'Failed to capture CNIC front side',
    );
  }

  Future<void> _captureCnicBack() async {
    await _captureFromCamera(
      thenSaveTo: (bytes) => _cnicBackImage = bytes,
      errorMessage: 'Failed to capture CNIC back side',
    );
  }

  Future<void> _captureSelfie() async {
    await _captureFromCamera(
      thenSaveTo: (bytes) => _selfieImage = bytes,
      errorMessage: 'Failed to capture selfie',
    );
  }

  Future<void> _captureFromCamera({
    required void Function(Uint8List bytes) thenSaveTo,
    required String errorMessage,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        imageQuality: 70,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        if (!mounted) return;
        setState(() {
          thenSaveTo(bytes);
        });
      }
    } catch (_) {
      _showError(errorMessage);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE0F7FA),
              Color(0xFFC8E6C9),
              Color(0xFFFFF9C4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: _buildCard(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white, // plain white card, no extra gradient bands
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '👤 Profile Setup',
            style: TextStyle(
              color: Color(0xFF3F51B5),
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          const Text(
            'Complete your profile and choose your user type.',
            style: TextStyle(
              color: Color(0xFF90A4AE),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          GestureDetector(
            onTap: _pickProfileImage,
            child: Column(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFCFD8DC),
                      width: 3,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _profileImage != null
                        ? Image.memory(
                            _profileImage!,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: const Color(0xFFE0E0E0),
                            child: const Icon(
                              Icons.person,
                              size: 40,
                              color: Color(0xFF9E9E9E),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Upload Profile Picture',
                  style: TextStyle(
                    color: Color(0xFF3F51B5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: _nameController,
            onChanged: (_) {
              setState(() {
                if (_nameController.text.trim().isEmpty) {
                  _nameError = 'Name is required';
                } else {
                  _nameError = null;
                }
              });
            },
            decoration: InputDecoration(
              hintText: 'Profile Name',
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFCFD8DC)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFCFD8DC)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF3F51B5)),
              ),
              errorText: _nameError,
            ),
          ),
          const SizedBox(height: 5),
          if (_nameError != null)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Name is required',
                style: TextStyle(
                  color: Color(0xFFFF5252),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: _buildTypeButton(
                  label: "I’m a Service Provider",
                  icon: Icons.handyman,
                  selected: _isProvider,
                  onTap: () {
                    setState(() => _isProvider = true);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTypeButton(
                  label: "I’m a Service Buyer",
                  icon: Icons.handshake,
                  selected: !_isProvider,
                  onTap: () {
                    setState(() => _isProvider = false);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _isProvider
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: _buildProviderUploads(),
            secondChild: const SizedBox.shrink(),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isFormValid ? _onSubmit : null,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: _isFormValid ? 8 : 0,
                backgroundColor:
                    _isFormValid ? Colors.transparent : const Color(0xFFBDBDBD),
                foregroundColor: Colors.white,
                shadowColor:
                    _isFormValid ? Colors.black26 : Colors.transparent,
              ),
              child: _isFormValid
                  ? Ink(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF00C853), Color(0xFF00E676)],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Center(
                        child: Text(
                          _isProvider
                              ? 'Submit for Review'
                              : 'Go To Application',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : const Center(
                      child: Text(
                        'Complete Profile First',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final Color borderColor =
        selected ? const Color(0xFF3F51B5) : const Color(0xFFCFD8DC);
    final Color bgColor =
        selected ? const Color(0xFFE8EAF6) : const Color(0xFFF7F7F7);
    final Color textColor =
        selected ? const Color(0xFF3F51B5) : const Color(0xFF333333);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color.fromARGB(77, 63, 81, 181),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderUploads() {
    return Column(
      children: [
        const SizedBox(height: 10),
        const Text(
          'Live Verification (Mandatory for Provider)',
          style: TextStyle(
            color: Color(0xFF3F51B5),
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 15),
        _buildUploadCard(
          icon: Icons.credit_card,
          title: 'CNIC Front Side',
          subtitle: '(Tap to take live photo)',
          image: _cnicFrontImage,
          circularPreview: false,
          onTap: _captureCnicFront,
        ),
        const SizedBox(height: 15),
        _buildUploadCard(
          icon: Icons.credit_card,
          title: 'CNIC Back Side',
          subtitle: '(Tap to take live photo)',
          image: _cnicBackImage,
          circularPreview: false,
          onTap: _captureCnicBack,
        ),
        const SizedBox(height: 15),
        _buildUploadCard(
          icon: Icons.camera_alt,
          title: 'Live Selfie',
          subtitle: '(Tap to take live photo)',
          image: _selfieImage,
          circularPreview: true,
          onTap: _captureSelfie,
        ),
      ],
    );
  }

  Widget _buildUploadCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Uint8List? image,
    bool circularPreview = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFBDBDBD), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: const Color(0xFF3F51B5),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF616161),
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF90A4AE),
              ),
            ),
            const SizedBox(height: 8),
            if (!circularPreview)
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                  color: const Color(0xFFF9F9F9),
                ),
                child: image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.memory(
                          image,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Center(
                        child: Text(
                          'No image captured',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFFB0BEC5),
                          ),
                        ),
                      ),
              )
            else
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF00C853),
                    width: 4,
                  ),
                  color: const Color(0xFFF9F9F9),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(77, 0, 200, 83),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: image != null
                      ? Image.memory(
                          image,
                          fit: BoxFit.cover,
                        )
                      : const Center(
                          child: Icon(
                            Icons.person,
                            size: 30,
                            color: Color(0xFFB0BEC5),
                          ),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onSubmit() {
    setState(() {
      if (_nameController.text.trim().isEmpty) {
        _nameError = 'Name is required';
      } else {
        _nameError = null;
      }
    });

    if (!_isFormValid) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isProvider
              ? 'Profile submitted for review!'
              : 'Profile completed, going to app...',
        ),
      ),
    );

    // Redirect to home screen (define /home route in main.dart).
    Navigator.of(context).pushReplacementNamed('/home');
  }
}
