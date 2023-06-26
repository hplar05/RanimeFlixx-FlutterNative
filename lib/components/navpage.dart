import 'package:anime_app/components/account.dart';
import 'package:anime_app/components/homescreen.dart';
import 'package:anime_app/components/searchvid.dart';
import 'package:anime_app/components/videoslib.dart';
import 'package:flutter/material.dart';

class Navpages extends StatefulWidget {
  const Navpages({
    Key? key,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _NavpagesState createState() => _NavpagesState();
}

class _NavpagesState extends State<Navpages> {
  int _currentIndex = 0;

  // ignore: unused_element
  void _navigateBottomBar(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<Widget> _screens = [
    Homescreen(),
    AnimeLibrary(),
    const SearchVideo(),
    const Profilepage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(0.0),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color.fromARGB(255, 49, 50, 53),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          elevation: 0.0,
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6.0,
                  horizontal: 16.0,
                ),
                decoration: BoxDecoration(
                  color: _currentIndex == 0 ? Colors.blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: const Icon(Icons.home),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6.0,
                  horizontal: 16.0,
                ),
                decoration: BoxDecoration(
                  color: _currentIndex == 1 ? Colors.blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: const Icon(Icons.smart_display),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6.0,
                  horizontal: 16.0,
                ),
                decoration: BoxDecoration(
                  color: _currentIndex == 2 ? Colors.blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: const Icon(Icons.search),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6.0,
                  horizontal: 16.0,
                ),
                decoration: BoxDecoration(
                  color: _currentIndex == 3 ? Colors.blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: const Icon(Icons.person),
              ),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}
