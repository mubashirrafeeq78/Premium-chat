import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// Buyer Home Screen (Design Only)
class _HomeScreenState extends State<HomeScreen> {
  // 0 = Chats, 1 = Call History, 2 = My Spending, 3 = Notification
  int _selectedIndex = 0;

  // IMPORTANT: Center action name (as you requested)
  static const String centerActionName = 'AddContact';

  static const Color activeGreen = Color(0xFF00C853);

  static const List<Color> _bgGradient = [
    Color(0xFFE0F7FA),
    Color(0xFFC8E6C9),
    Color(0xFFFFF9C4),
  ];

  void _onTapTab(int index) => setState(() => _selectedIndex = index);

  void _onAddContact() {
    // TODO: later you will tell which screen to open
    // For now: design only
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Contact (Design only)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      drawer: const _AppDrawer(), // ✅ Left drawer design

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
            onPressed: () {
              // TODO later
            },
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
        child: _buildBody(),
      ),

      // ✅ Center button ALWAYS original color (not grey)
      floatingActionButton: _AddContactFab(
        onTap: _onAddContact,
        semanticName: centerActionName, // code-name
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    // Design only — later you will tell which tab shows what
    return const Center(
      child: Text(
        'Chats Content Goes Here',
        style: TextStyle(
          fontSize: 16,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      color: Colors.white,
      elevation: 12,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.chat_bubble_outline объяс,
              label: 'Chats',
              selected: _selectedIndex == 0,
              onTap: () => _onTapTab(0),
            ),
            _NavItem(
              icon: Icons.call,
              label: 'Call History',
              selected: _selectedIndex == 1,
              onTap: () => _onTapTab(1),
            ),

            // space for FAB
            const SizedBox(width: 56),

            _NavItem(
              icon: Icons.attach_money,
              label: 'My Spending',
              selected: _selectedIndex == 2,
              onTap: () => _onTapTab(2),
              // not selected => grey (like screenshot)
            ),
            _NavItem(
              icon: Icons.notifications_none,
              label: 'Notification',
              selected: _selectedIndex == 3,
              onTap: () => _onTapTab(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = selected ? _HomeScreenState.activeGreen : Colors.grey.shade600;

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

/// ✅ Center FAB: always colored (green), name in code = AddContact
class _AddContactFab extends StatelessWidget {
  final VoidCallback onTap;
  final String semanticName;

  const _AddContactFab({
    required this.onTap,
    required this.semanticName,
  });

  @override
  Widget build(BuildContext context) {
    // Circle with soft gradient feel (looks like screenshot vibe)
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

/// ✅ Left Drawer (Design only) — like your screenshot
class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header (blue)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              decoration: const BoxDecoration(
                color: Color(0xFF3F51B5),
              ),
              child: Column(
                children: [
                  // avatar
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: const Center(
                      child: Icon(Icons.person, color: Colors.white, size: 44),
                    ),
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
                      Icon(Icons.edit, color: Colors.amber, size: 22),
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

            // Menu items
            _DrawerItem(
              icon: Icons.attach_money,
              title: 'My Spending',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _DrawerItem(
              icon: Icons.refresh,
              title: 'Check update',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _DrawerItem(
              icon: Icons.support_agent,
              title: 'Help sports',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _DrawerItem(
              icon: Icons.settings,
              title: 'App Settings',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _DrawerItem(
              icon: Icons.info_outline,
              title: 'About App',
              onTap: () {
                Navigator.pop(context);
              },
            ),

            const Spacer(),

            // Logout button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Design only
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logout (Design only)')),
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

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
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
