import 'package:flutter/material.dart';

import 'package:youtube_player_flutter/youtube_player_flutter.dart' as mobile_yt; //youtube-player für mobile Geräte
import 'package:youtube_player_iframe/youtube_player_iframe.dart' as web_yt; //youtube-player für Browser
import 'package:yt_api_app/services/helper_service.dart'; // Import des kleinen Services

// erstellt entweder einen YouTube-Player für mobile Geräte oder für den Webbrowser je nach Anwendungsfall 
class VideoScreen extends StatelessWidget {
  //Klassenvariablen
  final Map<String, dynamic> video; //enthält die Daten des aktuellen Videos
  final bool istImWebbrowser; //Zustand, ob die Applikation im Browser ausgeführt wird

  //Konstruktor
  const VideoScreen({super.key, required this.video, required this.istImWebbrowser});

  @override
  Widget build(BuildContext context) {
    // Überprüfen, ob das video-Objekt den erwarteten Schlüssel enthält
    if (video.containsKey('resourceId') &&
        video['resourceId'] != null &&
        video['resourceId'].containsKey('videoId')) {

      final String videoId = video['resourceId']['videoId']; // Extrahieren der Video-ID aus dem video-Objekt

      HelperService.checkInternetConnection(context); //check ob Internet-Zugriff vorhanden ist

      //Abfrage, ob die Applikation auf einem mobilen Gerät oder im Browser läuft
      if (istImWebbrowser) {
        // Für den Browser
        return _buildWebPlayer(videoId);
      } else {
        // Für mobile Geräte
        return _buildMobilePlayer(videoId);
      }
    } else {// Fehlerbehandlung, falls das video-Objekt nicht die erwarteten Schlüssel enthält
      return HelperService.showSnackbarWidget(context, 'Error: Invalid video data'); //beziehe den Helper-Service zum Anzeigen einer Fehlermeldung ein
    }
  }

  // Funktion zum Erstellen des YouTube-Players speziell für den Browser
  Widget _buildWebPlayer(String videoId) {
      // Erstellen eines YoutubePlayerControllers mit der extrahierten Video-ID
      final ytcontroller = web_yt.YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: false,
        params: const web_yt.YoutubePlayerParams(showFullscreenButton: true),
      );

      // Rückgabe eines YoutubePlayerScaffolds, um das Video zu erstellen und anzuzeigen
      return web_yt.YoutubePlayerScaffold(
        controller: ytcontroller,
        aspectRatio: 16 / 9,
        builder: (context, player) { // Der builder-Parameter definiert eine Funktion, die ein neues Widget zurückgibt
          return _buildStandardPlayerScreen(player); //rufe die Standard-Funktion zum Widget-Aufbauen auf, welche den speziellen player enthält
        },
      );
  }

  // Funktion zum Erstellen des YouTube-Players speziell für mobile Geräte
  Widget _buildMobilePlayer(String videoId) {
      // Erstellen eines YoutubePlayerControllers mit der extrahierten Video-ID
      final mobile_yt.YoutubePlayerController ytController = mobile_yt.YoutubePlayerController(
        initialVideoId: videoId,
        flags: const mobile_yt.YoutubePlayerFlags( //festlegen der Konfigurationen
          controlsVisibleAtStart: true, // Steuerelemente zu Beginn sichtbar machen
          autoPlay: false,
          mute: false,
        ),
      );

      // Rückgabe eines YoutubePlayerBuilders, um das Video zu erstellen und anzuzeigen
      return mobile_yt.YoutubePlayerBuilder(
        player: mobile_yt.YoutubePlayer( // Der player-Parameter erhält ein YoutubePlayer-Widget
          controller: ytController,
          showVideoProgressIndicator: true,
        ),
        builder: (context, player) { // Der builder-Parameter definiert eine Funktion, die ein neues Widget zurückgibt
          return _buildStandardPlayerScreen(player); //rufe die Standard-Funktion zum Widget-Aufbauen auf, welche den speziellen player enthält
        },
      );
  }

  // --> Die eigentliche Video-Anzeige
  //diese Widget-Konstruktion zeigt Appbar, (den speziellen) Player, Titel, Beschreibung an
  Widget _buildStandardPlayerScreen(player){
      return Scaffold(
            appBar: AppBar(
              title: Text(
                video['title'],
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  player, //hier den player anzeigen
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(10.0), 
                    child: Column(
                      children: [
                        Text(
                          video['title'],
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black, 
                            decoration: TextDecoration.none, 
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          video['description'],
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black, 
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.normal, 
                          ),
                        ),
                      ]
                    ),
                  ),
                ],
              ),
            ),
          );
    }

}
