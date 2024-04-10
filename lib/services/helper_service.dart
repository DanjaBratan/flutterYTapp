import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; //Package für Internet-Zugriffstests

class HelperService {

  //rückgabefreie Methode um eine Snackbar zu zeigen
  static void showSnackbar(BuildContext context, String message) { 
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(minutes: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 300.0).add(const EdgeInsets.all(16.0)),
      ),
    );
  }

  //Methode um eine Snackbar zurückzugeben
  static Widget showSnackbarWidget(BuildContext context, String message){
    return Scaffold(
          appBar: AppBar(
            title: const Text('Meldung'),
          ),
          body: Center(
            child: Text(message),
          ),
    );
  } 

  //Internet-Zugriffschecker
  static Future<void> checkInternetConnection(context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      showSnackbar(context, 'Error: Kein Internetzugriff möglich. Bitte überprüfe die Internetverbindung und starte die App neu!');
    } 
  }
  
}
