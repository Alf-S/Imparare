import 'package:app_italien/models/list.model.dart';
import 'package:app_italien/models/word.model.dart';
import 'package:app_italien/pages/lists.page.dart';
import 'package:app_italien/pages/main.page.dart';
import 'package:app_italien/services/file.service.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

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
    getLists();
    setIconsMap();
    super.initState();
  }

  getLists() async {
    List<ListModel> loadedList = [];
    List fileLists = await _fileService.readFile();

    if (fileLists.isNotEmpty) {
      for (var list in fileLists) {
        loadedList.add(ListModel.fromJson(list));
      }
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

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return MaterialApp(
        title: 'App translate',
        home: Scaffold(
            appBar: AppBar(
                title: const Text('App translate'),
                backgroundColor: const Color(0xFF009247)),
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
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ListsPage()));
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: const Color(0xFFFFFFFF),
                            backgroundColor: const Color(0xFF009247),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            "Lists",
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
                                  "Start",
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
                                  "Start",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                      ],
                    ))
              ],
            )));
  }
}
