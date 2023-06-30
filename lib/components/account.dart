// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Profilepage extends StatefulWidget {
  const Profilepage({Key? key}) : super(key: key);

  @override
  _ProfilepageState createState() => _ProfilepageState();
}

class _ProfilepageState extends State<Profilepage> {
  final double coverHeight = 280;
  final double profileHeight = 144;

  void logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Exit the App?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.black,
            ),
          ),
          content: const SizedBox(
            height: 35,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Are you sure you want to exit the App?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 5),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
// Exit the app
                SystemNavigator.pop();
              },
              child: const Text(
                'Exit',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          buildTop(),
          buildContent(),
          buildAbout(),
          buildAboutbody(),
        ],
      ),
    );
  }

  Widget buildTop() {
    final bottom = profileHeight / 2;
    final top = coverHeight - profileHeight / 2;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: bottom),
          child: buildCoverImage(),
        ),
        Positioned(
          top: top,
          child: buildProfileImage(),
        ),
      ],
    );
  }

  Widget buildCoverImage() => Container(
        color: Colors.grey,
        child: Image.asset(
          'lib/images/loadimg.jpg',
          width: double.infinity,
          height: coverHeight,
          fit: BoxFit.cover,
        ),
      );

  Widget buildProfileImage() => CircleAvatar(
        radius: profileHeight / 2,
        backgroundColor: Colors.grey.shade800,
        backgroundImage: const AssetImage("lib/images/profile.jpg"),
      );

  Widget buildContent() => Column(
        children: [
          const SizedBox(
            height: 8,
          ),
          const Text(
            'Ralph Saladino',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          const Text(
            'Creator of the App',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(
            height: 0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildSocialIcon(Icons.facebook_sharp),
              const SizedBox(
                width: 5,
              ),
              buildSocialIcon(Icons.phone_callback),
              const SizedBox(
                width: 5,
              ),
              buildLogoutIcon(Icons.exit_to_app_outlined),
              const SizedBox(
                width: 0,
              ),
            ],
          ),
        ],
      );

  Widget buildAbout() => Column(
        children: <Widget>[
          const SizedBox(
            height: 25,
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "  Comment:",
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: 0),
          Container(
            height: 2,
            width: MediaQuery.of(context).size.width * 3,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ],
      );

  Widget buildAboutbody() => Column(
        children: <Widget>[
          const SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.center,
            // ignore: avoid_unnecessary_containers
            child: Container(
              child: const Text(
                "  Napagtripan lang gawin sana magusto nyo \n mga Bossing. Visit nyo nadin portfolio ko \n ehehe :) hplarplay.vercel.app Salamat <3",
                style: TextStyle(fontSize: 21),
              ),
            ),
          ),
        ],
      );

  Widget buildSocialIcon(IconData icon) => Container(
        margin: const EdgeInsets.only(top: 10),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade800,
        ),
        child: IconButton(
          onPressed: () {},
          icon: Icon(
            icon,
            color: Colors.white,
            size: 25,
          ),
        ),
      );

  Widget buildLogoutIcon(IconData icon) => Container(
        margin: const EdgeInsets.only(top: 10),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade800,
        ),
        child: IconButton(
          onPressed: () {
            logout();
          },
          icon: Icon(
            icon,
            color: Colors.white,
            size: 25,
          ),
        ),
      );
}
