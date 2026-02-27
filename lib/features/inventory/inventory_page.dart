import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> items = [];

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    final response = await supabase
        .from('inventory_items')
        .select()
        .order('created_at');

    setState(() {
      items = response;
    });
  }

  Future<void> addItem() async {
    await supabase.from('inventory_items').insert({
      'name': 'Sample Item',
      'quantity': 10,
      'reorder_level': 5,
    });

    fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inventory")),
      floatingActionButton: FloatingActionButton(
        onPressed: addItem,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isLowStock =
              item['quantity'] <= item['reorder_level'];

          return ListTile(
            title: Text(item['name']),
            subtitle: Text("Qty: ${item['quantity']}"),
            trailing: isLowStock
                ? const Icon(Icons.warning, color: Colors.red)
                : null,
          );
        },
      ),
    );
  }
}
