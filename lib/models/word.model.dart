import 'package:json_annotation/json_annotation.dart';
part 'word.model.g.dart';

@JsonSerializable(explicitToJson: true)
class WordModel {
  String wordFR;
  String wordIT;

  WordModel({required this.wordFR, required this.wordIT});

  factory WordModel.fromJson(Map<String, dynamic> json) =>
      _$WordModelFromJson(json);

  Map<String, dynamic> toJson() => _$WordModelToJson(this);
}
