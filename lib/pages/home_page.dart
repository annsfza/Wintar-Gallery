import 'package:flutter/material.dart';
import 'package:frd_gallery/pages/profile_page.dart';
import 'gallery_page.dart';
import 'favorites_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const GalleryPage(),
    const FavoritesPage(),
    const ProfilePage(),
    const SettingsPage(),
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
     bottomNavigationBar: BottomNavigationBar(
  type: BottomNavigationBarType.fixed, // Tambahkan ini
  backgroundColor: Colors.white,
  selectedItemColor: Colors.black,
  unselectedItemColor: Colors.grey, // Opsional, untuk warna ikon tidak terpilih
  currentIndex: _selectedIndex,
  onTap: _onItemTapped,
  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.favorite),
      label: 'Favorites',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline_sharp),
      label: 'profile',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.more_rounded),
      label: 'Settings',
    ),
  ],
),

    );
  }
}
