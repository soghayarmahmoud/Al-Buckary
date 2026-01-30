import 'package:flutter/material.dart';
import 'package:buck/components/custom_appbar.dart';
import 'package:buck/database_helper.dart';
import 'package:buck/models/hadith.dart';
import 'package:buck/models/chaper.dart';
import 'package:buck/components/hadith_card.dart';
import 'package:buck/components/banner_ad_widget.dart';

class HadithListPage extends StatefulWidget {
  final Chapter chapter;
  const HadithListPage({super.key, required this.chapter});

  @override
  State<HadithListPage> createState() => _HadithListPageState();
}

class _HadithListPageState extends State<HadithListPage> {
  List<Hadith> _allHadiths = [];
  List<Hadith> _filteredHadiths = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadHadiths();
    _searchController.addListener(_filterHadiths);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterHadiths);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHadiths() async {
    try {
      final hadiths = await DatabaseHelper.instance.getHadiths(widget.chapter.id);
      if (!mounted) return;
      setState(() {
        _allHadiths = hadiths;
        _filteredHadiths = hadiths;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _normalizeArabic(String text) {
    return text.replaceAll(RegExp(r'[\u064B-\u0652]'), '');
  }

  void _filterHadiths() {
    final query = _normalizeArabic(_searchController.text.toLowerCase());
    setState(() {
      if (query.isEmpty) {
        _filteredHadiths = _allHadiths;
      } else {
        _filteredHadiths = _allHadiths.where((hadith) {
          final normalizedText = _normalizeArabic(hadith.text.toLowerCase());
          return normalizedText.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.chapter.title),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث في الأحاديث...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(child: Text('حدث خطأ: $_errorMessage'))
                    : _filteredHadiths.isEmpty && _searchController.text.isNotEmpty
                        ? const Center(child: Text('لا توجد نتائج بحث'))
                        : ListView.builder(
                            itemCount: _filteredHadiths.length,
                            itemBuilder: (context, index) {
                              final hadith = _filteredHadiths[index];
                              return HadithCard(
                                hadith: hadith,
                                highlightQuery: _searchController.text,
                                onTap: () {},
                              );
                            },
                          ),
          ),
          // Banner Ad at the bottom
          const BannerAdWidget(),
        ],
      ),
    );
  }
}
