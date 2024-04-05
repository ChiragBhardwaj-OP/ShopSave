import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';

import 'package:http/http.dart' as http;
import 'package:shopping_list/models/grocery_item.dart'; // to work with firebase we have installed 'flutter pub add http', we now add 'as http' to make our work more simple as it would get all the properties in a kinda object which is easy to use.

class NewItems extends StatefulWidget {
  const NewItems({super.key});
  @override
  State<NewItems> createState() {
    return _NewItemsState();
  }
}

class _NewItemsState extends State<NewItems> {
  final _formKey = GlobalKey<
      FormState>(); //we need to create a formkey to access the validators of the form this key will be used as a key in form to maintain the internal state of the form intact which is very necessary.it is a genric key so we need to state that it will be used for <formState>.

  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;
  var _isSending = false;

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      // this line of code will validate all the validators when add item is pressed.

      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });
    } // it will save the values and work on trigger of onSave function, this is put in condition because validation gives a bool value now it will save the values if it is valid only.

    final url = Uri.https('shoppinglist-1651f-default-rtdb.firebaseio.com',
        'shoppingList.json'); // first we have created a url variable using this syntax, url given on firebase project, after coma we give a path of our choice just add .json

    //** we are using async and await to get the future response about success or failure.

    final response = await http.post(
      url,
      headers: {
        'Content-type': 'application/json',
      }, //post request is created by this passing a map for firebase to identify.
      body: json.encode(
        {
          'name': _enteredName,
          'quantity': _enteredQuantity,
          'category': _selectedCategory.title,
        }, // dont need to add id as firebase will generate a unique id.
      ),
    ); // last step is to add a body which carries a map of the data which we want to post. for that json.encode function is used provided by dart:convert package.

    final Map<String, dynamic> resData = json.decode(response.body);

    if (!context.mounted) {
      return;
    } // with await flutter gives waring that context might not be the same so if context is not mounted we return.
    Navigator.of(context).pop(GroceryItem(
        category: _selectedCategory,
        id: resData['name'],
        name: _enteredName,
        quantity: _enteredQuantity));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add an Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey, //global key object defines above.
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text('Name'),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Must be between 1 and 50 characters';
                  } // trim() function helps remove unnecessary blank spaces before checking the conditions.
                  return null;
                },
                onSaved: (value) {
                  _enteredName = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    //it is necessary to wrap textFormField in expanded because we are using this in a row and textfield takes up a very wide space which caluses rendering error.
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Quantity must be positive';
                        } //we use tryparse because it was in string and to check in int we need to use that.
                        return null;
                      },

                      initialValue:
                          _enteredQuantity.toString(), //can be only in string

                      onSaved: (value) {
                        _enteredQuantity = int.parse(
                            value!); // value is always in int so we use parse to have in int.
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    //same reason to wrap as textFormField.
                    child: DropdownButtonFormField(
                      value:
                          _selectedCategory, // this value parameter must be updated everytime the selection is made.
                      items: [
                        for (final category in categories
                            .entries) //beacuse categories is a map we have to use entries to loop through it, for loop cant work on map so it kinda cinverts that in list.
                          DropdownMenuItem(
                            value: category
                                .value, // it is used to store the value which we will use to pass in on pressed
                            child: Row(
                              children: [
                                Container(
                                    height: 16,
                                    width: 16,
                                    color: category.value.color),
                                const SizedBox(
                                  width: 6,
                                ),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        }); // we need to set the value everytime the category is changed.
                      }, //we have passed value to onpressed now it will receieve the value which we can later use.
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSending
                        ? null
                        : () {
                            _formKey.currentState!
                                .reset(); // reset function is provided with the formkey.
                          },
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: _isSending ? null : _saveItem,
                    child: _isSending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Add item'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
