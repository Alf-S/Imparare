import 'package:app_italien/models/word.model.dart';
import 'package:app_italien/models/wordsList.model.dart';
import 'package:flutter/material.dart';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class MainPage extends StatefulWidget {
  final List<WordModel> listWords;
  final String startingLanguage;
  const MainPage(
      {super.key, required this.listWords, required this.startingLanguage});

  @override
  State<MainPage> createState() => _MainPage();
}

class _MainPage extends State<MainPage> {
  List<WordsListModel> wordsList = [];
  int wordListIndex = 0;

  double screenHeight = 0;
  double screenWidth = 0;

  Map<String, Container> stateIcons = {};
  String currentState = 'waiting';

  final FlutterTts ftts = FlutterTts();
  final SpeechToText fstt = SpeechToText();
  TextEditingController answerController = TextEditingController();
  bool isListening = false;

  @override
  initState() {
    retrieveData();
    super.initState();
    initFSTT();

    // Wait a second before saying the first word
    Future.delayed(const Duration(seconds: 1), () {
      sayWord();
    });
  }

  retrieveData() {
    List<WordModel> _allWords = widget.listWords;
    List<WordsListModel> _wordsList = [];

    switch (widget.startingLanguage) {
      case 'fr':
        for (WordModel word in _allWords) {
          _wordsList.add(WordsListModel(
              languageSource: 'fr-FR',
              languageAim: 'it-IT',
              wordSource: word.wordFR,
              wordAim: word.wordIT));
        }
        break;
      case 'it':
        for (WordModel word in _allWords) {
          _wordsList.add(WordsListModel(
              languageSource: 'it-IT',
              languageAim: 'fr-FR',
              wordSource: word.wordIT,
              wordAim: word.wordFR));
        }
        break;
      case 'both':
      default:
        int halfIndex = _allWords.length ~/ 2;

        List<WordModel> firstHalf = _allWords.sublist(0, halfIndex);
        List<WordModel> secondHalf = _allWords.sublist(halfIndex);

        for (WordModel word in firstHalf) {
          _wordsList.add(WordsListModel(
              languageSource: 'fr-FR',
              languageAim: 'it-IT',
              wordSource: word.wordFR,
              wordAim: word.wordIT));
        }

        for (WordModel word in secondHalf) {
          _wordsList.add(WordsListModel(
              languageSource: 'it-IT',
              languageAim: 'fr-FR',
              wordSource: word.wordIT,
              wordAim: word.wordFR));
        }
        break;
    }

    _wordsList.shuffle();
    wordsList = _wordsList;
  }

  initFSTT() async {
    await fstt.initialize();
    setState(() {});
  }

  Container getStateIcon(String state) {
    const Color col_flagGreen = Color(0xFF009247);
    const Color col_flagRed = Color(0xFFCD212A);
    const Color col_purple = Color(0xFF815EFF);

    Color displayedColor = const Color(0xFFFFFFFF);
    IconData displayedIcon = Icons.thumb_up;

    switch (state) {
      case 'waiting':
        displayedColor = col_purple;
        displayedIcon = Icons.more_horiz;
        break;

      case 'speaking':
        displayedColor = col_purple;
        displayedIcon = Icons.spatial_audio_off;
        break;

      case 'listening':
        displayedColor = col_purple;
        displayedIcon = Icons.spatial_audio;
        break;

      case 'rigth':
        displayedColor = col_flagGreen;
        displayedIcon = Icons.thumb_up;
        break;

      case 'wrong':
        displayedColor = col_flagRed;
        displayedIcon = Icons.thumb_down;
        break;
    }
    return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          color: displayedColor,
        ),
        child: Icon(size: 50, displayedIcon, color: const Color(0xFFFFFFFF)));
  }

  previousWord() {
    wordListIndex--;
  }

  nextWord() {
    wordListIndex++;
  }

  sayWord() async {
    setState(() {
      currentState = 'speaking';
    });

    await ftts.setLanguage(wordsList[wordListIndex].languageSource);
    await ftts.awaitSpeakCompletion(true);
    await ftts
        .speak(wordsList[wordListIndex].wordSource)
        .then((e) => setState(() {
              currentState = 'listening';
            }));

    listeningAnswer();
  }

  listeningAnswer() async {
    print('is listening : $isListening');

    if (!isListening) {
      await fstt.listen(onResult: setAnswer);
      setState(() {});
    }

    Future.delayed(const Duration(seconds: 5), () {
      print('sending answer');
      sendAnswer();
    });
  }

  setAnswer(SpeechRecognitionResult result) {
    print('setting answer');
    setState(() {
      print('controller : ${answerController.text}');
      print('result : ${result.recognizedWords}');
      answerController.text = result.recognizedWords;
    });
  }

  sendAnswer() {
    print('send answer : ${answerController.text}');
    setState(() {
      if (answerController.text == wordsList[wordListIndex].wordAim) {
        currentState = 'rigth';
        answerController.text = "";
        Future.delayed(const Duration(seconds: 1), () {
          nextWord();
          sayWord();
        });
      } else {
        currentState = 'wrong';
        answerController.text = "";
        Future.delayed(const Duration(seconds: 1), () {
          sayWord();
        });
      }
    });
  }

  stopListening() async {
    await fstt.stop();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return MaterialApp(
        title: 'App translate',
        home: Scaffold(
            appBar: AppBar(
              title: const Text('MainPage'),
              backgroundColor: const Color(0xFF009247),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      stopListening();
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
              Expanded(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          wordListIndex == 0
                              ? IconButton(
                                  iconSize: 35,
                                  color: const Color(0xFFA7A7A7),
                                  onPressed: () {
                                    setState(() {
                                      null;
                                    });
                                  },
                                  icon: const Icon(Icons.arrow_back))
                              : IconButton(
                                  iconSize: 35,
                                  color: const Color(0xFF575757),
                                  onPressed: () {
                                    setState(() {
                                      previousWord();
                                    });
                                  },
                                  icon: const Icon(Icons.arrow_back)),
                          SizedBox(
                              width: screenWidth * 0.7,
                              child: Text(
                                textAlign: TextAlign.center,
                                wordsList[wordListIndex].wordSource,
                                style: const TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold),
                              )),
                          wordListIndex == wordsList.length - 1
                              ? IconButton(
                                  iconSize: 35,
                                  color: const Color(0xFFA7A7A7),
                                  onPressed: () {
                                    setState(() {
                                      null;
                                    });
                                  },
                                  icon: const Icon(Icons.arrow_forward))
                              : IconButton(
                                  iconSize: 35,
                                  color: const Color(0xFF575757),
                                  onPressed: () {
                                    setState(() {
                                      nextWord();
                                    });
                                  },
                                  icon: const Icon(Icons.arrow_forward)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              iconSize: 35,
                              color: const Color(0xFF575757),
                              onPressed: () {
                                setState(() {});
                              },
                              icon: const Icon(Icons.play_arrow)),
                          IconButton(
                              iconSize: 35,
                              color: const Color(0xFF575757),
                              onPressed: () {
                                setState(() {});
                              },
                              icon: const Icon(Icons.pause)),
                        ],
                      ),
                    ]),
              ),
              Expanded(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                    getStateIcon(currentState),
                    SizedBox(
                        width: screenWidth * 0.5,
                        height: screenWidth * 0.25,
                        child: TextFormField(
                          controller: answerController,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 20, fontStyle: FontStyle.italic),
                        ))
                  ]))
            ])));
  }
}
