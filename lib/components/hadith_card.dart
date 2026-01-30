// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:flutter/services.dart';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

// import 'package:buck/models/hadith.dart';
// import 'package:buck/providers/favorit_provider.dart';
// import 'package:buck/providers/bookmarks_provider.dart';
// import 'package:buck/image_helper.dart'; // هذا الملف مسؤول عن تحويل الحديث لصورة

// class HadithCard extends StatelessWidget {
//   final Hadith hadith;
//   final String highlightQuery;
//   final VoidCallback? onTap;

//   const HadithCard({
//     super.key,
//     required this.hadith,
//     this.highlightQuery = "",
//     this.onTap,
//   });

//   Future<void> _downloadHadith(BuildContext context) async {
//     try {
//       // طلب إذن التخزين (Android فقط)
//       if (Platform.isAndroid) {
//         if (!await Permission.storage.request().isGranted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("لم يتم منح الإذن للوصول إلى التخزين")),
//           );
//           return;
//         }
//       }

//       // تحويل الحديث لصورة
//       final File imageFile = await ImageHelper.hadithToImage(hadith.text);

//       // تحديد مسار الحفظ
//       final directory = Platform.isAndroid
//           ? Directory('/storage/emulated/0/Download') // مجلد التنزيلات
//           : await getApplicationDocumentsDirectory(); // iOS / Windows / macOS

//       final savePath = File(
//           '${directory.path}/hadith_${hadith.id}_${DateTime.now().millisecondsSinceEpoch}.png');

//       await imageFile.copy(savePath.path);

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("تم حفظ الحديث كصورة في ${savePath.path}")),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("حدث خطأ أثناء تحميل الحديث كصورة")),
//       );
//       print("Download error: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final favoritesProvider = Provider.of<FavoritesProvider>(context);
//     final isFavorite = favoritesProvider.isFavorite(hadith.id);

//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Card(
//         color: Theme.of(context).cardColor,
//         margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         elevation: 4,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(16),
//           onTap: onTap,
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // نص الحديث
//                 Text(
//                   hadith.text,
//                   style: const TextStyle(fontSize: 16, height: 1.5),
//                   textAlign: TextAlign.start,
//                 ),
//                 const SizedBox(height: 12),

//                 // الأزرار
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     // مفضلة
//                     IconButton(
//                       icon: Icon(
//                         isFavorite ? Icons.favorite : Icons.favorite_border,
//                         color: isFavorite ? Colors.red : Theme.of(context).colorScheme.inversePrimary,
//                       ),
//                       onPressed: () {
//                         favoritesProvider.toggleFavorite(hadith);
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text(isFavorite
//                                 ? 'تم إزالة الحديث من المفضلة'
//                                 : 'تم إضافة الحديث إلى المفضلة'),
//                           ),
//                         );
//                       },
//                       tooltip: "مفضلة",
//                     ),

//                     // Bookmark
//                     Consumer<BookmarksProvider>(
//                       builder: (context, bookmarksProvider, child) {
//                         final isBookmarked =
//                             bookmarksProvider.getBookmark(hadith.chapterId) == hadith.id;
//                         return IconButton(
//                           icon: Icon(
//                             isBookmarked ? Icons.bookmark : Icons.bookmark_border,
//                             color: isBookmarked ? Colors.blue : Theme.of(context).colorScheme.inversePrimary,
//                           ),
//                           onPressed: () {
//                             bookmarksProvider.setBookmark(hadith.chapterId, hadith.id);
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(content: Text("تم تمييز الحديث")),
//                             );
//                           },
//                           tooltip: "تمييز",
//                         );
//                       },
//                     ),

//                     // نسخ
//                     IconButton(
//                       icon: Icon(Icons.copy, color: Theme.of(context).colorScheme.inversePrimary),
//                       onPressed: () async {
//                         await Clipboard.setData(ClipboardData(text: hadith.text));
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text("تم نسخ الحديث")),
//                         );
//                       },
//                       tooltip: "نسخ",
//                     ),

//                     // مشاركة
//                     IconButton(
//                       icon: Icon(Icons.share, color: Theme.of(context).colorScheme.inversePrimary),
//                       onPressed: () {
//                         Share.share(hadith.text, subject: "حديث شريف");
//                       },
//                       tooltip: "مشاركة",
//                     ),

//                     // تحميل كصورة
//                     IconButton(
//                       icon: Icon(Icons.download, color: Theme.of(context).colorScheme.inversePrimary),
//                       onPressed: () => _downloadHadith(context),
//                       tooltip: "تحميل كصورة",
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:async';
import 'dart:ui';

import 'package:buck/components/sharable_hadith_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:buck/models/hadith.dart';
import 'package:buck/providers/favorit_provider.dart';
import 'package:buck/providers/bookmarks_provider.dart';
import 'package:buck/image_helper.dart'; // هذا الملف مسؤول عن تحويل الحديث لصورة
import 'package:buck/themes/theme_provider.dart';
import 'package:buck/components/notes_sheet.dart';
import 'package:buck/components/add_to_collection_sheet.dart';
import 'package:buck/components/smart_share_dialog.dart';
import 'package:buck/services/notification_service.dart';

class HadithCard extends StatelessWidget {
  final Hadith hadith;
  final String highlightQuery;
  final VoidCallback? onTap;

  const HadithCard({
    super.key,
    required this.hadith,
    this.highlightQuery = "",
    this.onTap,
  });

  Future<void> _downloadHadith(BuildContext context) async {
    try {
      // طلب إذن التخزين (Android فقط)
      if (Platform.isAndroid) {
        if (!await Permission.storage.request().isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("لم يتم منح الإذن للوصول إلى التخزين"),
            ),
          );
          return;
        }
      }

      // تحويل الحديث لصورة
      final themeProvider = context.read<ThemeProvider>();
      final File imageFile = await ImageHelper.hadithToImage(
        hadith.text,
        primaryColor: themeProvider.primaryColor,
      );

      // تحديد مسار الحفظ
      final directory = Platform.isAndroid
          ? Directory('/storage/emulated/0/Download') // مجلد التنزيلات
          : await getApplicationDocumentsDirectory(); // iOS / Windows / macOS

      final savePath = File(
        '${directory.path}/hadith_${hadith.id}_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      await imageFile.copy(savePath.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("تم حفظ الحديث كصورة في ${savePath.path}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("حدث خطأ أثناء تحميل الحديث كصورة")),
      );
      print("Download error: $e");
    }
  }

  Future<void> _downloadStyledHadith(
    BuildContext context,
    Hadith hadith,
  ) async {
    try {
      // 1- اعمل GlobalKey للرسم
      final GlobalKey repaintKey = GlobalKey();

      // 2- اعمل widget بداخل Overlay عشان ما يتعرضش للمستخدم
      final overlay =
          Overlay.of(context).context.findRenderObject() as RenderBox;
      final overlaySize = overlay.size;

      final completer = Completer<Uint8List>();

      OverlayEntry entry = OverlayEntry(
        builder: (_) => Center(
          child: RepaintBoundary(
            key: repaintKey,
            child: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: overlaySize.width * 0.9,
                child: ShareableHadithCard(hadith: hadith),
              ),
            ),
          ),
        ),
      );

      Overlay.of(context).insert(entry);

      await Future.delayed(const Duration(milliseconds: 300));

      RenderRepaintBoundary boundary =
          repaintKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      completer.complete(byteData!.buffer.asUint8List());

      entry.remove();

      // 3- احفظ الصورة
      final directory = Directory('/storage/emulated/0/Download');
      final file = File(
        '${directory.path}/hadith_${hadith.id}_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(await completer.future);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ تم حفظ الحديث كصورة في مجلد التنزيلات"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ فشل تحميل الحديث كصورة")));
      debugPrint("Download styled error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFavorite = favoritesProvider.isFavorite(hadith.id);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Card(
        color: Theme.of(context).cardColor,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // نص الحديث
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return Text(
                      '${hadith.id} - ${hadith.text}',
                      style: TextStyle(
                        fontSize: themeProvider.fontSize,
                        fontWeight: themeProvider.isBold
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontStyle: themeProvider.isItalic
                            ? FontStyle.italic
                            : FontStyle.normal,
                        decoration: themeProvider.isUnderline
                            ? TextDecoration.underline
                            : TextDecoration.none,
                        height: 1.5,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.start,
                    );
                  },
                ),
                const SizedBox(height: 12),

                // الأزرار
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Smart Share (Copy, Text, Image)
                    IconButton(
                      icon: Icon(Icons.share, color: Theme.of(context).colorScheme.inversePrimary),
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
                      tooltip: "مشاركة",
                    ),

                    // Add Note
                    IconButton(
                      icon: Icon(Icons.note_add_outlined, color: Theme.of(context).colorScheme.inversePrimary),
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
                      tooltip: "إضافة ملاحظة",
                    ),

                    // Add to Collection
                    IconButton(
                      icon: Icon(Icons.bookmark_add_outlined, color: Theme.of(context).colorScheme.inversePrimary),
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
                      tooltip: "إضافة لمجموعة",
                    ),

                    // Favorite
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Theme.of(context).colorScheme.inversePrimary,
                      ),
                      onPressed: () {
                        favoritesProvider.toggleFavorite(hadith, context);
                      },
                      tooltip: "مفضلة",
                    ),

                    // Download Old Style (kept as requested, or can remove if SmartShare covers it. SmartShare is better, but keeping specific download button for quick access)
                     IconButton(
                      icon: Icon(
                        Icons.download,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                      onPressed: () => _downloadStyledHadith(
                        context,
                        hadith,
                      ),
                      tooltip: "تحميل كصورة",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
