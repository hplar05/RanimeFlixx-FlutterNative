import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({Key? key});

  @override
  _HomescreenState createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  Future<List<Map<String, dynamic>>> fetchData() async {
    const url = 'https://api.consumet.org/anime/gogoanime/top-airing';

    try {
      final dio = Dio();
      final response = await dio.get(url, queryParameters: {'page': 2});
      final results = response.data['results'];

      final List<Map<String, dynamic>> animeList = results
          .map<Map<String, dynamic>>((anime) => {
                'id': anime['id'],
                'title': anime['title'],
                'images': anime['images'],
                'url': anime['url'],
                'genres': anime['genres'],
              })
          .toList();

      return animeList;
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  void navigateToAnimeSelected(String animeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Animeselected(animeId: animeId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final animeList = snapshot.data;
            return ListView.builder(
              itemCount: animeList?.length,
              itemBuilder: (context, index) {
                final anime = animeList?[index];
                if (anime == null) {
                  return SizedBox(); // Return an empty SizedBox if anime is null
                }
                final title = anime['title'];
                final genres = anime['genres'];
                final images = anime['images'];
                final mainImage = images?['main'];

                return ListTile(
                  title: Text(title ?? 'Unknown Title'),
                  subtitle: Text(genres?.join(', ') ?? 'Unknown Genres'),
                  leading:
                      mainImage != null ? Image.network(mainImage) : SizedBox(),
                  onTap: () {
                    final animeId = anime['id'];
                    navigateToAnimeSelected(animeId);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class Animeselected extends StatefulWidget {
  final String animeId;

  const Animeselected({Key? key, required this.animeId});

  @override
  _AnimeselectedState createState() => _AnimeselectedState();
}

class _AnimeselectedState extends State<Animeselected> {
  String id = '';
  String title = '';
  String image = '';
  List<dynamic> genres = [];
  bool isLoading = true;

  void fetchData() async {
    try {
      final url = 'https://api.consumet.org/anime/gogoanime/info/${widget.animeId}';
      final dio = Dio();
      final response = await dio.get(url);
      final data = response.data;

      setState(() {
        id = data['id'].toString();
        title = data['title'];
        image = data['image'];
        genres = data['genres'];
        isLoading = false; // Data fetched, set isLoading to false
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                color: Colors.white,
                child: isLoading
                    ? SizedBox(
                        width: 200,
                        height: 200,
                        child: CircularProgressIndicator(), // Circular indicator
                      )
                    : Image.network(
                        image,
                        fit: BoxFit.cover,
                        height: 500, // Adjust the height as desired
                        width: double.infinity, // Set the width to fill the container
                      ),
              ),
              Positioned(
                bottom: 40,
                left: 10,
                child: Text(
                  ' $title',
                  style: const TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 200,
                child: Text(
                  ' ${genres.join(", ")}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}