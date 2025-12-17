// lib/home_screen.dart
import 'package:flutter/material.dart';
import 'api_client.dart';

class HomeScreen extends StatefulWidget {
  final String phone;
  const HomeScreen({super.key, required this.phone});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = const ApiClient();
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchHome(phone: widget.phone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: const Color(0xFF00C853),
        actions: [
          IconButton(
            onPressed: () =>
                setState(() => _future = _api.fetchHome(phone: widget.phone)),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return _errorView(snap.error.toString());
          }

          final data = snap.data ?? const {};
          final user = (data['user'] is Map)
              ? Map<String, dynamic>.from(data['user'])
              : <String, dynamic>{};

          final role = (user['role'] ?? 'buyer').toString();
          final name = (user['name'] ?? '').toString();
          final city = (user['city'] ?? '').toString();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? 'Welcome 👋' : 'Welcome, $name 👋',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('Phone: ${widget.phone}'),
                    const SizedBox(height: 4),
                    Text('Role: $role'),
                    if (city.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('City: $city'),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Loaded from DB',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Text('API: ${ApiClient.baseUrl}'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Next (Professional)',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Text(
                      role == 'provider'
                          ? 'Provider: services/pricing/availability (DB)'
                          : 'Buyer: requests/orders/chats (DB)',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Images بعد میں storage پر upload ہوں گی اور DB میں صرف URL save ہوگا (fast & low load).',
                      style: TextStyle(
                          color: Colors.grey.shade700, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: child,
    );
  }

  Widget _errorView(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 44),
            const SizedBox(height: 10),
            Text(msg, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () =>
                  setState(() => _future = _api.fetchHome(phone: widget.phone)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}