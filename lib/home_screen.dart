import 'package:flutter/material.dart';
import 'api_client.dart';

class HomeScreen extends StatefulWidget {
  final String phone;
  const HomeScreen({super.key, required this.phone});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiClient _api = const ApiClient();

  bool _loading = true;
  String? _error;

  String? _name;
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _api.getUserByPhone(phone: widget.phone);
      final user = (data['user'] is Map) ? (data['user'] as Map) : {};
      setState(() {
        _name = user['name']?.toString();
        _role = user['role']?.toString();
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home'), centerTitle: true),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : _error != null
                ? Text(_error!, style: const TextStyle(color: Colors.red))
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _name == null ? 'Welcome' : 'Welcome, $_name',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text('Role: ${_role ?? 'buyer'}'),
                      const SizedBox(height: 8),
                      Text('Phone: ${widget.phone}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUser,
                        child: const Text('Reload From DB'),
                      )
                    ],
                  ),
      ),
    );
  }
}