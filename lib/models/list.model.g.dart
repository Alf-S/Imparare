// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListModel _$ListModelFromJson(Map<String, dynamic> json) => ListModel(
      listName: json['listName'] as String,
      listWords: (json['listWords'] as List<dynamic>)
          .map((e) => WordModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ListModelToJson(ListModel instance) => <String, dynamic>{
      'listName': instance.listName,
      'listWords': instance.listWords.map((e) => e.toJson()).toList(),
    };
