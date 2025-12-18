import 'package:flutter/material.dart';
import 'api_client.dart';
import 'config.dart';
import 'models.dart';
import 'routes.dart';
import 'storage.dart';
import 'widgets.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _name = TextEditingController();
  final _api = ApiClient(baseUrl: AppConfig.baseUrl);

  String _role = "buyer"; // buyer/provider
  bool _loading = false;
  String _error = "";

  Future<void> _save() async {
    setState(() {
      _loading = true;
      _error = "";
    });

    try {
      final token = await AppStorage.getToken();
      final phone = await AppStorage.getPhone();
      if (token == null || token.isEmpty) throw Exception("Token missing. Login again.");
      if (phone == null || phone.isEmpty) throw Exception("Phone missing. Login again.");

      final name = _name.text.trim();
      if (name.isEmpty) {
        setState(() => _error = "Enter your name");
        return;
      }

      // avatarBase64 optional (kept empty in this minimal build)
      final j = await _api.postJson(
        "/profile/save",
        token: token,
        body: {"name": name, "role": _role, "avatarBase64": ""},
      );

      final user = UserModel.fromJson((j["user"] as Map<String, dynamic>));
      await AppStorage.saveUser(user);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Simple UI – آپ اپنا original design یہاں paste کر سکتے ہیں
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person, size: 56),
                  const SizedBox(height: 10),
                  const Text("Profile Setup", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  const Text("Complete your profile and choose your user type."),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _name,
                    decoration: const InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  ErrorBox(message: _error),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text("I'm a Service Provider"),
                          selected: _role == "provider",
                          onSelected: (_) => setState(() => _role = "provider"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text("I'm a Service Buyer"),
                          selected: _role == "buyer",
                          onSelected: (_) => setState(() => _role = "buyer"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    text: _loading ? "Saving..." : "Go To Application",
                    onPressed: _loading ? null : _save,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}