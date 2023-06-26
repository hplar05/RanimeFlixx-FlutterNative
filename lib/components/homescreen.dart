import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class Homescreen extends StatefulWidget {
  @override
  _HomescreenState createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  String id = '';
  String title = '';
  String image = '';
  List<dynamic> genres = [];
  bool isLoading = true;

  void fetchData() async {
    try {
      const url = "https://api.consumet.org/anime/gogoanime/info/spy-x-family";
      Dio dio = Dio();
      Response response = await dio.get(url);
      var data = response.data;

      setState(() {
        id = data['id'].toString();
        title = data['title'];
        image = data['image'];
        genres = data['genres'];
        isLoading = false; // Set isLoading to false after data is fetched
      });
    } catch (error) {
      throw Exception(error.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Stack(
          alignment: Alignment.center, // Center the CircularProgressIndicator
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  width: 0,
                ),
              ),
              child: Image.network(
                image,
                fit: BoxFit.cover,
              ),
            ),
            if (isLoading) // Show CircularProgressIndicator when isLoading is true
              CircularProgressIndicator(),
            if (!isLoading) // Show data when isLoading is false
              Positioned(
                bottom: 50,
                left: 10,
                child: Text(
                  '$title',
                  style: const TextStyle(
                      fontSize: 50,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            if (!isLoading) // Show data when isLoading is false
              Positioned(
                bottom: 10,
                right: 85,
                child: Text(
                  '${genres.join(", ")}',
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
