import 'package:flutter/material.dart';
import 'classes/category.dart';
import 'CategoryItemsWidget.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:to_do_app/classes/item.dart';
import 'boxes.dart';

class ListingCategories extends StatefulWidget {
  const ListingCategories({Key? key, required this.categories})
      : super(key: key);
  final List<Category> categories;

  @override
  State<ListingCategories> createState() => _ListingCategoriesState();
}

class _ListingCategoriesState extends State<ListingCategories> {
  var nameController = TextEditingController();



  void showDialogWithFieldsToChangeName(Category oldCategory) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: Text('Change \'${oldCategory.title}\''),
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
                        oldCategory.title = oldCategory.title;
                      } else {
                        oldCategory.title = nameController.text;
                      }
                      nameController.text = '';
                      oldCategory.save();
                    });

                    Navigator.of(context).pop();
                  })
            ],
          );
        });
  }

  //extends HiveObject'den geliyor.
  void deleteCategory(Category category) {
    category.delete();

    //When we delete category, it also deletes its children.
    final items = Boxes.getItems().values.where((Item) => Item.categoryKey == category.key).toList().cast<Item>();
    for (var item in items) {
      //print(item.title);
      Boxes.getItems().delete(item.key);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Categories"),
        backgroundColor: Colors.purple.shade400,
      ),
      body: Center(
        child: ListView.separated(
          // Let the ListView know how many items it needs to build.
          itemCount: widget.categories.length,
          // Provide a builder function. This is where the magic happens.
          // Convert each item into a widget based on the type of item it is.
          itemBuilder: (context, index) {
            final item = widget.categories[index];

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
                  //widget.categories.removeAt(index);
                  deleteCategory(widget.categories.elementAt(index));
                });

                // Then show a snackbar.
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('$item deleted'),
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
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            CategoryItems(title: item.title, categoryKey: item.key)));
                  },
                  onDoubleTap: () async {
                    showDialogWithFieldsToChangeName(item);
                  },
                  child: GradientText(
                    item.title,
                    style: const TextStyle(fontSize: 25),
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
              height: 5,
            );
          },
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