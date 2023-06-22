import 'package:flutter/material.dart';

class AnimeLibrary extends StatefulWidget {
  const AnimeLibrary({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AnimeLibraryState createState() => _AnimeLibraryState();
}

class _AnimeLibraryState extends State<AnimeLibrary> {
  // Define your state variables here
  int _counter = 0;

  // Define methods to handle state changes
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stateful Widget Template'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Counter:',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              '$_counter',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
