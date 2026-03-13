
import 'package:flutter/material.dart';
import 'package:buck/database_helper.dart';
import 'package:buck/models/hadith.dart';
import 'package:buck/models/collection.dart';
import 'package:buck/components/custom_appbar.dart';
import 'package:buck/components/hadith_card.dart';

class CollectionDetailsPage extends StatefulWidget {
  final Collection collection;

  const CollectionDetailsPage({super.key, required this.collection});

  @override
  State<CollectionDetailsPage> createState() => _CollectionDetailsPageState();
}

class _CollectionDetailsPageState extends State<CollectionDetailsPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Hadith> _hadiths = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHadiths();
  }

  Future<void> _loadHadiths() async {
    final list = await _dbHelper.getHadithsInCollection(widget.collection.id!);
    setState(() {
      _hadiths = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.collection.name),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hadiths.isEmpty
              ? const Center(child: Text("لا توجد أحاديث في هذه المجموعة."))
              : ListView.builder(
                  itemCount: _hadiths.length,
                  itemBuilder: (context, index) {
                    final hadith = _hadiths[index];
                    // Reuse HadithCard from HadithPage
                    // Note: We need to import the HighlightBuilder or just pass a simple one
                    return HadithCard(
                      hadith: hadith,
                      highlightQuery: "",
                    );
                  },
                ),
    );
  }
}
