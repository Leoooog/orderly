import 'package:flutter/material.dart';
import 'package:orderly/old/core/config/user_context.dart';
import '../../../core/config/supabase_client.dart';
import 'menu_models.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<Category> categories = [];
  bool loading = true;
  UserContext? user = UserContext.instance;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    setState(() => loading = true);

    final restaurantId = user!.restaurantId;

    final response = await supabase
        .from('categories')
        .select()
        .eq('restaurant_id', restaurantId);

    categories = (response as List).map((c) => Category.fromMap(c)).toList();

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestione Categorie')),
      body: loading ? _buildLoadingIndicator() : _buildCategoryList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        tooltip: 'Aggiungi Categoria',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildCategoryList() {
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
    return ListTile(
      title: Text(category.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditCategoryDialog(category),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDeleteCategory(category),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteCategory(Category category) async {
    final confirmed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text('Conferma eliminazione'),
            content: Text(
              'Sei sicuro di voler eliminare la categoria "${category.name}"?\n'
              'Assieme alla categoria verranno eliminati tutti i piatti.\n\n'
              'Questa operazione è irreversibile.',
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
        ) ??
        false;

    if (confirmed) {
      await _deleteCategory(category);
    }
  }

  Future<void> _deleteCategory(Category category) async {
    try {
      await supabase.from('categories').delete().eq('id', category.id);
      fetchCategories();
      _showSnackBar('Categoria eliminata');
    } catch (e) {
      _showSnackBar('Errore eliminazione categoria: $e');
    }
  }

  void _showAddCategoryDialog() {
    _showCategoryDialog(
      title: 'Nuova Categoria',
      onSave: (name) async {
        await supabase.from('categories').insert({
          'name': name,
          'restaurant_id': user!.restaurantId,
        });
        fetchCategories();
      },
    );
  }

  void _showEditCategoryDialog(Category category) {
    _showCategoryDialog(
      title: 'Modifica Categoria',
      initialName: category.name,
      onSave: (name) async {
        await supabase
            .from('categories')
            .update({'name': name}).eq('id', category.id);
        fetchCategories();
      },
    );
  }

  void _showCategoryDialog({
    required String title,
    String? initialName,
    required Future<void> Function(String name) onSave,
  }) {
    final controller = TextEditingController(text: initialName);
    String? errorMessage;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Inserisci il nome della categoria',
                ),
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () async {
                final name = controller.text.trim();
                String? validationError = _validateCategoryName(name, initialName);
                if (validationError != null) {
                  setState(() => errorMessage = validationError);
                  return;
                }
                setState(() => errorMessage = null);

                await onSave(name);
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Salva'),
            ),
          ],
        ),
      ),
    );
  }
  String? _validateCategoryName(String name, String? initialName) {
    if (name.isEmpty) {
      return 'Il nome della categoria non può essere vuoto';
    }

    final exists = categories.any((c) =>
        c.name.toLowerCase() == name.toLowerCase() &&
        c.name.toLowerCase() != initialName?.toLowerCase());
    if (exists) {
      return 'Esiste già una categoria con questo nome';
    }

    return null;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
