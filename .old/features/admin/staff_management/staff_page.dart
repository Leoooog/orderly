import 'package:flutter/material.dart';
import 'package:orderly/old/core/config/user_context.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_client.dart';
import '../../../shared/utils/helpers.dart';
import 'staff_models.dart';

class StaffPage extends StatefulWidget {
  const StaffPage({super.key});

  @override
  State<StaffPage> createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage> {
  List<Staff> staffList = [];
  bool loading = true;
  UserContext? user = UserContext.instance;
  final Map<String, bool> showPinMap = {};

  @override
  void initState() {
    super.initState();
    fetchStaff();
  }

  Future<void> fetchStaff() async {
    setState(() => loading = true);

    try {
      final response = await supabase
          .from('staff')
          .select()
          .eq('restaurant_id', user!.restaurantId)
          .order('name', ascending: true);

      staffList = (response as List).map((s) => Staff.fromMap(s)).toList();
      _initializePinVisibility();
    } catch (e) {
      _showSnackBar('Errore durante il caricamento: $e');
    }

    if (mounted) setState(() => loading = false);
  }

  void _initializePinVisibility() {
    for (var staff in staffList) {
      showPinMap[staff.id] = false;
    }
  }

  void _showAddStaffDialog() {
    final nameController = TextEditingController();
    final roles = ['Cameriere', 'Cucina'];
    String selectedRole = roles[0];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nuovo Staff'),
        content: _buildAddStaffDialogContent(nameController, roles, selectedRole),
        actions: _buildAddStaffDialogActions(nameController, selectedRole),
      ),
    );
  }

  Widget _buildAddStaffDialogContent(TextEditingController nameController, List<String> roles, String selectedRole) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Nome'),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: selectedRole,
          items: roles.map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
          onChanged: (value) => selectedRole = value!,
          decoration: const InputDecoration(labelText: 'Ruolo'),
        ),
      ],
    );
  }

  List<Widget> _buildAddStaffDialogActions(TextEditingController nameController, String selectedRole) {
    return [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Annulla'),
      ),
      TextButton(
        onPressed: () async {
          if (nameController.text.isEmpty || selectedRole.isEmpty) return;

          setState(() => loading = true);

          try {
            String pin;
            do {
              pin = generateRandomPin();
            } while (staffList.any((s) => s.pin == pin));

            await supabase.functions.invoke(
              'create_staff',
              body: {
                'name': nameController.text,
                'role': selectedRole,
                'pin': pin,
                'restaurant_id': user!.restaurantId,
              },
              headers: {
                'Authorization': 'Bearer ${supabase.auth.currentSession!.accessToken}',
                'Content-Type': 'application/json',
              },
              method: HttpMethod.post,
            );

            if (!mounted) return;
            Navigator.pop(context);
            fetchStaff();
            _showSnackBar('Staff aggiunto! PIN: $pin');
          } catch (e) {
            if (!mounted) return;
            setState(() => loading = false);
            _showSnackBar('Errore creazione staff: $e');
          }
        },
        child: const Text('Salva'),
      ),
    ];
  }

  Future<bool> _confirmDeleteStaff(Staff staff) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: Text(
          'Sei sicuro di voler eliminare ${staff.name}?\n\nQuesta operazione è irreversibile.',
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

  void _deleteStaff(Staff staff) async {
    setState(() => loading = true);

    try {
      await supabase.functions.invoke(
        'delete_staff',
        body: {'staff_id': staff.id},
        headers: {
          'Authorization': 'Bearer ${supabase.auth.currentSession!.accessToken}',
          'Content-Type': 'application/json',
        },
        method: HttpMethod.post,
      );

      if (!mounted) return;
      fetchStaff();
      _showSnackBar('Staff eliminato');
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      _showSnackBar('Errore eliminazione staff: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff')),
      body: loading ? _buildLoadingIndicator() : _buildStaffList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStaffDialog,
        tooltip: 'Aggiungi Staff',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildStaffList() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: staffList.length,
            itemBuilder: (context, index) {
              final staff = staffList[index];
              return _buildStaffTile(staff);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStaffTile(Staff staff) {
    final showPin = showPinMap[staff.id] ?? false;

    return ListTile(
      title: Text(staff.name),
      subtitle: Text(
        (staff.authUserId != user!.authUserId)
            ? '${staff.role} - PIN: ${showPin ? staff.pin : '******'}'
            : staff.role,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (staff.authUserId != user!.authUserId)
            IconButton(
              icon: Icon(showPin ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() {
                showPinMap[staff.id] = !showPin;
              }),
              tooltip: showPin ? 'Nascondi PIN' : 'Mostra PIN',
            ),
          if (staff.authUserId != user!.authUserId)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirmed = await _confirmDeleteStaff(staff);
                if (confirmed) _deleteStaff(staff);
              },
            ),
        ],
      ),
    );
  }
}