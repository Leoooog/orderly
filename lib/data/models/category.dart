import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  Category(this.id, this.name, this.icon);

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      json['id'] as String,
      json['name'] as String,
      IconData(json['iconCodePoint'] as int, fontFamily: 'MaterialIcons'),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': icon.codePoint,
    };
  }
}