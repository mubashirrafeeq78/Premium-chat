import 'package:flutter/material.dart';

// اسکرین شاٹ کے مطابق Bottom Navigation Bar کے ساتھ نئی Chats Screen
class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  // 0 = Chats (Default/Selected as per screenshot)
  // 1 = Call History
  // 2 = My Session
  // 3 = Profile
  int _selectedIndex = 0; 

  // Bottom Navigation Bar Items کی تفصیلات
  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.chat_bubble, 'label': 'Chats', 'index': 0},
    {'icon': Icons.call, 'label': 'Call History', 'index': 1},
    {'icon': Icons.assignment, 'label': 'My Session', 'index': 2}, // Icons.assignment for 'My Session' is a guess
    {'icon': Icons.person, 'label': 'Profile', 'index': 3},
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // یہاں آپ مطلوبہ اسکرین پر نیویگیٹ کرنے کی لاجک شامل کر سکتے ہیں۔
    // فی الحال، صرف منتخب آئیکن کا رنگ تبدیل ہوگا۔
    print('Tapped on index $index: ${_navItems[index]['label']}');
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold میں مطلوبہ ڈیزائن لاگو کیا گیا ہے
    return Scaffold(
      appBar: AppBar(
        // نیویگیشن بار کے مطابق Menu آئیکن (☰)
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // TODO: Drawer یا Menu ایکشن
          },
        ),
        title: const Text('Chats'),
        centerTitle: true,
        // نیویگیشن بار کے مطابق Wallet/Folder آئیکن
        actions: [
          IconButton(
            icon: const Icon(Icons.folder), // Icons.folder is a guess for the yellow icon
            onPressed: () {
              // TODO: Wallet/Folder ایکشن
            },
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: Colors.white,
        elevation: 0, // اسکرین شاٹ میں کوئی شیڈو نہیں دکھایا گیا
      ),
      // اسکرین شاٹ کے مطابق درمیان میں خالی جگہ
      body: const Center(
        child: Text('Chats Content Goes Here'),
      ),
      
      // بڑا گرین بٹن (پلس آئیکن)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: نیا چیٹ شروع کرنے کا ایکشن
        },
        backgroundColor: Colors.green,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      // بٹن کو نیویگیشن بار کے اوپر لانے کے لیے
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      // Bottom Navigation Bar
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 10,
        height: 60,
        // ایک خالی جگہ چھوڑیں جہاں Floating Action Button فٹ ہو
        notchMargin: 6.0,
        shape: const CircularNotchedRectangle(), 
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _navItems.map((item) {
            // Chats اور Profile کے درمیان FloatingActionButton کی جگہ خالی کرنی ہوگی۔
            if (item['index'] == 2) {
               return const SizedBox(width: 40); // Floating Action Button کے لیے خالی جگہ
            }

            return _buildNavItem(
              icon: item['icon'],
              label: item['label'],
              isSelected: item['index'] == _selectedIndex,
              onTap: () => _onItemTapped(item['index']),
            );
          }).toList(),
        ),
      ),
    );
  }

  // نیویگیشن بار میں ایک آئٹم بنانے کے لیے مددگار ویجیٹ
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    // اسکرین شاٹ کے مطابق منتخب آئیکن گرین، غیر منتخب آئیکن گرے
    final Color color = isSelected ? Colors.green.shade700 : Colors.grey.shade600;

    return InkWell(
      onTap: onTap,
      // رنگین آئیکن پر خاص توجہ
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// اگر آپ اس کلاس کو main.dart میں استعمال کرنا چاہتے ہیں، تو آپ کو
// ProfileSetupScreen کی جگہ ChatsScreen کو کال کرنا پڑے گا:
// void main() {
//   runApp(const MyApp());
// }
// 
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
// 
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       title: 'App Demo',
//       home: ChatsScreen(), // <-- یہاں تبدیلی کی گئی ہے
//     );
//   }
// }
