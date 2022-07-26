import 'dart:io';
import 'package:flutter/material.dart';
import 'classes/category.dart';
import 'ListingCategoriesWidget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'boxes.dart';
import 'classes/item.dart';



Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(ItemAdapter());
  await Hive.openBox<Category>('categories');
  await Hive.openBox<Item>('items');


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Two Dooh',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Two Dooh'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //List<Category> categories = [];
  var nameController = TextEditingController();

  @override
  void dispose() {
    Hive.box('categories').close();
    Hive.box('items').close();

    super.dispose();
  }

  void _addCategory(String value) async {
    final newCategory = Category(UniqueKey().hashCode, value);

    final box = Boxes.getCategories();
    box.add(newCategory);
  }


  void showDialogWithFields() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: const Text('Add Category'),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      autocorrect: false,
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Category Name',
                        icon: Icon(Icons.category),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                  child: const Text("Submit"),
                  onPressed: () {
                    _addCategory(nameController.text);
                    nameController.text = '';
                    Navigator.of(context).pop();
                  })
            ],
          );
        });
  }

  void showDialogInfo() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: const Text('INFO'),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                child: Column(
                  children: const <Widget>[
                    Text("Click (+) button to add item."),
                    Divider(height: 30,),
                    Text("Double click to edit the name."),
                    Divider(height: 30,),
                    Text("Swipe left to delete the item.")
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.info_outline,
            ),
            onPressed: () {
              showDialogInfo();
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<Category>>(
          valueListenable: Boxes.getCategories().listenable(),
          builder: (context, box, _) {
            final categories = box.values.toList().cast<Category>();
            return ListingCategories(
              categories: categories,
            );
          }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialogWithFields();
        },
        tooltip: 'Increment',
        backgroundColor: Colors.purple.shade400,
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}