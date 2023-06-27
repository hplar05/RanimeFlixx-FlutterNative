// ignore_for_file: library_private_types_in_public_api
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AnimeLibrary extends StatefulWidget {
  const AnimeLibrary({Key? key}) : super(key: key);

  @override
  _AnimeLibraryState createState() => _AnimeLibraryState();
}

class _AnimeLibraryState extends State<AnimeLibrary> {
  List<dynamic> jsonList = [];
  int currentPage = 1;
  bool isLoading = false;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getData();

    // Add a scroll listener to the scrollController
    scrollController.addListener(scrollListener);
  }

  @override
  void dispose() {
    // Dispose the scrollController to prevent memory leaks
    scrollController.dispose();
    super.dispose();
  }

void getData() async {
  try {
    if (isLoading) return; // Prevent multiple requests while loading

    setState(() {
      isLoading = true;
    });

    var url = Uri.parse('https://api.consumet.org/anime/gogoanime/top-airing?page=$currentPage');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      print(responseData); // Print the response data

      setState(() {
        jsonList.addAll(responseData['results'] as List<dynamic>);
        currentPage++;
        isLoading = false;
      });
    } else {
      print(response.statusCode); // Print the status code if it's not 200
    }
  } catch (e) {
    print(e);
  }
}


  void showDetails(int index) async {
    final id = jsonList[index]['id'] as String;
    final url = 'https://api.consumet.org/anime/gogoanime/info/$id';

    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = response.body;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AnimeDetailScreen(animeId: id), // Pass the correct animeId
          ),
        );
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print(e);
    }
  }

  void scrollListener() {
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        !isLoading) {
      // Reached the end of the list, load more data
      getData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller:
                  scrollController, // Assign the scrollController to the ListView.builder
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                final image = jsonList[index]['image'] as String?;
                final title = jsonList[index]['title'] as String?;
                final description = jsonList[index]['description'] as String?;

                return GestureDetector(
                  onTap: () => showDetails(index),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: image != null
                                ? Image.network(
                                    image,
                                    fit: BoxFit.cover,
                                    width: 70,
                                    height: 100,
                                  )
                                : Container(),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  description ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              itemCount: jsonList.length,
            ),
          ),
        ],
      ),
    );
  }
}

class AnimeDetailScreen extends StatefulWidget {
  final String animeId;

  const AnimeDetailScreen({Key? key, required this.animeId}) : super(key: key);

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
    var url = Uri.parse("https://api.consumet.org/anime/gogoanime/info/${widget.animeId}");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        animeData = json.decode(response.body); // Parse the response body as JSON
        episodes = animeData['episodes'] ?? [];
        isLoading = false;
      });
    } else {
      print('Failed to fetch anime details. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error while fetching anime details: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 49, 50, 53),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Image.network(
                      animeData['image'] ?? '',
                      fit: BoxFit.fill,
                      width: MediaQuery.of(context).size.width,
                      height: 400,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
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
                            Positioned(
                              bottom: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  (animeData['genres'] as List<dynamic>)
                                      .join(", "),
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
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
                    itemCount: episodes.length,
                    itemBuilder: (BuildContext context, int index) {
                      final episode = episodes[index];

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.withOpacity(0.4),
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Episode ${episode['number'] ?? ''}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  ),
                                ),
                                Text(
                                  episode['title'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Add your desired functionality here
                              },
                              // ignore: sort_child_properties_last
                              child: const Text('Watch'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 160, 27, 27),
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
