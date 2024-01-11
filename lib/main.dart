import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

var taylorSwiftAPI = 'taylor-swift-api.sarbo.workers.dev';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'My TS App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Album>> futureAlbums;

  @override
  initState() {
    super.initState();
    futureAlbums = fetchData();
  }

  Future<List<Album>> fetchData() async {
    List<Album> albums = [];
    var endpointURL = Uri.https(
      taylorSwiftAPI,
      'albums',
    );

    var response = await http.get(
      endpointURL,
      // insert your headers here with
      // headers: your headers
    );

    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(
        convert.utf8.decode(
          response.bodyBytes,
        ),
      ) as List<dynamic>;

      for (var album in jsonResponse) {
        albums.add(Album.fromJson(album));
      }
    }

    return albums;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder<List<Album>>(
          future: futureAlbums,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var albums = snapshot.data!;

              return ListView.builder(
                itemCount: albums.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(albums[index].title),
                ),
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            // By default, show a loading spinner.
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

class Album {
  int id = 0;
  String title = '';
  DateTime releaseDate = DateTime.now();

  Album(this.id, this.title, this.releaseDate);

  factory Album.fromJson(Map<String, dynamic> json) {
    var {
      'album_id': albumId,
      'title': title,
      'release_date': releaseDate,
    } = json;
    return Album(
      albumId,
      title,
      DateTime.parse(releaseDate),
    );
  }
}
