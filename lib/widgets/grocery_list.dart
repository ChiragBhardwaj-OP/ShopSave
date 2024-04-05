import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';

import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_items.dart';

import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems =
      []; // this is list created of type GroceryItem class so currently have all the attributes.

  var _isLoading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _loadItems();
  } // init state helps us load when the app starts

  void _loadItems() async {
    final url = Uri.https(
        'shoppinglist-1651f-default-rtdb.firebaseio.com', 'shoppingList.json');

    final response = await http.get(url);

    if (response.statusCode >= 400) {
      setState(() {
        _error = 'Failed to fetch data try again later.';
      });
    }

    if (response.body == 'null') {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final List<GroceryItem> loadedItems =
        []; // after looping responses will be collected here.

    final Map<String, dynamic> listData = json.decode(response
        .body); //listData receives the response and decode it and the type is also Map<String, dynamic>
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == item.value['category'])
          .value;
      loadedItems.add(
        GroceryItem(
          category: category,
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
        ),
      );
    } // to convert json to usable map type we are looping through.
    setState(() {
      _groceryItems = loadedItems;
      _isLoading = false;
    });
  }

  _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (context) => const NewItems(),
      ),
    );
    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }
  //<GroceryItem> this is added later to tell the function which kind of data is coming back.

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    final url = Uri.https('shoppinglist-1651f-default-rtdb.firebaseio.com',
        'shoppingList/${item.id}.json'); // we need to specify the unique id to delete, so we used injection method using ${}.

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
      });
    }

    setState(() {
      _groceryItems.remove(item);
    });
  } // this function takes an GroceryItem type value and removes it and runs the build function again.

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('No Items added yet!'),
    );
    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length, //to render the full list.
        itemBuilder: (ctx, index) => Dismissible(
          onDismissed: (direction) {
            _removeItem(_groceryItems[
                index]); // we have to pass the grocery item in this function so it passes the parameter to the _removeItem function to finally remove the item from the list.
          },
          key: ValueKey(_groceryItems[index]
              .id), // dismissible require a unique key to identify the item.
          child: ListTile(
            title: Text(_groceryItems[index]
                .name), //access the list and then by index its properties.

            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index]
                  .category
                  .color, // in groceryItem category contains color.
            ),

            trailing: Text(_groceryItems[index].quantity.toString()),
          ),
        ),
      );
    }

    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Grociries'),
          actions: [
            IconButton(onPressed: _addItem, icon: const Icon(Icons.add))
          ],
        ),
        body: content);
  }
}
