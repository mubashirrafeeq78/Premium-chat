import 'package:flutter/material.dart';
import 'api_service.dart';

class HomeScreen extends StatefulWidget {
  final String phone;
  const HomeScreen({super.key, required this.phone});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool loading = true;
  String? error;
  Map<String, dynamic>? me;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final r = await ApiService.getMe(widget.phone);
      if (r["success"] == true) {
        setState(() => me = r);
      } else {
        setState(() => error = r["message"]?.toString() ?? "Failed");
      }
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = me?["user"];
    final profile = me?["profile"];

    return Scaffold(
      appBar: AppBar(
        title: const Text("PremiumChat"),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Phone: ${user?["phone"] ?? ""}", style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text("Role: ${user?["role"] ?? ""}"),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Profile (Loaded from DB)", style: TextStyle(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 10),
                            Text("Name: ${profile?["name"] ?? "-"}"),
                            if (user?["role"] == "provider") ...[
                              const SizedBox(height: 6),
                              Text("Status: ${profile?["verification_status"] ?? "pending"}"),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        "Next Step: اب ہم services / listings / categories وغیرہ کا DB backend کریں گے۔",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
    );
  }
}