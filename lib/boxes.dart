import 'package:hive/hive.dart';
import 'package:to_do_app/classes/category.dart';
import 'package:to_do_app/classes/item.dart';

class Boxes {
  static Box<Category> getCategories() =>
      Hive.box<Category>('categories');

  static Box<Item> getItems() =>
      Hive.box<Item>('items');
}