
import 'package:flutter/material.dart';
import 'package:buck/database_helper.dart';
import 'package:buck/models/collection.dart';
import 'package:buck/components/custom_appbar.dart';
import 'package:buck/pages/collection_details_page.dart';

class CollectionsPage extends StatefulWidget {
  const CollectionsPage({super.key});

  @override
  State<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Collection> _collections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    final list = await _dbHelper.getCollections();
    setState(() {
      _collections = list.map((e) => Collection.fromMap(e)).toList();
      _isLoading = false;
    });
  }

  Future<void> _createCollection() async {
    final TextEditingController nameController = TextEditingController();
    Color selectedColor = Colors.blue;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('إنشاء مجموعة جديدة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم المجموعة'),
              ),
              const SizedBox(height: 10),
              // Color picker simplified for now
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                   _colorCircle(Colors.blue, (c) => selectedColor = c),
                   _colorCircle(Colors.red, (c) => selectedColor = c),
                   _colorCircle(Colors.green, (c) => selectedColor = c),
                   _colorCircle(Colors.orange, (c) => selectedColor = c),
                ],
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  await _dbHelper.createCollection(
                    nameController.text.trim(),
                    selectedColor.toARGB32(),
                  );
                  Navigator.pop(context);
                  _loadCollections();
                }
              },
              child: const Text('إنشاء'),
            ),
          ],
        );
      },
    );
  }

  Widget _colorCircle(Color color, Function(Color) onSelect) {
    return GestureDetector(
      onTap: () => onSelect(color),
      child: CircleAvatar(backgroundColor: color, radius: 15),
    );
  }

  Future<void> _deleteCollection(int id) async {
    await _dbHelper.deleteCollection(id);
    _loadCollections();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "مجموعاتي"),
      floatingActionButton: FloatingActionButton(
        onPressed: _createCollection,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _collections.isEmpty
              ? const Center(child: Text("لا توجد مجموعات بعد."))
              : ListView.builder(
                  itemCount: _collections.length,
                  itemBuilder: (context, index) {
                    final collection = _collections[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(collection.color),
                          child: const Icon(Icons.folder, color: Colors.white),
                        ),
                        title: Text(collection.name),
                        onTap: () {
                           Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CollectionDetailsPage(collection: collection),
                            ),
                          );
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCollection(collection.id!),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
