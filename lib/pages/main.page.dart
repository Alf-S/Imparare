import 'package:flutter/material.dart';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../models/word.model.dart';
import '../models/wordsList.model.dart';

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
  bool isPaused = false;

  Color playIconColor = const Color(0xFF009247);
  Color pauseIconColor = const Color(0xFF575757);

  @override
  initState() {
    super.initState();

    retrieveData();
    initFTSS();
    initFSTT();

    // Wait a second before start exercice
    Future.delayed(const Duration(seconds: 1), () {
      startExerciceWrap();
    });
  }

  // LOADING METHODS

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

  initFTSS() async {
    await ftts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback,
        [IosTextToSpeechAudioCategoryOptions.defaultToSpeaker]);
    await ftts.setSpeechRate(0.45);
    await ftts.setVolume(1.0);
    await ftts.setPitch(1);
  }

  initFSTT() async {
    await fstt.initialize();
    setState(() {});
  }

  // LAYOUTING METHODS

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

  // FTTS METHODS

  layoutFTTS() {
    answerController.text = "";
    currentState = 'speaking';

    setState(() {});
  }

  playFTTS() async {
    if (!isPaused) {
      await ftts.setLanguage(wordsList[wordListIndex].languageSource);
      await ftts.awaitSpeakCompletion(true);
    }

    if (!isPaused) {
      await ftts
          .speak(wordsList[wordListIndex].wordSource)
          .then((e) => setState(() {
                currentState = 'listening';
              }));
    }
  }

  stopFTTS() async {
    await ftts.stop();
  }

  // FSTT METHODS

  layoutFSTT() {
    answerController.text = "";
    currentState = 'listening';

    setState(() {});
  }

  playFSTT() async {
    if (!isListening) {
      await fstt.listen(
          onResult: getFSTT, localeId: wordsList[wordListIndex].languageAim);
      setState(() {});
    }
  }

  getFSTT(SpeechRecognitionResult result) {
    if (!isPaused) {
      answerController.text = result.recognizedWords.toLowerCase();
      setState(() {});
    }
  }

  stopFSTT() async {
    await fstt.stop();
  }

  // EXERCICE METHODS

  startExerciceWrap() {
    startExercice();
  }

  startExercice() async {
    if (!isPaused) {
      if (wordListIndex < wordsList.length) {
        await layoutFTTS();
        await playFTTS();
        await stopFTTS();

        await layoutFSTT();
        await playFSTT();

        Future.delayed(const Duration(seconds: 4), () async {
          if (!isPaused) {
            await stopFSTT();
            validateExercice();
          }
        });
      } else {
        endExercice();
      }
    }
  }

  stopExercice() {
    stopFTTS();
    stopFSTT();

    answerController.text = "";
    isPaused = true;
  }

  layoutValidateExercice() {
    setState(() {
      answerController.text == wordsList[wordListIndex].wordAim
          ? currentState = 'rigth'
          : currentState = 'wrong';
    });
  }

  validateExercice() async {
    Future.delayed(const Duration(seconds: 1), () {
      if (!isPaused) {
        layoutValidateExercice();

        Future.delayed(const Duration(seconds: 1), () {
          if (answerController.text == wordsList[wordListIndex].wordAim) {
            wordListIndex++;
          }

          startExercice();
        });
      }
    });
  }

  endExercice() {
    pause();
  }

  // BUTTONS METHODS

  previous() {
    stopExercice();

    wordListIndex--;

    startExercice();
  }

  next() {
    stopExercice();

    wordListIndex++;

    startExercice();
  }

  play() {
    isPaused = false;

    playIconColor = const Color(0xFF009247);
    pauseIconColor = const Color(0xFF575757);
    setState(() {});

    startExercice();
  }

  pause() {
    stopExercice();

    if (isPaused) {
      currentState = 'waiting';
      playIconColor = const Color(0xFF575757);
      pauseIconColor = const Color(0xFFCD212A);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return MaterialApp(
        title: 'Imparare',
        home: Scaffold(
            appBar: AppBar(
              title: const Text('MainPage'),
              backgroundColor: const Color(0xFF009247),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      stopExercice();
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
                                    previous();
                                  },
                                  icon: const Icon(Icons.arrow_back)),
                          SizedBox(
                              width: screenWidth * 0.7,
                              child: Text(
                                textAlign: TextAlign.center,
                                wordListIndex < wordsList.length
                                    ? wordsList[wordListIndex].wordSource
                                    : '...',
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
                                    next();
                                  },
                                  icon: const Icon(Icons.arrow_forward)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              iconSize: 35,
                              color: playIconColor,
                              onPressed: () {
                                play();
                              },
                              icon: const Icon(Icons.play_arrow)),
                          IconButton(
                              iconSize: 35,
                              color: pauseIconColor,
                              onPressed: () {
                                pause();
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
