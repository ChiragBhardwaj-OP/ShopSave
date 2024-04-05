import 'package:shopping_list/models/category.dart';
//import 'package:flutter/material.dart';

class GroceryItem {
  const GroceryItem(
      {required this.category,
      required this.id,
      required this.name,
      required this.quantity});

  final String id;
  final String name;
  final int quantity;
  final Category category;
}
