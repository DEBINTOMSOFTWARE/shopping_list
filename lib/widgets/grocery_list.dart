import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItem = [];
  var _isLoading = true;
  String? _isError;

  @override
  void initState() {
    super.initState();
    _loadGroceryItems();
  }

  void _loadGroceryItems() async {
    final url = Uri.https(
        'shopping-list-2e353-default-rtdb.firebaseio.com', 'shoping-list.json');

    try {
      final response = await http.get(url);
      print(response.body);
      print(response.statusCode);
      if (response.statusCode >= 400) {
        setState(() {
          _isError = 'Failed to fetch data. Please try again later';
        });
      }
      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
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
      setState(() {
        _groceryItem = loadedGroceryItems;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isError = 'Something went wrong!. Please try again later';
      });
    }
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
    Widget content = const Center(child: Text('No Items Added'));

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groceryItem.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItem.length,
        itemBuilder: ((context, index) => Dismissible(
              onDismissed: (direction) {
                _removeItem(_groceryItem[index]);
              },
              key: ValueKey(_groceryItem[index].id),
              child: ListTile(
                title: Text(_groceryItem[index].name),
                leading: Container(
                  width: 24,
                  height: 24,
                  color: _groceryItem[index].category.color,
                ),
                trailing: Text(_groceryItem[index].quantity.toString()),
              ),
            )),
      );
    }

    if (_isError != null) {
      content = Center(
        child: Text(_isError!),
      );
    }

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
        body: content);
  }
}
