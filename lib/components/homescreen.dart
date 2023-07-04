// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';


class Homescreen extends StatelessWidget {
  const Homescreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anime App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AnimeHomePage(),
    );
  }
}

class AnimeHomePage extends StatefulWidget {
  const AnimeHomePage({Key? key}) : super(key: key);

  @override
  _AnimeHomePageState createState() => _AnimeHomePageState();
}

class _AnimeHomePageState extends State<AnimeHomePage> {
  final List<String> carouselImages = [
    'lib/images/one.jpg',
    'lib/images/stone.jpg',
    'lib/images/black.jpg',
    'lib/images/naruto.jpg',
    'lib/images/mashle.jpg',
    'lib/images/demon.jpg',
  ];
  late PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPageIndex);
    _startAutoScroll();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPageIndex < carouselImages.length - 1) {
        _currentPageIndex++;
      } else {
        _currentPageIndex = 0;
      }
      _pageController.animateToPage(
        _currentPageIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
        backgroundColor: Colors.grey, // Set the background color to grey
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text(
              'Popular Anime',
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: Color.fromARGB(255, 0, 0, 0)),
            ),
            const SizedBox(height: 13),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: carouselImages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Image.asset(
                      carouselImages[index],
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width * 0.7,
                    ),
                  );
                },
                onPageChanged: (index) {
                  setState(() {
                    _currentPageIndex = index;
                  });
                },
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView(
                children: [
                  AnimeCard(
                    title: 'Mashle',
                    imageUrl: 'lib/images/mashle.jpg',
                    onTap: () {
                      // Handle anime selection
                    },
                  ),
                  AnimeCard(
                    title: 'Demon Slayer',
                    imageUrl: 'lib/images/demon.jpg',
                    onTap: () {
                      // Handle anime selection
                    },
                  ),
                  AnimeCard(
                    title: 'One Piece',
                    imageUrl: 'lib/images/one.jpg',
                    onTap: () {
                      // Handle anime selection
                    },
                  ),
                ],
              ),
            ),
          ]),
        ));
  }
}

class AnimeCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  const AnimeCard({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
