import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  Category(this.id, this.name);

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      json['id'] as String,
      json['name'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}