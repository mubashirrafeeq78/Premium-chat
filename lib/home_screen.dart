import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 0 = Chats, 1 = Call History, 2 = My Spending, 3 = Notification
  int _selectedIndex = 0;

  static const String centerActionName = 'AddContact';
  static const Color activeGreen = Color(0xFF00C853);

  static const List<Color> bgGradient = [
    Color(0xFFE0F7FA),
    Color(0xFFC8E6C9),
    Color(0xFFFFF9C4),
  ];

  void _onTapTab(int index) => setState(() => _selectedIndex = index);

  void _onAddContact() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Contact (design only)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: const _AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Chats',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: bgGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Text(
            'Home Content Goes Here',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _AddContactFab(
        onTap: _onAddContact,
        semanticName: centerActionName,
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 12,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _BottomTab(
                icon: Icons.chat_bubble_outline,
                label: 'Chats',
                selected: _selectedIndex == 0,
                onTap: () => _onTapTab(0),
              ),
              _BottomTab(
                icon: Icons.call,
                label: 'Call History',
                selected: _selectedIndex == 1,
                onTap: () => _onTapTab(1),
              ),
              const SizedBox(width: 56),
              _BottomTab(
                icon: Icons.attach_money,
                label: 'My Spending',
                selected: _selectedIndex == 2,
                onTap: () => _onTapTab(2),
              ),
              _BottomTab(
                icon: Icons.notifications_none,
                label: 'Notification',
                selected: _selectedIndex == 3,
                onTap: () => _onTapTab(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BottomTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color color =
        selected ? _HomeScreenState.activeGreen : Colors.grey.shade600;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddContactFab extends StatelessWidget {
  final VoidCallback onTap;
  final String semanticName;

  const _AddContactFab({
    required this.onTap,
    required this.semanticName,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticName,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 66,
          height: 66,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 6),
              ),
            ],
            gradient: const LinearGradient(
              colors: [Color(0xFF00C853), Color(0xFF00E676)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.person_add_alt_1,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              color: const Color(0xFF3F51B5),
              child: Column(
                children: const [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, color: Colors.white, size: 44),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Premium Chat',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text('Account Type: USER', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            _DrawerItem(icon: Icons.attach_money, title: 'My Spending'),
            _DrawerItem(icon: Icons.refresh, title: 'Check update'),
            _DrawerItem(icon: Icons.support_agent, title: 'Help support'),
            _DrawerItem(icon: Icons.settings, title: 'App Settings'),
            _DrawerItem(icon: Icons.info_outline, title: 'About App'),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Log Out'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const _DrawerItem({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF3F51B5)),
      title: Text(title),
      onTap: () => Navigator.pop(context),
    );
  }
}