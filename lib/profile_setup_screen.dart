import 'package:flutter/material.dart';
import 'api_client.dart';
import 'home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String phone;

  const ProfileSetupScreen({super.key, required this.phone});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final ApiClient _api = const ApiClient();

  final TextEditingController _name = TextEditingController();
  String _role = 'buyer'; // buyer | provider

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Name is required');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _api.upsertProfile(
        phone: widget.phone,
        role: _role,
        name: name,
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
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Phone: ${widget.phone}',
                style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 16),

            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _role,
              items: const [
                DropdownMenuItem(value: 'buyer', child: Text('Buyer User')),
                DropdownMenuItem(value: 'provider', child: Text('Provider User')),
              ],
              onChanged: (v) => setState(() => _role = v ?? 'buyer'),
              decoration: const InputDecoration(
                labelText: 'Account Type',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save & Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}