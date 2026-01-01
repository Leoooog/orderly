import 'package:flutter/material.dart';
import 'package:orderly/old/core/config/user_context.dart';
import '../../../core/config/supabase_client.dart';
import 'menu_models.dart';

class DishPage extends StatefulWidget {
  const DishPage({super.key});

  @override
  State<DishPage> createState() => _DishPageState();
}

class _DishPageState extends State<DishPage> {
  List<Category> categories = [];
  bool loading = true;
  UserContext? user = UserContext.instance;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => loading = true);

    try {
      await _fetchCategoriesAndDishes();
    } catch (e) {
      _showSnackBar('Errore durante il caricamento: $e');
    }

    if (mounted) setState(() => loading = false);
  }

  Future<void> _fetchCategoriesAndDishes() async {
    final catResponse = await supabase
        .from('categories')
        .select()
        .eq('restaurant_id', user!.restaurantId)
        .order('name', ascending: true);

    categories = (catResponse as List).map((c) => Category.fromMap(c)).toList();

    final dishResponse = await supabase
        .from('dishes')
        .select()
        .eq('restaurant_id', user!.restaurantId);

    final allDishes =
    (dishResponse as List).map((d) => Dish.fromMap(d)).toList();

    for (var cat in categories) {
      final catDishes = allDishes.where((d) => d.categoryId == cat.id).toList();
      catDishes.sort((a, b) => a.name.compareTo(b.name));
      cat.dishes = catDishes;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Piatti')),
      body: loading ? _buildLoadingIndicator() : _buildDishList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDishDialog(
          title: 'Nuovo Piatto',
          onSave: (name, description, price, categoryId) async {
            await supabase.from("dishes").insert({
              'name': name,
              'description': description,
              'price': price,
              'category_id': categoryId,
              'restaurant_id': user!.restaurantId,
            });
            fetchData();
          },
        ),
        tooltip: 'Aggiungi Piatto',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildDishList() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryTile(category);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTile(Category category) {
    return ExpansionTile(
      title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: category.dishes.map((dish) => _buildDishTile(dish)).toList(),
    );
  }

  Widget _buildDishTile(Dish dish) {
    return ListTile(
      title: Text(dish.name),
      subtitle: Text('${dish.description} - €${dish.price.toStringAsFixed(2)}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showDishDialog(
              title: 'Modifica Piatto',
              initialName: dish.name,
              initialDescription: dish.description,
              initialPrice: dish.price.toString(),
              initialCategoryId: dish.categoryId.toString(),
              onSave: (name, description, price, categoryId) async {
                await supabase.from('dishes').update({
                  'name': name,
                  'description': description,
                  'price': price,
                  'category_id': categoryId,
                }).eq('id', dish.id);
                fetchData();
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDeleteDish(dish),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteDish(Dish dish) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: Text(
          'Sei sicuro di voler eliminare il piatto "${dish.name}"?\n\nQuesta operazione è irreversibile.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    ) ?? false;

    if (confirmed) {
      await _deleteDish(dish);
    }
  }

  Future<void> _deleteDish(Dish dish) async {
    try {
      await supabase.from('dishes').delete().eq('id', dish.id);
      fetchData();
    } catch (e) {
      _showSnackBar('Errore eliminazione piatto: $e');
    }
  }

  void _showDishDialog({
    required String title,
    String? initialName,
    String? initialDescription,
    String? initialPrice,
    String? initialCategoryId,
    required Future<void> Function(String name, String description, double price, String categoryId) onSave,
  }) {
    final nameController = TextEditingController(text: initialName);
    final descController = TextEditingController(text: initialDescription);
    final priceController = TextEditingController(text: initialPrice);
    String? selectedCategory = initialCategoryId;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Descrizione'),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Prezzo'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  items: categories
                      .map((c) => DropdownMenuItem(
                    value: c.id.toString(),
                    child: Text(c.name),
                  ))
                      .toList(),
                  onChanged: (v) => setState(() => selectedCategory = v),
                  hint: const Text('Categoria'),
                ),
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final description = descController.text.trim();
                final price = double.tryParse(priceController.text.trim()) ?? 0;

                if (name.isEmpty || price <= 0 || selectedCategory == null) {
                  setState(() => errorMessage = 'Compila tutti i campi correttamente');
                  return;
                }

                setState(() => errorMessage = null);
                await onSave(name, description, price, selectedCategory!);
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Salva'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}