// import 'package:app_italien/models/list.model.dart';
import 'package:app_italien/models/word.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MainPage extends StatefulWidget {
  final List<WordModel> listWords;
  final String startingLanguage;
  const MainPage(
      {super.key, required this.listWords, required this.startingLanguage});

  @override
  State<MainPage> createState() => _MainPage();
}

class _MainPage extends State<MainPage> {
  Map<String, String> mapWords = {};

  double screenHeight = 0;
  double screenWidth = 0;

  int index = 0;
  // faire un cache pour le last random mot

  FlutterTts ftts = FlutterTts();

  @override
  initState() {
    retrieveData();
    // fttsSetup();
    super.initState();
  }

  retrieveData() {
    Map<String, String> _mapWords = {};
    List<WordModel> _allWords = widget.listWords;

    switch (widget.startingLanguage) {
      case 'fr':
        for (WordModel word in _allWords) {
          _mapWords.putIfAbsent(word.wordFR, () => word.wordIT);
        }
        break;
      case 'it':
        for (WordModel word in _allWords) {
          _mapWords.putIfAbsent(word.wordIT, () => word.wordFR);
        }
        break;
      case 'both':
      default:
        int halfIndex = _allWords.length ~/ 2;

        List<WordModel> firstHalf = _allWords.sublist(0, halfIndex);
        List<WordModel> secondHalf = _allWords.sublist(halfIndex);

        for (WordModel word in firstHalf) {
          _mapWords.putIfAbsent(word.wordFR, () => word.wordIT);
        }

        for (WordModel word in secondHalf) {
          _mapWords.putIfAbsent(word.wordIT, () => word.wordFR);
        }
        break;
    }

    mapWords = _mapWords;
  }

  String getRandomWord() {
    // delete le mot last position random
    // random de la list length
    // prendre le mot position random
    return '';
  }

  Future<dynamic> _getLanguages() async => await ftts.getLanguages;
  Future<dynamic> _getEngines() async => await ftts.getEngines;

  fttsSetup() {
    var languages = _getLanguages();
    var engines = _getEngines();
  }

  speak() async {
    await ftts.setLanguage("it-IT");
    await ftts.setVolume(1.0);
    var result = await ftts.speak("Hello World, this is Flutter Campus.");
    if (result == 1) {
      //speaking
    } else {
      //not speaking
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return MaterialApp(
        title: 'App translate',
        home: Scaffold(
            appBar: AppBar(
              title: const Text('MainPage Test'),
              backgroundColor: const Color(0xFF009247),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFFFFFFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: const Icon(Icons.arrow_back)),
              ],
            ),
            body: Column(children: [
              Text(mapWords.keys.elementAt(index),
                  style: const TextStyle(
                    fontSize: 14,
                  )),
              ElevatedButton(
                onPressed: () {
                  speak();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color(0xFFFFFFFF),
                  backgroundColor: const Color(0xFF575757),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  "Speak",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color(0xFFFFFFFF),
                  backgroundColor: const Color(0xFF575757),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  "Stop",
                  style: TextStyle(fontSize: 16),
                ),
              )
            ])));
  }
}
