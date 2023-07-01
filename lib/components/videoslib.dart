// ignore_for_file: library_private_types_in_public_api, prefer_final_fields, prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class AnimeLibrary extends StatefulWidget {
  const AnimeLibrary({Key? key}) : super(key: key);

  @override
  _AnimeLibraryState createState() => _AnimeLibraryState();
}

class _AnimeLibraryState extends State<AnimeLibrary> {
  List<dynamic> jsonList = [];
  int currentPage = 1;
  bool isLoading = false;
  ScrollController _scrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getData();

    _scrollController.addListener(_scrollListener);
  }

  void getData() async {
    try {
      if (isLoading) return;

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
        // ignore: avoid_print
        print(response.statusCode);
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      getData();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _searchAnime(String query) {
    setState(() {
      jsonList.clear();
      currentPage = 1;
      getData();
    });
  }

@override
Widget build(BuildContext context) {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  return Scaffold(
    backgroundColor: Colors.grey,
    body: Builder(
      builder: (BuildContext context) {
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: jsonList.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == jsonList.length) {
                    if (isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      return Container();
                    }
                  }

                  final image = jsonList[index]['image'] as String?;
                  final title = jsonList[index]['title'] as String?;
                  final description = jsonList[index]['description'] as String?;
                  final id = jsonList[index]['id'] as String?;

                  return GestureDetector(
                    onTap: () {
                      _handleAnimeTap(id);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2.0,
                            blurRadius: 10.0,
                            offset: const Offset(0.0, 3.0),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0),
                            ),
                            child: Image.network(
                              image ?? '',
                              fit: BoxFit.cover,
                              height: 200,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              title ?? '',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              description ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    ),
  );
}


  void _handleAnimeTap(String? id) {
    if (id != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnimeDetailsScreen(animeId: id),
        ),
      );
    }
  }
}


class AnimeDetailsScreen extends StatefulWidget {
  final String animeId;

  const AnimeDetailsScreen({Key? key, required this.animeId}) : super(key: key);

  @override
  _AnimeDetailsScreenState createState() => _AnimeDetailsScreenState();
}

class _AnimeDetailsScreenState extends State<AnimeDetailsScreen> {
  late Future<Map<String, dynamic>> animeDetailsFuture;

  @override
  void initState() {
    super.initState();
    animeDetailsFuture = fetchAnimeDetails();
  }

  Future<Map<String, dynamic>> fetchAnimeDetails() async {
    try {
      var dio = Dio();
      var response = await dio.get(
        'https://api.consumet.org/anime/gogoanime/info/${widget.animeId}',
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to fetch anime details');
      }
    } catch (e) {
      throw Exception('Failed to fetch anime details: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchEpisodeServers(String episodeId) async {
    try {
      var dio = Dio();
      print(episodeId);
      var response = await dio.get(
        'https://api.consumet.org/anime/gogoanime/servers/$episodeId'
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Failed to fetch episode servers');
      }
    } catch (e) {
      throw Exception('Failed to fetch episode servers: $e');
    }
  }

  Future<void> handleEpisodeTap(String episodeId) async {
    try {
      final servers = await fetchEpisodeServers(episodeId);
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            child: ListView.builder(
              itemCount: servers.length,
              itemBuilder: (context, index) {
                final server = servers[index];
                return ListTile(
                  title: Text(server['name']),
                  onTap: () {
                    // Handle server selection and episode ID
                    // You can do something with the selected server and episode ID here
                    Navigator.pop(context);
                  },
                );
              },
            ),
          );
        },
      );
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    return Scaffold(
      appBar: null,
      body: FutureBuilder<Map<String, dynamic>>(
        future: animeDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final animeDetails = snapshot.data!;
            final description = animeDetails['description'];

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 400,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(animeDetails['image']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          color: Colors.black.withOpacity(0.6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                animeDetails['title'],
                                style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 207, 203, 203),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                description.length > 150
                                    ? '${description.substring(0, 150)}...'
                                    : description,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color.fromARGB(255, 196, 193, 193),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Episodes:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    height: 400,
                    child: ListView.separated(
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.grey[300],
                        thickness: 1,
                        height: 0,
                      ),
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: animeDetails['episodes'].length,
                      itemBuilder: (context, index) {
                        final episode = animeDetails['episodes'][index];
                        final episodeId = episode['id']; // Assuming the episode ID is stored in the 'id' field
                        return ListTile(
                          title: Text('Episode ${episode['number']}'),
                          trailing: const Icon(Icons.play_circle_outline),
                          onTap: () => handleEpisodeTap(episodeId), // Pass the episode ID
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

