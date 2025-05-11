import 'package:flutter/material.dart';
import 'package:wheat_rust_detection_application/customnavigationbar.dart';
import 'package:wheat_rust_detection_application/views/chatbot.dart';
import 'package:wheat_rust_detection_application/views/home_page_widgets/home_content.dart';
import 'package:wheat_rust_detection_application/views/know_the_disease.dart';
import 'package:wheat_rust_detection_application/views/profile_page.dart';

class HomePage extends StatefulWidget {
  static String route = 'home-page';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeContentPage(),
    KnowTheDiseasePage(),
    ChatbotPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _selectedIndex, onItemTapped: _onItemTapped),
    );
  }
}
