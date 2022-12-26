import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/list.model.dart';
import '../models/word.model.dart';
import '../services/file.service.dart';
import 'lists.page.dart';
import 'main.page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  final FileService _fileService = FileService();
  List<ListModel> _lists = [];
  Map<String, bool> listsControllers = {};
  List<WordModel> wordsList = [];
  int checkedCount = 0;

  Map<int, Map<String, Icon>> icons = {};
  int iconIndex = 0;

  double screenHeight = 0;
  double screenWidth = 0;

  @override
  initState() {
    super.initState();

    setIconsMap();
    getLists();

    setState(() {});
  }

  getLists() async {
    List<ListModel> loadedList = [];
    List fileLists = await _fileService.readFile();

    for (var list in fileLists) {
      loadedList.add(ListModel.fromJson(list));
    }

    setState(() {
      _lists = loadedList;
      setControllers();
    });
  }

  setControllers() {
    Map<String, bool> _listsControllers = {};
    for (ListModel list in _lists) {
      _listsControllers.putIfAbsent(list.listName, () => false);
    }

    listsControllers = _listsControllers;
  }

  setIconsMap() {
    Map<int, Map<String, Icon>> _icons = {};
    for (int i = 0; i < 3; i++) {
      _icons.putIfAbsent(i, () => {});
    }

    _icons[0]?.putIfAbsent('both', () => const Icon(Icons.cached));
    _icons[1]?.putIfAbsent('fr', () => const Icon(Icons.arrow_forward));
    _icons[2]?.putIfAbsent('it', () => const Icon(Icons.arrow_back));

    icons = _icons;
  }

  setNextIcon() {
    iconIndex == 2 ? iconIndex = 0 : iconIndex++;
  }

  retrieveData() {
    List<WordModel> _wordsList = [];

    listsControllers.forEach((key, value) {
      if (value) {
        _wordsList = [
          ..._wordsList,
          ..._lists.singleWhere((list) => list.listName == key).listWords
        ];
      }
    });

    wordsList = _wordsList;
  }

  getFileFromLocal() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      _fileService.moveFile(File(result.files.single.path!));
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
                title: const Text('HomePage'),
                backgroundColor: const Color(0xFF009247),
                actions: <Widget>[
                  IconButton(
                      color: Colors.white,
                      onPressed: () {
                        setState(() {
                          getFileFromLocal();
                        });
                      },
                      icon: const Icon(Icons.upload_file)),
                  IconButton(
                      color: Colors.white,
                      onPressed: () {
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => ListsPage(lists: _lists)))
                            .then((value) => getLists());
                      },
                      icon: const Icon(Icons.settings_suggest))
                ]),
            body: Column(
              children: [
                Container(
                    margin: const EdgeInsets.symmetric(vertical: 30),
                    height: screenHeight * 0.025,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/fr_icon.png'),
                        IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              setState(() {
                                setNextIcon();
                              });
                            },
                            icon: icons[iconIndex]!.entries.first.value),
                        Image.asset('assets/images/it_icon.png'),
                      ],
                    )),
                Expanded(
                    child: ListView.builder(
                        itemCount: _lists.length,
                        itemBuilder: (BuildContext context, index) {
                          return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: screenWidth * 0.75,
                                  child: CheckboxListTile(
                                    value: listsControllers[
                                        _lists[index].listName],
                                    onChanged: (bool? value) {
                                      setState(() {
                                        //A améliorer
                                        listsControllers[
                                            _lists[index].listName] = value!;
                                        value ? checkedCount++ : checkedCount--;
                                      });
                                    },
                                    dense: true,
                                    visualDensity: const VisualDensity(
                                        horizontal: 0, vertical: -3),
                                    activeColor: const Color(0xFF009247),
                                    title: Text(_lists[index].listName,
                                        style: const TextStyle(
                                          fontSize: 14,
                                        )),
                                  ),
                                )
                              ]);
                        })),
                Container(
                    height: screenHeight * 0.075,
                    margin: const EdgeInsets.symmetric(vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        checkedCount > 0
                            ? ElevatedButton(
                                onPressed: () {
                                  // retrieveData();
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) => MainPage(
                                  //             listWords: wordsList,
                                  //             startingLanguage:
                                  //                 icons[iconIndex]!
                                  //                     .entries
                                  //                     .first
                                  //                     .key)));
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: const Color(0xFFFFFFFF),
                                  backgroundColor: const Color(0xFF009247),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: const Text(
                                  "Leçons",
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  null;
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: const Color(0xFFFFFFFF),
                                  backgroundColor: const Color(0xFF575757),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: const Text(
                                  "Leçons",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                        checkedCount > 0
                            ? ElevatedButton(
                                onPressed: () {
                                  retrieveData();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MainPage(
                                              listWords: wordsList,
                                              startingLanguage:
                                                  icons[iconIndex]!
                                                      .entries
                                                      .first
                                                      .key)));
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: const Color(0xFFFFFFFF),
                                  backgroundColor: const Color(0xFF009247),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: const Text(
                                  "Exercices",
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  null;
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: const Color(0xFFFFFFFF),
                                  backgroundColor: const Color(0xFF575757),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: const Text(
                                  "Exercices",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                      ],
                    ))
              ],
            )));
  }
}
