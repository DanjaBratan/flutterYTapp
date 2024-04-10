//Packages und Module
import 'package:flutter/material.dart';

//eigene erstellte benötigte Dateien
import 'package:yt_api_app/anzeigen/playlist_anzeige.dart'; //Screen mit der Playlist

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube API App Integration',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PlaylistScreen(), //Starte die Anzeige
    );
  }
}

