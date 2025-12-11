import 'package:flutter/material.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _nameError;
  bool _isProvider = false; // false = buyer, true = provider

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // پورا بی جی گرینٹ
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
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
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
          const SizedBox(height: 25),

          // پروفائل پِکچر
          GestureDetector(
            onTap: () {
              // TODO: یہاں بعد میں image picker جوڑ سکتے ہیں
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile picture upload coming soon'),
                ),
              );
            },
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
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
                  child: const ClipOval(
                    child: Image(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        'https://via.placeholder.com/90?text=Pic',
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

          // نام والا ان پٹ
          TextField(
            controller: _nameController,
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

          // یوزر ٹائپ بٹن
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
                  label: "I’m a Service buyer",
                  icon: Icons.handshake,
                  selected: !_isProvider,
                  onTap: () {
                    setState(() => _isProvider = false);
                  },
                ),
              ),
            ],
          ),

          // پرووائیڈر اپ لوڈ سیکشن
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

          // فائنل بٹن
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _onSubmit,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 8,
                backgroundColor: Colors.green,
              ).copyWith(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.disabled)) {
                    return const Color(0xFFBDBDBD);
                  }
                  // اصل ڈیزائن کی طرح گرین گرینٹ
                  return null;
                }),
              ),
              child: Ink(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00C853), Color(0xFF00E676)],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
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
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 15),

        // تین کارڈز
        Column(
          children: [
            _buildUploadCard(
              icon: Icons.credit_card,
              title: 'CNIC Front Side',
              subtitle: '(Tap to take Live Photo)',
            ),
            const SizedBox(height: 15),
            _buildUploadCard(
              icon: Icons.credit_card,
              title: 'CNIC Back Side',
              subtitle: '(Tap to take Live Photo)',
            ),
            const SizedBox(height: 15),
            _buildUploadCard(
              icon: Icons.camera_alt,
              title: 'Live Selfie',
              subtitle: '(Tap to take Live Photo)',
              circularPreview: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUploadCard({
    required IconData icon,
    required String title,
    required String subtitle,
    bool circularPreview = false,
  }) {
    return GestureDetector(
      onTap: () {
        // TODO: یہاں camera / image picker لگا سکتے ہیں
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title upload coming soon')),
        );
      },
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
            const SizedBox(height: 6),
            // Placeholder preview frame (ڈیزائن کے لئے)
            if (!circularPreview)
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                  color: const Color(0xFFF9F9F9),
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

    if (_nameError != null) return;

    // یہاں آپ اپنی اصل لاجک لگائیں (API, DB وغیرہ)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isProvider
              ? 'Profile submitted for review!'
              : 'Profile completed, going to app...',
        ),
      ),
    );
  }
}
