import 'package:flutter/material.dart';
import 'package:to_do_app/classes/item.dart';
import 'boxes.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

class CategoryItems extends StatefulWidget {
  CategoryItems({Key? key, required this.title, required this.categoryKey}) : super(key: key);
  final String title;
  final int categoryKey;

  //late final List<Item> items = [];

  @override
  State<CategoryItems> createState() => _CategoryItemsState();
}

class _CategoryItemsState extends State<CategoryItems> {
  var nameController = TextEditingController();

  void _addItem(String value) {
    final newItem = Item(UniqueKey().hashCode, widget.categoryKey, value);

    final box = Boxes.getItems();
    box.add(newItem);
    setState(() {

    });
  }

  void showDialogWithFields() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: const Text('Add Item'),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      autocorrect: false,
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Item Name',
                        icon: Icon(Icons.pie_chart),
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
                    _addItem(nameController.text);
                    nameController.text = '';
                    Navigator.of(context).pop();
                  })
            ],
          );
        });
  }

  void showDialogWithFieldsToChangeName(Item oldItem) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: Text('Change \'${oldItem.title}\''),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      autocorrect: false,
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'New Name',
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

                    setState(() {
                      //Checks if it is empty or not.
                      if (nameController.text == "") {
                        oldItem.title = oldItem.title;
                      } else {
                        oldItem.title = nameController.text;
                      }
                      nameController.text = '';
                      oldItem.save();
                    });

                    Navigator.of(context).pop();
                  })
            ],
          );
        });
  }

  //extends HiveObject'den geliyor.
  void deleteItem(Item item) {
    item.delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.purple.shade400,
      ),
      body: ValueListenableBuilder<Box<Item>>(
          valueListenable: Boxes.getItems().listenable(),
          builder: (context, box, _) {
            final items = box.values.where((Item) => Item.categoryKey == widget.categoryKey).toList().cast<Item>();
          return Center(
            child: ListView.separated(
              // Let the ListView know how many items it needs to build.
              itemCount: items.length,
              // Provide a builder function. This is where the magic happens.
              // Convert each item into a widget based on the type of item it is.
              itemBuilder: (context, index) {
                final item = items[index];

                return Dismissible(
                  direction: DismissDirection.endToStart,
                  // Each Dismissible must contain a Key. Keys allow Flutter to
                  // uniquely identify widgets.
                  key: UniqueKey(),
                  // Provide a function that tells the app
                  // what to do after an item has been swiped away.
                  onDismissed: (direction) {
                    // Remove the item from the data source.
                    setState(() {
                      deleteItem(items.elementAt(index));
                    });

                    // Then show a snackbar.
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('${item.title} deleted'),
                      duration: const Duration(seconds: 1),
                    ));
                  },
                  background: Container(
                    color: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const <Widget>[
                        Icon(
                          Icons.delete,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                  child: ListTile(
                    title: GestureDetector(
                      onDoubleTap: () async {
                        showDialogWithFieldsToChangeName(item);
                      },
                      child: GradientText(
                        item.title,
                        style: const TextStyle(fontSize: 18),
                        gradient: const LinearGradient(colors: [
                          Colors.red,
                          Colors.pink,
                          Colors.purple,
                          Colors.deepPurple,
                          Colors.deepPurple,
                          Colors.indigo,
                          Colors.blue,
                          Colors.lightBlue,
                          Colors.cyan,
                          Colors.teal,
                          Colors.green,
                          Colors.lightGreen,
                          Colors.lime,
                          Colors.yellow,
                          Colors.amber,
                          Colors.orange,
                          Colors.deepOrange,
                        ]),
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(
                  height: 4,
                );
              },
            ),
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

class GradientText extends StatelessWidget {
  const GradientText(
      this.text, {
        required this.gradient,
        this.style,
      });

  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}