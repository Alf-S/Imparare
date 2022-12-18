import 'package:app_italien/models/list.model.dart';
import 'package:app_italien/models/word.model.dart';
import 'package:app_italien/services/file.service.dart';
import 'package:flutter/material.dart';

class ListsPage extends StatefulWidget {
  const ListsPage({super.key});

  @override
  State<ListsPage> createState() => _ListPage();
}

class _ListPage extends State<ListsPage> {
  final FileService _fileService = FileService();

  //SEE TO UPDATE THIS PART
  ListModel _currentList = ListModel(
      listName: 'listName',
      listWords: [WordModel(wordFR: 'wordFR', wordIT: 'wordIT')]);
  List<ListModel> _lists = [];
  bool newList = true;

  //LAST THING DONES
  TextEditingController listNameController = TextEditingController();
  Map<int, Map<String, TextEditingController>> wordsControllers = {};

  final Color col_flagGreen = const Color(0xFF009247);
  final Color col_flagRed = const Color(0xFFCD212A);
  final Color col_white = const Color(0xFFFFFFFF);
  final Color col_darkGrey = const Color(0xFF575757);

  double screenHeight = 0;
  double screenWidth = 0;

  @override
  initState() {
    getLists();
    super.initState();
  }

  //LOADING METHODS

  getLists() async {
    List<ListModel> loadedList = [];
    List fileLists = await _fileService.readFile();

    if (fileLists.isNotEmpty) {
      for (var list in fileLists) {
        loadedList.add(ListModel.fromJson(list));
      }
      newList = false;
    }

    setState(() {
      _lists = loadedList;
      if (loadedList.isNotEmpty) {
        _currentList = loadedList.last;
      }
      setControllers();
    });
  }

  setControllers() {
    //Set the words in each controller text
    Map<int, Map<String, TextEditingController>> _wordsControllers = {};

    _currentList.listWords.asMap().forEach((i, word) {
      TextEditingController textEditingControllerFR =
          TextEditingController(text: word.wordFR);

      _wordsControllers.putIfAbsent(i, () => {});
      _wordsControllers[i]!.putIfAbsent('FR', () => textEditingControllerFR);

      TextEditingController textEditingControllerIT =
          TextEditingController(text: word.wordIT);

      _wordsControllers.putIfAbsent(i, () => {});
      _wordsControllers[i]!.putIfAbsent('IT', () => textEditingControllerIT);
    });

    listNameController = TextEditingController(text: _currentList.listName);
    wordsControllers = _wordsControllers;
  }

  //BUTTONS METHODS

  createNewList() {
    newList = true;
    _currentList = ListModel(
        listName: 'newList',
        listWords: [WordModel(wordFR: 'newWordFR', wordIT: 'newWordIT')]);
    setControllers();
  }

  deleteCurrentList() {
    String currentListName = _currentList.listName;
    _lists.removeWhere((element) => element.listName == currentListName);
    dropdownOnChanged(_lists.last.listName);
    saveLists();
  }

  addNewLine() {
    //First, we adding a new entry on the list so inputs will appears in template
    _currentList.listWords
        .add(WordModel(wordFR: 'newWordFR', wordIT: 'newWordIT'));

    //Then we adding new controllers that will be bind to the new inputs
    int i = wordsControllers.length;

    TextEditingController textEditingControllerFR =
        TextEditingController(text: 'newWordFR');

    wordsControllers.putIfAbsent(i, () => {});
    wordsControllers[i]!.putIfAbsent('FR', () => textEditingControllerFR);

    TextEditingController textEditingControllerIT =
        TextEditingController(text: 'newWordIT');

    wordsControllers.putIfAbsent(i, () => {});
    wordsControllers[i]!.putIfAbsent('IT', () => textEditingControllerIT);
  }

  deleteLastLine() {
    _currentList.listWords.removeLast();
    int i = wordsControllers.length - 1;
    wordsControllers.remove(i);
  }

  saveLists() {
    ListModel listToSave =
        ListModel(listName: listNameController.text, listWords: []);

    for (var i = 0; i < wordsControllers.entries.length; i++) {
      String wordFR = wordsControllers[i]!['FR']!.text;
      String wordIT = wordsControllers[i]!['IT']!.text;

      listToSave.listWords.add(WordModel(wordFR: wordFR, wordIT: wordIT));
    }

    //On vérifie si la liste existe déjà, si oui on la supprime avant de l'ajouter
    int index =
        _lists.indexWhere((list) => list.listName == listToSave.listName);
    if (index != -1) {
      _lists.removeAt(index);
    }
    _lists.add(listToSave);
    _fileService.writeFile(_lists);

    dropdownOnChanged(listToSave.listName);
    newList = false;
  }

  //DROPDOWN METHODS

  List<DropdownMenuItem<String>> get _dropdownMenuItems {
    List<DropdownMenuItem<String>> items = [];
    for (var element in _lists) {
      items.add(DropdownMenuItem(
          value: element.listName, child: Text(element.listName)));
    }
    return items;
  }

  void dropdownOnChanged(String listName) {
    _currentList =
        _lists.where((element) => element.listName == listName).first;
    setControllers();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return MaterialApp(
        title: 'App translate',
        home: Scaffold(
            appBar: AppBar(
              title: const Text('ListPage Test'),
              backgroundColor: col_flagGreen,
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: col_white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: const Icon(Icons.arrow_back)),
              ],
            ),
            body: Form(
              child: Column(children: [
                Center(child: newList ? headerTextField() : headerDropDown()),
                Container(
                    height: screenHeight * 0.025,
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Image.asset('assets/images/fr_icon.png'),
                        Image.asset('assets/images/it_icon.png'),
                      ],
                    )),
                Expanded(
                    child: ListView.builder(
                        itemCount: _currentList.listWords.length,
                        itemBuilder: (BuildContext context, index) {
                          return Row(
                            children: [
                              Expanded(
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 25),
                                      child: TextFormField(
                                          style: const TextStyle(fontSize: 14),
                                          controller: wordsControllers[index]
                                              ?['FR']))),
                              Expanded(
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 25),
                                      child: TextFormField(
                                          style: const TextStyle(fontSize: 14),
                                          controller: wordsControllers[index]
                                              ?['IT'])))
                            ],
                          );
                        })),
                Container(
                  height: screenHeight * 0.065,
                  margin: const EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                          // 1 : CREATE NEW LIST
                          iconSize: 35,
                          color: col_darkGrey,
                          onPressed: () {
                            setState(() {
                              createNewList();
                            });
                          },
                          icon: const Icon(Icons.playlist_add)),
                      IconButton(
                          // 2 : DELETE CURRENT LIST
                          iconSize: 35,
                          color: col_flagRed,
                          onPressed: () {
                            setState(() {
                              deleteCurrentList();
                            });
                          },
                          icon: const Icon(Icons.playlist_remove)),
                      IconButton(
                          // 3 : ADD NEW LINE
                          iconSize: 28,
                          color: col_darkGrey,
                          onPressed: () {
                            setState(() {
                              addNewLine();
                            });
                          },
                          icon: const Icon(Icons.add_circle_outline)),
                      IconButton(
                          // 4 : DELETE LAST LIGNE
                          iconSize: 28,
                          color: col_flagRed,
                          onPressed: () {
                            setState(() {
                              if (_currentList.listWords.length > 1) {
                                deleteLastLine();
                              }
                            });
                          },
                          icon: const Icon(Icons.remove_circle_outline)),
                      IconButton(
                          // 5 : SAVE LISTS
                          iconSize: 35,
                          color: col_flagGreen,
                          onPressed: () {
                            setState(() {
                              saveLists();
                            });
                          },
                          icon: const Icon(Icons.playlist_add_check)),
                    ],
                  ),
                )
              ]),
            )));
  }

  headerDropDown() {
    return Container(
        height: screenHeight * 0.055,
        width: screenWidth * 0.35,
        margin: const EdgeInsets.symmetric(vertical: 15),
        child: DropdownButton<String>(
            isExpanded: true,
            iconSize: 18,
            icon: const Icon(Icons.arrow_downward),
            value: _currentList.listName,
            onChanged: (String? newValue) {
              setState(() {
                dropdownOnChanged(newValue!);
              });
            },
            items: _dropdownMenuItems));
  }

  headerTextField() {
    return Container(
        height: screenHeight * 0.095,
        width: screenWidth * 0.65,
        margin: const EdgeInsets.symmetric(vertical: 15),
        child: Column(children: [
          const Text('Create new list :'),
          TextFormField(
              style: const TextStyle(fontSize: 14),
              controller: listNameController)
        ]));
  }
}
