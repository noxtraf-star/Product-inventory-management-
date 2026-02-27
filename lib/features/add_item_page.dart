import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_item_page.dart';

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

  Future<void> deleteItem(String id) async {
    await supabase.from('inventory_items').delete().eq('id', id);
    fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inventory")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddItemPage()),
          );
          fetchItems();
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isLowStock =
              item['quantity'] <= item['reorder_level'];

          return Card(
            child: ListTile(
              title: Text(item['name']),
              subtitle: Text(
                  "Qty: ${item['quantity']} | Reorder: ${item['reorder_level']}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLowStock)
                    const Icon(Icons.warning, color: Colors.red),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deleteItem(item['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
