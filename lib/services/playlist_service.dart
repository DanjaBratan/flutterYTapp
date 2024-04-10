import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

// "hardcoded_playlist_lite.dart" enthält eine default (fallback) Playlist 
// wodurch, falls die API oder die ehemalige Playlist nicht mehr vorhanden sind, 
// diese default-Playlist verwendet werden kann [siehe Code]
import 'package:yt_api_app/bestandteile/hardcoded_playlist_lite.dart'; 


class PlaylistService {
  //Attribute des Objekts
  final String playlistId;
  final String apiKey;

  //Konstruktor
  PlaylistService({required this.playlistId, required this.apiKey});

  //Methode zum Laden der Playlist mithilfe der API ("YouTube Data API v3") mit dem "apiKey" und mit einer existierenden Playlist "playlistId"
  Future<List<dynamic>> fetchPlaylist() async {
    try {

      // Erstelle die URL für die API-Anfrage siehe Doku https://developers.google.com/youtube/v3/docs/playlistItems/list?hl=de
      final Uri url = Uri.https('www.googleapis.com', '/youtube/v3/playlistItems', {
        'part': 'snippet', //playlistItem-Ressourceneigenschaften, die in der API-Antwort enthalten sein werden. bei "snippet" sind alle Eigenschaften enthalten
        'playlistId': playlistId, //gibt die eindeutige ID der Playlist an, für die die Playlist-Elemente abrufen werden sollen
        'key': apiKey, //der zu verwendete Api-Key für die Youtube Data API
      }); 

      final response = await http.get(url); // Sende die HTTP-Anfrage ab

      if (response.statusCode == 200) { // Überprüfe den Statuscode der Antwort
        
        final Map<String, dynamic> extractedData = json.decode(response.body); // Dekodiere die JSON-Antwort und füge es in eine Map ein

        if (extractedData.containsKey('items')) { // Überprüfe, ob die Map-Daten den erwarteten Schlüssel "items" enthalten
          return extractedData['items']; //gib ein den Teilinhalt mit dem keyword "items" zurück
        } else {
          throw 'Error: Unexpected data format'; // Fehlermeldung, wenn das Datenformat unerwartet ist
        }

      } else { //andere Status Codes abprüfen
        switch (response.statusCode) {
          case 403:
            // Fehler: Zugriff verweigert
            final errorResponse = json.decode(response.body);
            if (errorResponse['reason'] == 'channelClosed') {
              throw 'Error: Der Kanal wurde geschlossen.';
            } else if (errorResponse['reason'] == 'channelSuspended') {
              throw 'Error: Der Kanal wurde gesperrt.';
            } else if (errorResponse['reason'] == 'playlistForbidden') {
              throw 'Error: Zugriff auf die Playlist ist nicht möglich.';
            } else {
              throw 'Error: Zugriff verweigert (${errorResponse['reason']})';
            }
          case 404:
            // Fehler: Playlist nicht gefunden
            throw 'Error: Playlist nicht gefunden.'; //standard Fehler wenn es die Playlist nicht gibt
          case 400:
            // Fehler: Ungültiger Wert
            throw 'Error: Ungültiger Wert.';
          default:
            // Unbekannter Fehler
            throw 'Error: Unbekannter Fehler (${response.statusCode})';
        }
      }
    } catch (error) {
      throw 'Error: $error';
    }
  }

  //Methode zum Laden der Playlist ohne API und mit einer hardcoded Playlist aus "hardcoded_playlist_lite.dart"
  Future<List<dynamic>> fetchPlaylistNoApi() async {
    try {
      // falls die Playlist durch eigene Daten hardcoded ersetzt werden soll,
      // kann die Datei "hardcoded_playlist_lite.dart" angepasst und verwendet werden
      return datenDerPlaylist['items']; //diese Map enthält die nötigsten hardcoded Daten für die Applikation 
    } catch (error) {
      throw 'Error: $error';
    }
  }

}
