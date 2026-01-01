import 'package:flutter/material.dart';
import 'package:orderly/old/core/config/user_context.dart';
import 'package:orderly/old/features/admin/table_management/table_models.dart';
import '../../../core/config/supabase_client.dart';

class TablePage extends StatefulWidget {
  const TablePage({super.key});

  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  List<RestaurantTable> tables = [];
  bool loading = true;
  UserContext? user = UserContext.instance;

  @override
  void initState() {
    super.initState();
    fetchTables();
  }

  Future<void> fetchTables() async {
    setState(() => loading = true);

    final response = await supabase
        .from('tables')
        .select()
        .eq('restaurant_id', user!.restaurantId)
        .order('id');

    tables = (response as List).map((t) => RestaurantTable.fromMap(t)).toList();

    if (!mounted) return;
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestione Tavoli')),
      body: loading ? _buildLoadingIndicator() : _buildTableList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTableDialog(
          title: 'Nuovo Tavolo',
          onSave: (name, seats) async {
            await supabase.from('tables').insert({
              'restaurant_id': user!.restaurantId,
              'name': name,
              'seats': seats,
            });
            fetchTables();
          },
        ),
        tooltip: 'Aggiungi Tavolo',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildTableList() {
    return ListView.builder(
      itemCount: tables.length,
      itemBuilder: (context, index) {
        final table = tables[index];
        return ListTile(
          title: Text(table.name),
          subtitle: table.seats != null
              ? Text('${table.seats} posti')
              : const Text('Posti non specificati'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showTableDialog(
                  title: 'Modifica Tavolo',
                  initialName: table.name,
                  initialSeats: table.seats,
                  onSave: (name, seats) async {
                    await supabase.from('tables').update({
                      'name': name,
                      'seats': seats,
                    }).eq('id', table.id);
                    fetchTables();
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final confirmed = await _confirmDeleteTable(table);
                  if (confirmed) _deleteTable(table);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _confirmDeleteTable(RestaurantTable table) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: Text(
          'Sei sicuro di voler eliminare il tavolo "${table.name}"?\n'
              'Assieme al tavolo verrà eliminato l\'ordine associato se presente.\n\n'
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
  }

  Future<void> _deleteTable(RestaurantTable table) async {
    try {
      await supabase.from('tables').delete().eq('id', table.id);
      fetchTables();
    } catch (e) {
      _showSnackBar('Errore eliminazione tavolo: $e');
    }
  }

  void _showTableDialog({
    required String title,
    String? initialName,
    int? initialSeats,
    required Future<void> Function(String name, int? seats) onSave,
  }) {
    final nameController = TextEditingController(text: initialName);
    final seatsController = TextEditingController(text: initialSeats?.toString());
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
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome tavolo'),
              ),
              TextField(
                controller: seatsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Posti'),
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
                final name = nameController.text.trim();
                final seats = seatsController.text.isEmpty
                    ? null
                    : int.tryParse(seatsController.text.trim());

                String? validationError = _validateTableName(name, initialName);

                if (validationError != null) {
                  setState(() => errorMessage = validationError);
                } else {
                  setState(() => errorMessage = null);
                  await onSave(name, seats);
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('Salva'),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateTableName(String name, [String? initialName]) {
    if (name.isEmpty) {
      return 'Il nome del tavolo non può essere vuoto';
    }

    final exists = tables.any((t) =>
    t.name.toLowerCase() == name.toLowerCase() &&
        t.name.toLowerCase() != initialName?.toLowerCase());
    if (exists) {
      return 'Esiste già un tavolo con questo nome';
    }

    return null;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}