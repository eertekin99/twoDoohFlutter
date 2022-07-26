import 'package:flutter/material.dart';
import 'category.dart';
import 'package:hive/hive.dart';

part 'item.g.dart';

@HiveType(typeId: 1)
class Item extends HiveObject {
  @HiveField(0)
  final int key;

  @HiveField(1)
  final int categoryKey;

  @HiveField(2)
  String title;

  Item(this.key, this.categoryKey, this.title);
}