import 'package:app_italien/models/word.model.dart';

import 'package:json_annotation/json_annotation.dart';
part 'list.model.g.dart';

@JsonSerializable(explicitToJson: true)
class ListModel {
  String listName;
  List<WordModel> listWords;

  ListModel({required this.listName, required this.listWords});

  factory ListModel.fromJson(Map<String, dynamic> json) =>
      _$ListModelFromJson(json);

  Map<String, dynamic> toJson() => _$ListModelToJson(this);
}
