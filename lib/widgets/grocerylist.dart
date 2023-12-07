import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryListNew extends StatefulWidget {
  const GroceryListNew({super.key});

  @override
  State<GroceryListNew> createState() => _GroceryListNewState();
}

class _GroceryListNewState extends State<GroceryListNew> {
  List<GroceryItem> _groceryItem = [];
  late Future<List<GroceryItem>> _loadedGroceryItems;

  @override
  void initState() {
    super.initState();
    _loadedGroceryItems = _loadGroceryItems();
  }

  Future<List<GroceryItem>> _loadGroceryItems() async {
    final url = Uri.https(
        'shopping-list-2e353-default-rtdb.firebaseio.com', 'shoping-list.json');
    final response = await http.get(url);
    print(response.body);
    print(response.statusCode);

    if (response.statusCode >= 400) {
      throw Exception('Failed to fetch grocery items. Please try again');
    }
    if (response.body == 'null') {
      return [];
    }

    final Map<String, dynamic> loadGroceryData = json.decode(response.body);
    print(loadGroceryData);
    final List<GroceryItem> loadedGroceryItems = [];
    for (final item in loadGroceryData.entries) {
      final category = categories.entries
          .firstWhere((categoryItem) =>
              categoryItem.value.title == item.value['category'])
          .value;
      loadedGroceryItems.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category));
    }
    return loadedGroceryItems;
  }

  void _addNewItem() async {
    final result = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const NewItem()));
    setState(() {
      _groceryItem.add(result);
    });
  }

  void _removeItem(GroceryItem groceryItem) async {
    final index = _groceryItem.indexOf(groceryItem);
    setState(() {
      _groceryItem.remove(groceryItem);
    });
    final url = Uri.https('shopping-list-2e353-default-rtdb.firebaseio.com',
        'shoping-list/${groceryItem.id}.json');
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      setState(() {
        _groceryItem.insert(index, groceryItem);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Shopping List'),
          actions: [
            IconButton(
              onPressed: _addNewItem,
              icon: const Icon(Icons.add),
            )
          ],
        ),
        body: FutureBuilder(
            future: _loadedGroceryItems,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                Center(
                  child: Text(snapshot.error.toString()),
                );
              }

              if (snapshot.data!.isEmpty) {
                const Center(child: Text('No items ddded yet.'));
              }

              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: ((context, index) => Dismissible(
                      onDismissed: (direction) {
                        _removeItem(snapshot.data![index]);
                      },
                      key: ValueKey(snapshot.data![index].id),
                      child: ListTile(
                        title: Text(snapshot.data![index].name),
                        leading: Container(
                          width: 24,
                          height: 24,
                          color: snapshot.data![index].category.color,
                        ),
                        trailing: Text(snapshot.data![index].quantity.toString()),
                      ),
                    )),
              );
            }));
  }
}
