import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  final reorderController = TextEditingController();

  final supabase = Supabase.instance.client;

  List<dynamic> suppliers = [];
  String? selectedSupplierId;

  @override
  void initState() {
    super.initState();
    fetchSuppliers();
  }

  Future<void> fetchSuppliers() async {
    final response =
        await supabase.from('suppliers').select().order('created_at');

    setState(() {
      suppliers = response;
    });
  }

  Future<void> saveItem() async {
    await supabase.from('inventory_items').insert({
      'name': nameController.text.trim(),
      'quantity': int.parse(quantityController.text.trim()),
      'reorder_level': int.parse(reorderController.text.trim()),
      'supplier_id': selectedSupplierId,
    });

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Inventory Item")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Item Name"),
            ),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Quantity"),
            ),
            TextField(
              controller: reorderController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Reorder Level"),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: selectedSupplierId,
              hint: const Text("Select Supplier"),
              items: suppliers.map((supplier) {
                return DropdownMenuItem<String>(
                  value: supplier['id'],
                  child: Text(supplier['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSupplierId = value;
                });
              },
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveItem,
              child: const Text("Save Item"),
            ),
          ],
        ),
      ),
    );
  }
}
