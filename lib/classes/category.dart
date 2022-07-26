import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 0)
class Category extends HiveObject{

  @HiveField(0)
  final int key;

  @HiveField(1)
  String title;

  Category(this.key, this.title);
}