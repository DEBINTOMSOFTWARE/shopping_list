import 'package:flutter/material.dart';

import 'package:shopping_list/models/category.dart';

const categories = {
  Categories.vegetables: ShopingListCategory(
    'Vegetables',
    Color.fromARGB(255, 0, 255, 128),
  ),
  Categories.fruit: ShopingListCategory(
    'Fruit',
    Color.fromARGB(255, 145, 255, 0),
  ),
  Categories.meat: ShopingListCategory(
    'Meat',
    Color.fromARGB(255, 255, 102, 0),
  ),
  Categories.dairy: ShopingListCategory(
    'Dairy',
    Color.fromARGB(255, 0, 208, 255),
  ),
  Categories.carbs: ShopingListCategory(
    'Carbs',
    Color.fromARGB(255, 0, 60, 255),
  ),
  Categories.sweets: ShopingListCategory(
    'Sweets',
    Color.fromARGB(255, 255, 149, 0),
  ),
  Categories.spices: ShopingListCategory(
    'Spices',
    Color.fromARGB(255, 255, 187, 0),
  ),
  Categories.convenience: ShopingListCategory(
    'Convenience',
    Color.fromARGB(255, 191, 0, 255),
  ),
  Categories.hygiene: ShopingListCategory(
    'Hygiene',
    Color.fromARGB(255, 149, 0, 255),
  ),
  Categories.other: ShopingListCategory(
    'Other',
    Color.fromARGB(255, 0, 225, 255),
  ),
};