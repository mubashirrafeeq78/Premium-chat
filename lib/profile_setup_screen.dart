import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 0 = Chats, 1 = Call History, 2 = My Spending, 3 = Notification
  int _selectedIndex = 0;

  // You asked: center button name in code must be "Add contact"
  static const String addContactName = 'Add contact';

  static const List<Color> _bgGradient = [
    Color(0xFFE0F7FA),
    Color(0xFFC8E6C9),
    Color(0xFFFFF9C4),
  ];

  static const Color _activeGreen = Color(0xFF00C853);

  void _onTabTap(int index) => setState(() => _selectedIndex = index);

  void _onAddContactTap() {
    // Design only for now
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add contact (design only)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const _AppDrawer(),
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
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
            colors: _bgGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Text(
            'Chats Content Goes Here',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      ),

      // Center button (always colored) + notch in bottom bar
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _AddContactFab(
        semanticName: addContactName,
        onTap: _onAddContactTap,
      ),

      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 12,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _BottomTab(
                icon: Icons.chat_bubble_outline,
                label: 'Chats',
                selected: _selectedIndex == 0,
                onTap: () => _onTabTap(0),
              ),
              _BottomTab(
                icon: Icons.call,
                label: 'Call History',
                selected: _selectedIndex == 1,
                onTap: () => _onTabTap(1),
              ),

              // Space for center FAB
              const SizedBox(width: 72),

              _BottomTab(
                icon: Icons.attach_money,
                label: 'My Spending',
                selected: _selectedIndex == 2,
                onTap: () => _onTabTap(2),
              ),
              _BottomTab(
                icon: Icons.notifications_none,
                label: 'Notification',
                selected: _selectedIndex == 3,
                onTap: () => _onTabTap(3),
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
    final Color color = selected ? const Color(0xFF00C853) : Colors.grey.shade600;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
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
  final String semanticName; // "Add contact"
  final VoidCallback onTap;

  const _AddContactFab({
    required this.semanticName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticName,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, 8),
              ),
            ],
            // Looks like your screenshot (green → yellow-ish)
            gradient: const LinearGradient(
              colors: [Color(0xFF00C853), Color(0xFFFFEB3B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 6),
              ),
              child: const Icon(
                Icons.person_add_alt_1,
                color: Colors.white,
                size: 30,
              ),
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
            // Header (blue like screenshot)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
              decoration: const BoxDecoration(
                color: Color(0xFF3F51B5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      color: Colors.white.withOpacity(0.25),
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 46),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Mubashir 4',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.edit, color: Color(0xFFFFC107), size: 22),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '03222222222',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Account Type: CONSUMER',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            _DrawerTile(
              icon: Icons.attach_money,
              title: 'My Spending',
              onTap: () => Navigator.pop(context),
            ),
            _DrawerTile(
              icon: Icons.refresh,
              title: 'Check update',
              onTap: () => Navigator.pop(context),
            ),
            _DrawerTile(
              icon: Icons.support_agent,
              title: 'Help sports',
              onTap: () => Navigator.pop(context),
            ),
            _DrawerTile(
              icon: Icons.settings,
              title: 'App Settings',
              onTap: () => Navigator.pop(context),
            ),
            _DrawerTile(
              icon: Icons.info_outline,
              title: 'About App',
              onTap: () => Navigator.pop(context),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Log Out (design only)')),
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
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

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF3F51B5)),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }
}
