
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:buck/models/hadith.dart';

class SmartShareDialog extends StatefulWidget {
  final Hadith hadith;

  const SmartShareDialog({super.key, required this.hadith});

  @override
  State<SmartShareDialog> createState() => _SmartShareDialogState();
}

class _SmartShareDialogState extends State<SmartShareDialog> {
  final ScreenshotController _screenshotController = ScreenshotController();
  int _selectedStyle = 0;

  final List<Gradient> _gradients = [
    const LinearGradient(
      colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [Color(0xFF141E30), Color(0xFF243B55)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [Color(0xFFD3CCE3), Color(0xFFE9E4F0)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [Color(0xFFF4ECD8), Color(0xFFE8DECA)], // Sepia
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];

  Future<void> _shareImage() async {
    try {
      final directory = await getTemporaryDirectory();
      final imagePath = await _screenshotController.captureAndSave(
        directory.path,
        fileName: 'hadith_share_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      if (imagePath != null) {
        await Share.shareXFiles([XFile(imagePath)], text: widget.hadith.text);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء المشاركة: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'مشاركة الحديث كصورة',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          
          // Preview Area
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Screenshot(
                  controller: _screenshotController,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: _gradients[_selectedStyle],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.format_quote, color: Colors.white70, size: 30),
                        const SizedBox(height: 10),
                        Text(
                          widget.hadith.text,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: 18,
                            height: 1.6,
                            color: _selectedStyle == 4 || _selectedStyle == 5 
                                ? Colors.black87 
                                : Colors.white,
                            fontFamily: 'Amiri', // Or default font
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'صحيح البخاري - حديث رقم ${widget.hadith.id}',
                          style: TextStyle(
                             color: _selectedStyle == 4 || _selectedStyle == 5 
                                ? Colors.black54 
                                : Colors.white70,
                             fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Style Selector
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _gradients.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedStyle = index),
                  child: Container(
                    width: 50,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      gradient: _gradients[index],
                      borderRadius: BorderRadius.circular(8),
                      border: _selectedStyle == index 
                          ? Border.all(color: Theme.of(context).primaryColor, width: 3)
                          : null,
                    ),
                    child: _selectedStyle == index 
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              },
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareImage,
                    icon: const Icon(Icons.share),
                    label: const Text('مشاركة'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
