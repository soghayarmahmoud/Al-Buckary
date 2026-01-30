import 'package:flutter/material.dart';
import 'package:buck/database_helper.dart';
import 'package:buck/models/hadith.dart';
import 'package:buck/services/notification_service.dart';

class NotesSheet extends StatefulWidget {
  final Hadith hadith;

  const NotesSheet({super.key, required this.hadith});

  @override
  State<NotesSheet> createState() => _NotesSheetState();
}

class _NotesSheetState extends State<NotesSheet> {
  final TextEditingController _controller = TextEditingController();
  int _selectedColor = 0xFFFFC107; // Default amber

  final List<int> _availableColors = [
    0xFFFFC107, // Amber
    0xFF4CAF50, // Green
    0xFF2196F3, // Blue
    0xFFF44336, // Red
    0xFF9C27B0, // Purple
    0xFFFF9800, // Orange
    0xFFE91E63, // Pink
    0xFF00BCD4, // Cyan
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_controller.text.trim().isEmpty) return;

    await DatabaseHelper.instance.addNote(
      widget.hadith.id,
      _controller.text.trim(),
      color: _selectedColor,
    );

    if (mounted) {
      Navigator.pop(context);
      NotificationService.showSuccess(context, 'تم حفظ الملاحظة بنجاح');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'إضافة ملاحظة',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 5,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'اكتب ملاحظتك هنا...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'اختر لون الملاحظة:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: _availableColors.map((color) {
              final isSelected = color == _selectedColor;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Color(color),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(color).withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 24,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveNote,
                  child: const Text('حفظ'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
