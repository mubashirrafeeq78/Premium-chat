import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Required for File

// Note: For this code to work, you must have the 'image_picker' package
// added to your pubspec.yaml file and run 'flutter pub get'.
// Also, ensure you have set up the necessary platform permissions (iOS/Android)
// for camera and gallery access.

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  // --- State Variables for Data ---
  final TextEditingController _nameController = TextEditingController();
  String? _nameError;
  bool _isProvider = false; // false = buyer, true = provider

  // --- State Variables for Image Files ---
  File? _profileImageFile;
  File? _cnicFrontFile;
  File? _cnicBackFile;

  // --- Utility for Image Picking ---
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Listen to name changes to update button state
    _nameController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // --- Core Logic: Check if Submission is Ready ---
  bool get _isSubmissionReady {
    final bool nameValid = _nameController.text.trim().isNotEmpty;

    if (_isProvider) {
      // Provider requires Name, Profile Pic, CNIC Front, and CNIC Back
      return nameValid &&
          _profileImageFile != null &&
          _cnicFrontFile != null &&
          _cnicBackFile != null;
    } else {
      // Buyer only requires Name
      return nameValid;
    }
  }

  // --- Method to Trigger State Update ---
  void _updateButtonState() {
    // Calling setState() with no arguments forces the widget to rebuild,
    // which updates the button's enabled/disabled state based on _isSubmissionReady.
    // This is efficient as it only rebuilds the necessary widgets (like the button).
    setState(() {
      // This empty setState block is necessary to trigger the rebuild
    });
  }

  // --- Method for Picking Images ---
  Future<void> _pickImage(
      {required ImageSource source, required Function(File) onFilePicked}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800, // Optimize image size for performance
        imageQuality: 75, // Reduce quality for faster network transmission later
      );

      if (pickedFile != null) {
        onFilePicked(File(pickedFile.path));
        _updateButtonState(); // Update button state after picking a required image
      }
    } catch (e) {
      // Handle permission errors or other exceptions
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  // --- Submission Handler ---
  void _onSubmit() {
    setState(() {
      if (_nameController.text.trim().isEmpty) {
        _nameError = 'Name is required';
      } else {
        _nameError = null;
      }
    });

    if (!_isSubmissionReady) {
      // Should not happen if button is disabled correctly, but good for safety
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields.')),
      );
      return;
    }

    // --- Actual Logic Placeholder ---
    // In a real app, you would upload files to the server here.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isProvider
              ? 'Profile data and images collected. Submitting for review...'
              : 'Profile data collected. Going to application...',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Full background gradient container
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE0F7FA), // Light Cyan
              Color(0xFFC8E6C9), // Light Green
              Color(0xFFFFF9C4), // Light Yellow
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: SingleChildScrollView(
          // For better performance on low-end devices, use minimal padding/decoration
          // within the SingleChildScrollView and keep image sizes optimized.
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: _buildCard(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF0F0F0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
              color: Color(0xFF3F51B5), // Indigo
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          const Text(
            'Complete your profile and choose your user type.',
            style: TextStyle(
              color: Color(0xFF90A4AE), // Blue Grey
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),

          // --- Profile Picture Upload ---
          GestureDetector(
            onTap: () => _pickImage(
              source: ImageSource.gallery,
              onFilePicked: (file) => setState(() => _profileImageFile = file),
            ),
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _profileImageFile != null
                          ? const Color(0xFF00C853) // Green for uploaded
                          : const Color(0xFFCFD8DC), // Light Grey
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
                    child: _profileImageFile != null
                        ? Image.file(
                            _profileImageFile!,
                            fit: BoxFit.cover,
                            cacheHeight: 180, // Optimized for smooth display
                            cacheWidth: 180,
                          )
                        : const Image(
                            fit: BoxFit.cover,
                            image: NetworkImage(
                              'https://via.placeholder.com/90?text=Pic',
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _profileImageFile != null
                      ? 'Change Profile Picture'
                      : 'Upload Profile Picture',
                  style: const TextStyle(
                    color: Color(0xFF3F51B5),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // --- Name Input Field ---
          TextField(
            controller: _nameController,
            onChanged: (value) => _updateButtonState(), // Call update on text change
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
          const SizedBox(height: 15),

          // --- User Type Selector Buttons ---
          Row(
            children: [
              Expanded(
                child: _buildTypeButton(
                  label: "I’m a Service Provider",
                  icon: Icons.handyman,
                  selected: _isProvider,
                  onTap: () {
                    setState(() => _isProvider = true);
                    _updateButtonState(); // Update state when type changes
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTypeButton(
                  label: "I’m a Service buyer",
                  icon: Icons.handshake,
                  selected: !_isProvider,
                  onTap: () {
                    setState(() => _isProvider = false);
                    _updateButtonState(); // Update state when type changes
                  },
                ),
              ),
            ],
          ),

          // --- Provider Upload Section (Animated Visibility) ---
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

          // --- Final Submission Button ---
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSubmissionReady ? _onSubmit : null, // Disabled if not ready
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 8,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: _isSubmissionReady
                      ? const LinearGradient(
                          colors: [Color(0xFF00C853), Color(0xFF00E676)], // Green Gradient
                        )
                      : null, // No gradient when disabled
                  color: _isSubmissionReady ? null : const Color(0xFFBDBDBD), // Grey when disabled
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Center(
                  child: Text(
                    _isProvider ? 'Submit for Review' : 'Go To Application',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 15),

        // CNIC Front Side
        _buildUploadCard(
          icon: Icons.credit_card,
          title: 'CNIC Front Side',
          subtitle: '(Tap to take Live Photo)',
          file: _cnicFrontFile,
          onTap: () => _pickImage(
            source: ImageSource.camera, // Live camera for CNIC
            onFilePicked: (file) => setState(() => _cnicFrontFile = file),
          ),
        ),
        const SizedBox(height: 15),

        // CNIC Back Side
        _buildUploadCard(
          icon: Icons.credit_card,
          title: 'CNIC Back Side',
          subtitle: '(Tap to take Live Photo)',
          file: _cnicBackFile,
          onTap: () => _pickImage(
            source: ImageSource.camera, // Live camera for CNIC
            onFilePicked: (file) => setState(() => _cnicBackFile = file),
          ),
        ),
        const SizedBox(height: 15),

        // Live Selfie
        _buildUploadCard(
          icon: Icons.camera_alt,
          title: 'Live Selfie',
          subtitle: '(Tap to take Live Photo)',
          circularPreview: true,
          file: _profileImageFile, // Reusing profile pic variable for consistency
          onTap: () => _pickImage(
            source: ImageSource.camera, // Live camera for Selfie
            onFilePicked: (file) => setState(() => _profileImageFile = file),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    File? file,
    bool circularPreview = false,
  }) {
    final bool uploaded = file != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: uploaded ? const Color(0xFF00C853) : const Color(0xFFBDBDBD),
              width: uploaded ? 3 : 1),
          boxShadow: [
            BoxShadow(
              color: uploaded ? const Color.fromARGB(77, 0, 200, 83) : Colors.black12,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: uploaded ? const Color(0xFF00C853) : const Color(0xFF3F51B5),
            ),
            const SizedBox(height: 5),
            Text(
              uploaded ? '$title (Uploaded)' : title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: uploaded ? const Color(0xFF00C853) : const Color(0xFF616161),
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF90A4AE),
              ),
            ),
            const SizedBox(height: 10),
            // Dynamic Preview
            if (uploaded)
              _buildFilePreview(file!, circularPreview)
            else
              // Placeholder Preview
              circularPreview
                  ? Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFEEEEEE),
                          width: 4,
                        ),
                        color: const Color(0xFFF9F9F9),
                      ),
                      child: const Center(
                        child: Icon(Icons.add_a_photo,
                            color: Color(0xFFBDBDBD), size: 30),
                      ),
                    )
                  : Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                        color: const Color(0xFFF9F9F9),
                      ),
                      child: const Center(
                        child: Icon(Icons.add_a_photo,
                            color: Color(0xFFBDBDBD), size: 30),
                      ),
                    ),
          ],
        ),
      ),
    );
  }

  // Helper method for image preview
  Widget _buildFilePreview(File file, bool circular) {
    // Using a ClipOval or ClipRRect for better performance and aesthetic
    final imageWidget = Image.file(
      file,
      fit: BoxFit.cover,
      cacheHeight: 200, // Optimize file size for display
      cacheWidth: circular ? 200 : 800,
    );

    return circular
        ? Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF00C853),
                width: 4,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(77, 0, 200, 83),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(child: imageWidget),
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Container(
              height: 100,
              width: double.infinity,
              child: imageWidget,
            ),
          );
  }
}
