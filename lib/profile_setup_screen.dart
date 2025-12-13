import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _picker = ImagePicker();

  bool _isProvider = false;

  Uint8List? _profileBytes;
  Uint8List? _cnicFrontBytes;
  Uint8List? _cnicBackBytes;
  Uint8List? _selfieBytes;

  String? _nameError;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isNameValid => _nameController.text.trim().isNotEmpty;

  bool get _isReadyToSubmit {
    if (!_isNameValid) return false;
    if (_profileBytes == null) return false;

    if (_isProvider) {
      return _cnicFrontBytes != null &&
          _cnicBackBytes != null &&
          _selfieBytes != null;
    }
    return true;
  }

  Future<void> _pickFromGallery({
    required void Function(Uint8List bytes) onPicked,
  }) async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1200,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    onPicked(bytes);
  }

  Future<void> _captureFromCamera({
    required void Function(Uint8List bytes) onCaptured,
    bool useFrontCamera = false,
  }) async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice:
          useFrontCamera ? CameraDevice.front : CameraDevice.rear,
      imageQuality: 70,
      maxWidth: 1200,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    onCaptured(bytes);
  }

  void _validateName() {
    setState(() {
      _nameError = _isNameValid ? null : 'Name is required';
    });
  }

  void _onSubmit() {
    _validateName();
    if (!_isReadyToSubmit) return;

    if (_isProvider) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile submitted for review!')),
      );
      return;
    }

    Navigator.pushReplacementNamed(context, '/home');
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 380),
                      child: _buildCard(context),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF6F6F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 22,
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
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'Complete your profile and choose your user type.',
            style: TextStyle(
              color: Color(0xFF90A4AE),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),

          _buildProfilePicker(),
          const SizedBox(height: 18),

          _buildNameField(),
          const SizedBox(height: 14),

          _buildUserTypeRow(),
          const SizedBox(height: 10),

          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState:
                _isProvider ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: _buildProviderSection(),
            secondChild: const SizedBox.shrink(),
          ),

          const SizedBox(height: 18),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildProfilePicker() {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            await showModalBottomSheet(
              context: context,
              builder: (_) => _PickSheet(
                onCamera: () async {
                  Navigator.pop(context);
                  await _captureFromCamera(
                    onCaptured: (b) => setState(() => _profileBytes = b),
                  );
                },
                onGallery: () async {
                  Navigator.pop(context);
                  await _pickFromGallery(
                    onPicked: (b) => setState(() => _profileBytes = b),
                  );
                },
              ),
            );
          },
          child: Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFCFD8DC), width: 3),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
              ],
            ),
            child: ClipOval(
              child: _profileBytes == null
                  ? Container(
                      color: const Color(0xFFF3F3F3),
                      child: const Icon(Icons.person, size: 44, color: Color(0xFF90A4AE)),
                    )
                  : Image.memory(_profileBytes!, fit: BoxFit.cover),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Upload Profile Picture',
          style: TextStyle(
            color: Color(0xFF3F51B5),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextField(
      controller: _nameController,
      onChanged: (_) {
        _validateName();
        setState(() {});
      },
      decoration: InputDecoration(
        hintText: 'Profile Name',
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCFD8DC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCFD8DC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3F51B5), width: 2),
        ),
        errorText: _nameError,
      ),
    );
  }

  Widget _buildUserTypeRow() {
    return Row(
      children: [
        Expanded(
          child: _TypeButton(
            label: "I'm a Service Provider",
            icon: Icons.handyman,
            selected: _isProvider,
            onTap: () => setState(() => _isProvider = true),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _TypeButton(
            label: "I'm a Service Buyer",
            icon: Icons.handshake,
            selected: !_isProvider,
            onTap: () => setState(() => _isProvider = false),
          ),
        ),
      ],
    );
  }

  Widget _buildProviderSection() {
    return Column(
      children: [
        const SizedBox(height: 6),
        const Text(
          'Live Verification (Mandatory for Provider)',
          style: TextStyle(
            color: Color(0xFF3F51B5),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),

        _UploadCard(
          title: 'CNIC Front Side',
          subtitle: 'Tap to take live photo',
          bytes: _cnicFrontBytes,
          onTap: () async {
            await _captureFromCamera(
              onCaptured: (b) => setState(() => _cnicFrontBytes = b),
            );
          },
        ),
        const SizedBox(height: 12),
        _UploadCard(
          title: 'CNIC Back Side',
          subtitle: 'Tap to take live photo',
          bytes: _cnicBackBytes,
          onTap: () async {
            await _captureFromCamera(
              onCaptured: (b) => setState(() => _cnicBackBytes = b),
            );
          },
        ),
        const SizedBox(height: 12),
        _UploadCard(
          title: 'Live Selfie',
          subtitle: 'Tap to take live photo',
          bytes: _selfieBytes,
          circularPreview: true,
          onTap: () async {
            await _captureFromCamera(
              useFrontCamera: true,
              onCaptured: (b) => setState(() => _selfieBytes = b),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isReadyToSubmit ? _onSubmit : null,
        style: ElevatedButton.styleFrom(
          elevation: 8,
          backgroundColor: _isReadyToSubmit ? const Color(0xFF00C853) : const Color(0xFFBDBDBD),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          _isProvider ? 'Submit for Review' : 'Go To Application',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? const Color(0xFF3F51B5) : const Color(0xFFCFD8DC);
    final bgColor = selected ? const Color(0xFFE8EAF6) : const Color(0xFFF7F7F7);
    final textColor = selected ? const Color(0xFF3F51B5) : const Color(0xFF333333);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
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
}

class _UploadCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Uint8List? bytes;
  final bool circularPreview;
  final VoidCallback onTap;

  const _UploadCard({
    required this.title,
    required this.subtitle,
    required this.bytes,
    required this.onTap,
    this.circularPreview = false,
  });

  @override
  Widget build(BuildContext context) {
    final preview = bytes == null
        ? null
        : ClipRRect(
            borderRadius: circularPreview ? BorderRadius.circular(999) : BorderRadius.circular(10),
            child: Image.memory(bytes!, fit: BoxFit.cover),
          );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBDBDBD), width: 2),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          children: [
            Icon(
              circularPreview ? Icons.camera_alt : Icons.credit_card,
              size: 28,
              color: const Color(0xFF3F51B5),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF616161),
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10.5, color: Color(0xFF90A4AE)),
            ),
            const SizedBox(height: 10),
            if (!circularPreview)
              Container(
                height: 110,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                  color: const Color(0xFFF9F9F9),
                ),
                child: preview ?? const SizedBox.shrink(),
              )
            else
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF00C853), width: 4),
                  color: const Color(0xFFF9F9F9),
                ),
                clipBehavior: Clip.antiAlias,
                child: preview ?? const Icon(Icons.person, color: Color(0xFF90A4AE), size: 40),
              ),
          ],
        ),
      ),
    );
  }
}

class _PickSheet extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  const _PickSheet({required this.onCamera, required this.onGallery});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 14),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: onCamera,
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: onGallery,
            ),
          ],
        ),
      ),
    );
  }
} 
