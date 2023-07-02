import 'package:anime_app/components/videoslib.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

class SearchVideo extends StatefulWidget {
  const SearchVideo({Key? key}) : super(key: key);

  @override
  _SearchVideoState createState() => _SearchVideoState();
}

class _SearchVideoState extends State<SearchVideo> {
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

    _searchController.addListener(() {
      _searchAnime(_searchController.text);
    });
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
        print(response.statusCode);
      }
    } catch (e) {
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

  void _searchAnime(String query) async {
    setState(() {
      jsonList.clear();
      currentPage = 1;
      isLoading = true;
    });

    try {
      var dio = Dio();
      var response = await dio.get(
        'https://api.consumet.org/anime/gogoanime/$query',
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
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Builder(
        builder: (BuildContext context) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
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
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Search Anime',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          _searchAnime(_searchController.text);
                        },
                      ),
                    ],
                  ),
                ),
              ),
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
                        margin: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 8.0),
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
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0), // Add border radius
                                  child: Image.network(
                                    image ?? '',
                                    fit: BoxFit.cover,
                                    height: 100,
                                    width: 100,
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title ?? '',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          description ?? '',
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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
