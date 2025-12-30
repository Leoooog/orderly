import 'package:flutter/material.dart';
import 'models/category.dart';
import 'models/extra.dart';
import 'models/menu_item.dart';
import 'models/cart_item.dart';
import 'models/table_item.dart';


final List<Category> categories = [
  Category('fav', 'Preferiti', Icons.star_outline),
  Category('drinks', 'Bevande', Icons.wine_bar),
  Category('food', 'Primi', Icons.restaurant),
  Category('main', 'Secondi', Icons.restaurant_menu),
  Category('coffee', 'Caffè', Icons.coffee),
];

final extraRucola = Extra('rucola', 'Rucola', 1.0);
final extraGrana = Extra('grana', 'Scaglie di Grana', 1.5);
final extraBufala = Extra('bufala', 'Mozz. di Bufala', 2.0);
final extraGhiaccio = Extra('ghiaccio', 'Ghiaccio a parte', 0.0);
final extraLimone = Extra('limone', 'Fetta di Limone', 0.0);

final List<MenuItem> menuItems = [
  MenuItem(
      id: 1, name: 'Acqua Nat. 50cl', price: 1.50, category: 'drinks', popular: true,
      imageUrl: 'https://images.unsplash.com/photo-1548839140-29a749e1cf4d?auto=format&fit=crop&w=150&q=80',
      ingredients: const ['Acqua oligominerale naturale'], allergens: const [],
      availableExtras: [extraGhiaccio, extraLimone]
  ),
  MenuItem(
      id: 2, name: 'Coca Cola', price: 3.00, category: 'drinks', popular: true,
      imageUrl: 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?auto=format&fit=crop&w=150&q=80',
      ingredients: const ['Acqua', 'Zucchero', 'Caffeina'], allergens: const [],
      availableExtras: [extraGhiaccio, extraLimone]
  ),
  MenuItem(
      id: 3, name: 'Spritz Aperol', price: 5.50, category: 'drinks', popular: true,
      imageUrl: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=150&q=80',
      ingredients: const ['Prosecco', 'Aperol', 'Soda'], allergens: const ['Solfiti'],
      availableExtras: [Extra('gin', 'Rinforzo Gin', 2.0)]
  ),
  MenuItem(
      id: 5, name: 'Carbonara', price: 12.00, category: 'food', popular: true,
      imageUrl: 'https://images.unsplash.com/photo-1612874742237-6526221588e3?auto=format&fit=crop&w=150&q=80',
      ingredients: const ['Spaghetti', 'Tuorlo', 'Guanciale', 'Pecorino'], allergens: const ['Glutine', 'Uova', 'Latte'],
      availableExtras: [Extra('pepe', 'Extra Pepe', 0.0)]
  ),
  MenuItem(
      id: 6, name: 'Amatriciana', price: 11.00, category: 'food', popular: false,
      imageUrl: 'https://images.unsplash.com/photo-1574868309603-c1b9aa53de63?auto=format&fit=crop&w=150&q=80',
      ingredients: const ['Bucatini', 'Pomodoro', 'Guanciale'], allergens: const ['Glutine'],
      availableExtras: [Extra('peperoncino', 'Extra Piccante', 0.0)]
  ),
  MenuItem(
      id: 8, name: 'Tagliata Manzo', price: 18.00, category: 'main', popular: true,
      imageUrl: 'https://images.unsplash.com/photo-1600891964092-4316c288032e?auto=format&fit=crop&w=150&q=80',
      ingredients: const ['Manzo', 'Rucola', 'Grana'], allergens: const ['Latte'],
      availableExtras: [extraRucola, extraGrana, Extra('patate', 'Contorno Patate', 4.0)]
  ),
  MenuItem(
      id: 10, name: 'Espresso', price: 1.20, category: 'coffee', popular: true,
      imageUrl: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=150&q=80',
      ingredients: const ['Caffè', 'Acqua'], allergens: const [],
      availableExtras: [Extra('macchiato', 'Macchiato', 0.0), Extra('corretto', 'Corretto Grappa', 1.0)]
  ),
];

// Stato Globale dei tavoli (Singleton simulation)
final List<TableItem> globalTables = List.generate(15, (i) => TableItem(
    id: i + 1,
    name: 'T${i + 1}',
    status: (i + 1) % 4 == 0 ? TableStatus.ordered : TableStatus.free,
    guests: (i + 1) % 4 == 0 ? ((i % 3) + 2) : 0,
    orders: (i + 1) % 4 == 0 ? [
      CartItem(internalId: i, id: 1, name: 'Acqua Nat. 50cl', basePrice: 1.50, qty: (i % 3) + 2),
      CartItem(internalId: i+100, id: 5, name: 'Carbonara', basePrice: 12.00, qty: (i % 2) + 1),
    ] : []
));