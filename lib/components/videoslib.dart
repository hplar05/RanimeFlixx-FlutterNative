// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class AnimeLibrary extends StatefulWidget {
  @override
  _AnimeLibraryState createState() => _AnimeLibraryState();
}

class _AnimeLibraryState extends State<AnimeLibrary> {
  List<dynamic> jsonList = [];
  int currentPage = 1;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    try {
      if (isLoading) return; // Prevent multiple requests while loading

      setState(() {
        isLoading = true;
      });

      var dio = Dio();
      var response = await dio.get(
        'https://api.consumet.org/anime/gogoanime/top-airing',
        queryParameters: {'page': currentPage},
      );

      if (response.statusCode == 200) {
        setState(() {
          jsonList.addAll(response.data['results'] as List<dynamic>);
          currentPage++;
          isLoading = false;
        });
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print(e);
    }
  }

  void showDetails(int index) async {
    final id = jsonList[index]['id'] as String;
    final url = 'https://api.consumet.org/anime/gogoanime/info/$id';

    try {
      var dio = Dio();
      var response = await dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;

        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AnimeDetailScreen(animeId: jsonList[index]['id']),
          ),
        );
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                final image = jsonList[index]['image'] as String?;
                final title = jsonList[index]['title'] as String?;
                final description = jsonList[index]['description'] as String?;

                return Card(
                  child: ListTile(
                    onTap: () => showDetails(index),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: image != null
                          ? Image.network(
                              image,
                              fit: BoxFit.fill,
                              width: 70,
                              height: 100,
                            )
                          : Container(),
                    ),
                    title: Text(title ?? ''),
                    subtitle: Text(description ?? ''),
                  ),
                );
              },
              itemCount: jsonList.length,
            ),
          ),
          isLoading
              ? const CircularProgressIndicator() // Show a loading indicator while fetching data
              : ElevatedButton(
                  onPressed: getData,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<
                        Color>(const Color
                            .fromARGB(255, 1, 19,
                        34)), // Replace 'Colors.blue' with your desired color
                  ),
                  child: const Text('Load More'),
                ),
        ],
      ),
    );
  }
}

class AnimeDetailScreen extends StatefulWidget {
  final String animeId;

  const AnimeDetailScreen({super.key, required this.animeId});

  @override
  _AnimeDetailScreenState createState() => _AnimeDetailScreenState();
}

class _AnimeDetailScreenState extends State<AnimeDetailScreen> {
  late dynamic animeData;
  List<dynamic> episodes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      var dio = Dio();
      var url =
          "https://api.consumet.org/anime/gogoanime/info/${widget.animeId}";
      var response = await dio.get(url);

      if (response.statusCode == 200) {
        setState(() {
          animeData = response.data;
          episodes = animeData['episodes'] ?? [];
          isLoading = false;
        });
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 49, 50, 53),
        automaticallyImplyLeading: false,
        title: const Text('Anime Details'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: ClipRRect(
                        child: Image.network(
                          animeData['image'] ?? '',
                          fit: BoxFit.fill,
                          width: 500,
                          height: 400,
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.grey.withOpacity(0.5),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              animeData['title'] ?? '',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              (animeData['genres'] as List<dynamic>).join(
                                  ', '), // Join the genre strings with a comma and space
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              animeData['description'] ?? '',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      final episode = episodes[index];

                      return ListTile(
                        title: Text('Episode ${episode['number'] ?? ''}'),
                        subtitle: Text(episode['title'] ?? ''),
                      );
                    },
                    itemCount: episodes.length,
                  ),
                ),
              ],
            ),
    );
  }
}
