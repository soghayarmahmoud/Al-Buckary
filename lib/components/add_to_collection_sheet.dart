import 'package:flutter/material.dart';
import 'package:buck/database_helper.dart';
import 'package:buck/models/collection.dart';
import 'package:buck/models/hadith.dart';
import 'package:buck/services/notification_service.dart';

class AddToCollectionSheet extends StatefulWidget {
  final Hadith hadith;

  const AddToCollectionSheet({super.key, required this.hadith});

  @override
  State<AddToCollectionSheet> createState() => _AddToCollectionSheetState();
}

class _AddToCollectionSheetState extends State<AddToCollectionSheet> {
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
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('إنشاء مجموعة جديدة'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'اسم المجموعة'),
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
                    Colors.blue.toARGB32(),
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

  Future<void> _addToCollection(Collection collection) async {
    await _dbHelper.addHadithToCollection(collection.id!, widget.hadith.id);
    if (!mounted) return;
    Navigator.pop(context);
    NotificationService.showSuccess(context, 'تمت الإضافة إلى ${collection.name} ✅');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إضافة إلى مجموعة',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _createCollection,
                tooltip: "إنشاء مجموعة جديدة",
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _collections.isEmpty
                    ? const Center(child: Text("لا توجد مجموعات. أضف واحدة!"))
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
                              onTap: () => _addToCollection(collection),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
