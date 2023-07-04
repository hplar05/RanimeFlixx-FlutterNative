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
    

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
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
                    final description =
                        jsonList[index]['description'] as String?;
                    final id = jsonList[index]['id'] as String?;

                    return GestureDetector(
                      onTap: () {
                        _handleAnimeTap(id);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 7.0, horizontal: 10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.grey,
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
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
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool isEpisodeLoading = false;

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

  Future<List<Map<String, dynamic>>> fetchEpisodeServers(
      String episodeId) async {
    try {
      var dio = Dio();
      var response = await dio.get(
        'https://api.consumet.org/anime/gogoanime/watch/$episodeId?server=gogocdn',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final sources = List<Map<String, dynamic>>.from(data['sources']);
        return sources;
      } else {
        throw Exception('Failed to fetch episode servers');
      }
    } catch (e) {
      throw Exception('Failed to fetch episode servers: $e');
    }
  }

  Future<void> handleEpisodeTap(String episodeId) async {
    try {
      setState(() {
        isEpisodeLoading = true;
      });

      final servers = await fetchEpisodeServers(episodeId);
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 67, 72, 75),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Select Episode Quality',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: servers.length,
                  itemBuilder: (context, index) {
                    final server = servers[index];
                    final quality = server['quality'];
                    final url = server['url'];
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                      title: Text(
                        'Quality: $quality',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                VideoPlayerScreen(videoUrl: url),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        isEpisodeLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    

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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
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
                        final episodeId = episode['id'];
                        return ListTile(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16.0),
                          title: Text(
                            'Episode ${episode['number']}',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          trailing: Icon(
                            Icons.play_circle_outline,
                            color: const Color.fromARGB(255, 59, 60, 60),
                          ),
                          onTap: () => handleEpisodeTap(episodeId),
                        );
                      },
                    ),
                  ),
                  if (isEpisodeLoading)
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                  if (_chewieController != null)
                    Chewie(controller: _chewieController!),
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


class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: true,
      aspectRatio: 16 / 9, // Adjust the aspect ratio as needed for stretching
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 49, 50, 53),
      ),
      body: Center(
        child: Chewie(controller: _chewieController),
      ),
    );
  }
}
