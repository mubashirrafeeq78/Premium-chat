
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<_NavItem> _items = const [
    _NavItem(icon: Icons.chat_bubble_outline, label: 'Chats'),
    _NavItem(icon: Icons.call, label: 'Call History'),
    _NavItem(icon: Icons.attach_money, label: 'My Spending'),
    _NavItem(icon: Icons.notifications_none, label: 'Notification'),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    const gradientColors = [
      Color(0xFFE0F7FA),
      Color(0xFFC8E6C9),
      Color(0xFFFFF9C4),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Icon(Icons.menu, color: Colors.black87),
        title: const Text(
          'Chats',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: const [
          Icon(Icons.notifications_none, color: Colors.black87),
          SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Text(
            'Chats Content Goes Here',
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    const Color activeGreen = Color(0xFF00C853);

    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          final bool isSelected = index == _selectedIndex;
          final bool isCenter = index == 2;

          Color iconColor;
          Color textColor;

          if (isSelected) {
            iconColor = activeGreen;
            textColor = activeGreen;
          } else if (isCenter) {
            iconColor = Colors.black;
            textColor = Colors.black;
          } else {
            iconColor = Colors.grey.shade600;
            textColor = Colors.grey.shade600;
          }

          return _NavButton(
            icon: item.icon,
            label: item.label,
            iconColor: iconColor,
            textColor: textColor,
            onTap: () => _onItemTapped(index),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color textColor;
  final VoidCallback onTap;

  const _NavButton({
    super.key,
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 22),
            Text(label, style: TextStyle(fontSize: 11, color: textColor)),
          ],
        ),
      ),
    );
  }
}
