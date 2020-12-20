import 'package:senior_launcher/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:senior_launcher/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class Update {
  static void checkUpdateAndroid(BuildContext context) async {
    try {
      http.Response response =
          await http.get('https://clementsicard.github.io/AppInstaller/');
      final String resp = response.body;
      int firstIndex = resp.indexOf('-->');
      var resp2 = resp.substring(firstIndex + 3);
      int secondIndex = firstIndex + 3 + resp2.indexOf('-->');
      final String version = resp.substring(firstIndex + 8, secondIndex);
      final String toDisplay =
          'Nouvelle version disponible! ($version)\nLa version actuelle est la ' +
              Constants.CURRENT_VERSION;
      print(toDisplay);
      if (Constants.CURRENT_VERSION != version) {
        Navigator.pop(context);
        return showDialog(
          context: context,
          builder: (nContext) {
            return AlertDialog(
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20.0),
                ),
              ),
              title: Text(
                toDisplay,
                style: TextStyles.dialogTitle,
                textAlign: TextAlign.center,
              ),
              content: Text(
                'Mettre à jour ?',
                textAlign: TextAlign.center,
                style: TextStyles.dialogActionMain,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.check),
                  iconSize: 110,
                  onPressed: () async {
                    const url =
                        'https://dl.dropboxusercontent.com/s/1uzf6uwalzjym4a/SeniorLauncher.apk';
                    if (await canLaunch(url)) {
                      await FlutterDownloader.initialize();
                      const downloadFolderPath =
                          '/storage/emulated/0/Download/';
                      var appName = 'SeniorLauncher_$version.apk';
                      final taskId = await FlutterDownloader.enqueue(
                        url: url,
                        fileName: appName,
                        savedDir: downloadFolderPath,
                        showNotification: true,
                        openFileFromNotification: true,
                      );
                      try {
                        bool success = false;
                        while (!success) {
                          await Future.delayed(Duration(seconds: 2));
                          success =
                              await FlutterDownloader.open(taskId: taskId);
                        }
                      } catch (e) {
                        await Fluttertoast.showToast(
                            msg: "Erreur lors de l'ouverture de l'APK");
                      }
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  color: Colors.green,
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  iconSize: 110,
                  onPressed: () => Navigator.pop(nContext),
                  color: Colors.red,
                ),
              ],
            );
          },
        );
      } else {
        Navigator.pop(context);
        return showDialog(
          context: context,
          builder: (nContext) {
            return AlertDialog(
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20.0),
                ),
              ),
              title: Text(
                'Pas de nouvelle mise à jour disponible',
                style: TextStyles.dialogTitle,
                textAlign: TextAlign.center,
              ),
              content: null,
              actions: [
                FlatButton(
                  child: const Text(
                    'RETOUR',
                    style: TextStyles.dialogAction,
                  ),
                  onPressed: () {},
                ),
              ],
            );
          },
        );
      }
    } catch (_) {
      await Fluttertoast.showToast(msg: 'Erreur pendant la mise à jour');
    }
  }
}