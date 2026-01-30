import 'package:flutter/material.dart';
import 'package:buck/database_helper.dart';
import 'package:buck/components/custom_appbar.dart';
import 'package:intl/intl.dart' hide TextDirection;

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllNotes();
  }

  Future<void> _loadAllNotes() async {
    final notes = await _dbHelper.getAllNotes();
    setState(() {
      _notes = notes;
      _isLoading = false;
    });
  }

  Future<void> _deleteNote(int id) async {
    await _dbHelper.deleteNote(id);
    _loadAllNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "ملاحظاتي"),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _notes.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "لا توجد ملاحظات محفوظة.",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _notes.length,
                    itemBuilder: (context, index) {
                      final note = _notes[index];
                      final date = DateTime.fromMillisecondsSinceEpoch(note['created_at']);
                      final noteColor = Color(note['color'] ?? 0xFFFFC107);
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: noteColor.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Card(
                          elevation: 0,
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: noteColor,
                              width: 2,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  noteColor.withOpacity(0.1),
                                  noteColor.withOpacity(0.05),
                                ],
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: noteColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          DateFormat('dd/MM/yyyy - HH:mm').format(date),
                                          style: TextStyle(
                                            color: noteColor.withOpacity(0.8),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'حديث #${note['hadith_id']}',
                                        style: TextStyle(
                                          color: noteColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: noteColor.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Text(
                                      note['text'],
                                      style: const TextStyle(
                                        fontSize: 15,
                                        height: 1.6,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ExpansionTile(
                                    
title: Text(
                                      "نص الحديث",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: noteColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                    tilePadding: EdgeInsets.zero,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.surface,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          note['hadith_text'],
                                          style: const TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: Colors.black54,
                                            fontSize: 14,
                                            height: 1.6,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton.icon(
                                      onPressed: () => _deleteNote(note['id']),
                                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                      label: const Text(
                                        "حذف الملاحظة",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
