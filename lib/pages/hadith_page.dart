// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';

// import 'package:buck/components/custom_appbar.dart';
// import 'package:buck/database_helper.dart';
// import 'package:buck/models/hadith.dart';
// import 'package:buck/models/chaper.dart';
// import 'package:buck/providers/favorit_provider.dart';

// class HadithPage extends StatefulWidget {
//   final Chapter chapter;

//   const HadithPage({
//     super.key,
//     required this.chapter,
//   });

//   @override
//   State<HadithPage> createState() => _HadithPageState();
// }

// class _HadithPageState extends State<HadithPage> {
//   final DatabaseHelper _dbHelper = DatabaseHelper.instance;
//   late Future<List<Hadith>> _allHadiths;
//   List<Hadith> _filteredHadiths = [];
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _allHadiths = _dbHelper.getHadiths(widget.chapter.id);
//     _searchController.addListener(_filterHadiths);
//   }

//   @override
//   void dispose() {
//     _searchController.removeListener(_filterHadiths);
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _filterHadiths() async {
//     final allHadiths = await _allHadiths;
//     final query = _searchController.text.toLowerCase();

//     setState(() {
//       if (query.isEmpty) {
//         _filteredHadiths = allHadiths;
//       } else {
//         _filteredHadiths = allHadiths.where((hadith) {
//           return hadith.text.toLowerCase().contains(query);
//         }).toList();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(title: widget.chapter.title),
//       body: FutureBuilder<List<Hadith>>(
//         future: _allHadiths,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(
//                 child: Text('Error: ${snapshot.error}',
//                     style: const TextStyle(fontSize: 18)));
//           }
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(
//                 child: Text('لا توجد أحاديث في هذا الباب.',
//                     style: TextStyle(fontSize: 18)));
//           }

//           if (_filteredHadiths.isEmpty && _searchController.text.isEmpty) {
//             _filteredHadiths = snapshot.data!;
//           }

//           return Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: TextField(
//                   controller: _searchController,
//                   decoration: InputDecoration(
//                     hintText: 'ابحث في الأحاديث...',
//                     prefixIcon: const Icon(Icons.search),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(25.0),
//                       borderSide: BorderSide.none,
//                     ),
//                     filled: true,
//                     fillColor: Colors.grey.shade200,
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: _filteredHadiths.isEmpty && _searchController.text.isNotEmpty
//                     ? const Center(child: Text('لا توجد نتائج مطابقة.'))
//                     : ListView.builder(
//                         itemCount: _filteredHadiths.length,
//                         itemBuilder: (context, index) {
//                           final hadith = _filteredHadiths[index];
//                           return HadithCard(hadith: hadith);
//                         },
//                       ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// class HadithCard extends StatelessWidget {
//   final Hadith hadith;

//   const HadithCard({super.key, required this.hadith});

//   @override
//   Widget build(BuildContext context) {
//     final favoritesProvider = Provider.of<FavoritesProvider>(context);
//     final isFavorite = favoritesProvider.isFavorite(hadith.id);

//     return Card(
//       elevation: 1.5,
//       margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "${hadith.id} - ${hadith.text}",
//               textDirection: TextDirection.rtl,
//               style: const TextStyle(fontSize: 18, height: 1.7),
//             ),
//             const SizedBox(height: 15),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.copy),
//                   onPressed: () {
//                     Clipboard.setData(ClipboardData(text: hadith.text));
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('تم النسخ')),
//                     );
//                   },
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.share),
//                   onPressed: () {
//                     Share.share(hadith.text);
//                   },
//                 ),
//                 IconButton(
//                   icon: Icon(
//                     isFavorite ? Icons.favorite : Icons.favorite_border,
//                     color: isFavorite ? Colors.red : null,
//                   ),
//                   onPressed: () {
//                     favoritesProvider.toggleFavorite(hadith);
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:buck/components/custom_appbar.dart';
import 'package:buck/database_helper.dart';
import 'package:buck/models/hadith.dart';
import 'package:buck/models/chaper.dart';
import 'package:buck/providers/favorit_provider.dart';
import 'package:buck/components/notes_sheet.dart';
import 'package:buck/components/add_to_collection_sheet.dart';
import 'package:buck/components/smart_share_dialog.dart';
import 'package:buck/services/notification_service.dart';

class HadithPage extends StatefulWidget {
  final Chapter chapter;

  const HadithPage({
    super.key,
    required this.chapter,
  });

  @override
  State<HadithPage> createState() => _HadithPageState();
}

class _HadithPageState extends State<HadithPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late Future<List<Hadith>> _allHadiths;
  List<Hadith> _filteredHadiths = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _allHadiths = _dbHelper.getHadiths(widget.chapter.id);
    _searchController.addListener(_filterHadiths);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterHadiths);
    _searchController.dispose();
    super.dispose();
  }

  void _filterHadiths() async {
    final allHadiths = await _allHadiths;
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredHadiths = allHadiths;
      } else {
        _filteredHadiths = allHadiths.where((hadith) {
          return hadith.text.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  TextSpan _buildHighlightedText(String text, String query, BuildContext context) {
    if (query.isEmpty) {
      return TextSpan(text: text);
    }
    final normalizedText = text.toLowerCase();
    final normalizedQuery = query.toLowerCase();
    
    final List<TextSpan> spans = [];
    int start = 0;
    while (true) {
      final int indexOfMatch = normalizedText.indexOf(normalizedQuery, start);
      if (indexOfMatch == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      spans.add(TextSpan(text: text.substring(start, indexOfMatch)));
      spans.add(TextSpan(
        text: text.substring(indexOfMatch, indexOfMatch + normalizedQuery.length),
        style: TextStyle(
          backgroundColor: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.5),
          fontWeight: FontWeight.bold,
        ),
      ));
      start = indexOfMatch + normalizedQuery.length;
    }
    return TextSpan(children: spans);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.chapter.title),
      body: FutureBuilder<List<Hadith>>(
        future: _allHadiths,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(fontSize: 18)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('لا توجد أحاديث في هذا الباب.',
                    style: TextStyle(fontSize: 18)));
          }

          if (_filteredHadiths.isEmpty && _searchController.text.isEmpty) {
            _filteredHadiths = snapshot.data!;
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'ابحث في الأحاديث...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                  ),
                ),
              ),
              Expanded(
                child: _filteredHadiths.isEmpty && _searchController.text.isNotEmpty
                    ? const Center(child: Text('لا توجد نتائج مطابقة.'))
                    : ListView.builder(
                        itemCount: _filteredHadiths.length,
                        itemBuilder: (context, index) {
                          final hadith = _filteredHadiths[index];
                          return HadithCard(
                            hadith: hadith,
                            highlightQuery: _searchController.text,
                            highlightBuilder: _buildHighlightedText,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class HadithCard extends StatelessWidget {
  final Hadith hadith;
  final String highlightQuery;
  final Function(String, String, BuildContext) highlightBuilder;

  const HadithCard({
    super.key,
    required this.hadith,
    required this.highlightQuery,
    required this.highlightBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFavorite = favoritesProvider.isFavorite(hadith.id);

    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              textDirection: TextDirection.rtl,
              text: highlightBuilder("${hadith.id} - ${hadith.text}", highlightQuery, context),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: hadith.text));
                    NotificationService.showInfo(context, 'تم نسخ الحديث 📋');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.copy_all),
                            title: const Text('نسخ النص'),
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: hadith.text));
                              Navigator.pop(context);
                              NotificationService.showInfo(context, 'تم نسخ الحديث 📋');
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.text_fields),
                            title: const Text('مشاركة كنص'),
                            onTap: () {
                              Navigator.pop(context);
                              Share.share(hadith.text);
                              NotificationService.showInfo(context, 'جاري مشاركة الحديث 📤');
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.image),
                            title: const Text('مشاركة كصورة (Smart Share)'),
                            onTap: () {
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (context) => SmartShareDialog(hadith: hadith),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.note_add_outlined),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => NotesSheet(hadith: hadith),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_add_outlined),
                  onPressed: () {
                     showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => AddToCollectionSheet(hadith: hadith),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Theme.of(context).iconTheme.color,
                  ),
                  onPressed: () {
                    favoritesProvider.toggleFavorite(hadith, context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
