//Packages
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; //zum Erkennen, ob ein Browser verwendet wird

//eigene Dateien
import 'package:yt_api_app/services/playlist_service.dart'; // Import des PlaylistService
import 'package:yt_api_app/bestandteile/keys.dart'; // Import der API-Schlüssel
import 'package:yt_api_app/anzeigen/video_anzeige.dart'; // Import des VideoScreen-Widgets
import 'package:yt_api_app/services/helper_service.dart'; // Import des kleinen Services

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  PlaylistScreenState createState() => PlaylistScreenState();
}

class PlaylistScreenState extends State<PlaylistScreen> {
  //Klassenvariablen
  late PlaylistService _playlistService; //plane Objekt der externen Klasse PlaylistService
  List<dynamic> _videos = []; //Liste für Video-Informationen
  String plistId = 'PLnS0gE9DxCrsBv9kz1htHadmS7rCimQz1'; //Playlist-ID "PLnS0gE9DxCrsBv9kz1htHadmS7rCimQz1"


  @override
  void initState() { 
    super.initState();
    _playlistService = PlaylistService(playlistId: plistId, apiKey: apiKey); //erstelle das PlaylistService-Objekt mit der definierten plistId und dem Api-Key aus keys.dart
    ladePlaylist(); // rufe die Funktion zum Laden der Playlist auf
    _checkEmptyPlaylist(); //rufe einen check auf, der prüfen soll, ob die Playlist geladen wurde
  }

  // Funktion zum Laden der Playlist-Daten aus dem PlaylistService.
  void ladePlaylist() async {
    try { 

      HelperService.checkInternetConnection(context); //check ob Internet-Zugriff vorhanden ist

      //final videos = await _playlistService.fetchPlaylist(); // Playlist-Daten per API und Playlist-ID abrufen
      
      //nutze die App per hardcoded playlist ohne API
      final videos = await _playlistService.fetchPlaylistNoApi(); //Playlist-Daten abrufen OHNE verwendung einer API und mit einer hardcoded-Playlist (hardcoded_playlist_lite.dart)
      

      setState(() {
        _videos = videos; // Videos-Liste setzen und UI aktualisieren
      });
      
    } catch (error) {
      HelperService.showSnackbar(context, error.toString()); // Wenn ein Fehler auftritt, wird 'showSnackbar' des playlistService-Objekts aufgerufen
    }
  }

  //check nach 8 Sekunden, der prüfen soll, ob die Playlist geladen wurde (nicht leer ist)
  void _checkEmptyPlaylist() {
    Future.delayed(const Duration(seconds: 8), () {
      if (_videos.isEmpty) {
        HelperService.showSnackbar(context, 'Videos konnten nach 8 Sekunden nicht geladen werden. Versuche die App neuzustarten!');
      }
    });
  }

  @override
  Widget build(BuildContext context) { // das UI des PlaylistScreens erstellen
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube DHGE Playlist'),
      ),
      body: _videos.isEmpty // Wenn die Liste leer ist
        ? HelperService.showSnackbarWidget(context, 'Playlist lädt...')
        : ListView.builder(
          itemCount: _videos.length,
          itemBuilder: (context, index) {
            final Map<String, dynamic> video = _videos[index]['snippet']; // Extrahiere die Daten des AKTUELLEN Videos --> [index]
            final String thumbnailUrl = video['thumbnails']['medium']['url'] ?? ''; // Extrahiere die Thumbnail-URL

            return GestureDetector( //Erkennung des Drückens auf den Bildschirm
              onTap: () {
                Navigator.push( //Navigation zum nächsten Screen
                  context,
                  MaterialPageRoute(builder: (context) => VideoScreen(video: video, istImWebbrowser: kIsWeb)), //Navigation zum Video-Bildschirm mit Übergabe der Video-Map
                );
              },
              child: Card( // Widget für jedes Video
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        // wenn die App im Web ist, wird ein Platzhalterbild verwendet, sonst das Thumbnail
                        kIsWeb 
                           ? Image.asset( // lädt einen Platzhalter, weil es im Browser CORS-Probleme gibt
                             'bilder/platzhalterbild.jpg', //Alternativ könnte man hier andere Thumbnails einfügen, in dem zuvor Bilderpfade in einer Liste gespeichert werden und dann mit dem Index der passende Pfad angegeben werden 
                             height: 50, 
                             fit: BoxFit.cover, 
                           ) 
                          : Image.network( // lädt das Thumbnail-Bild aus dem Internet anhand der bereitgestellten URL und zeigt es an (nur auf mobilen Geräten [iOS und Android])
                              thumbnailUrl,
                              height: 200, 
                              fit: BoxFit.cover, 
                            ),

                        const SizedBox(height: 5),
                        Column(
                          children: [  
                            Text(
                              video['title'], 
                              style: const TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold, 
                              ),
                            ),
                            Text(video['description']), //Beschreibung des Videos
                          ],
                        ),
                      ],
                    ),
                  ),
              ),
            );
        },
      ),
    );
  }

}
