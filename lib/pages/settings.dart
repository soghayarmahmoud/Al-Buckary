// ignore_for_file: depend_on_referenced_packages, deprecated_member_use, use_build_context_synchronously, unused_label

import 'package:flutter/material.dart';
import 'package:buck/components/custom_appbar.dart';
import 'package:buck/components/notification_helper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:buck/themes/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:buck/pages/about_page.dart';
import 'package:buck/database_helper.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

// Alias for AboutPage to distinguish it from usage in settings
typedef AboutPageWidget = AboutPage;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _isBold;
  late bool _isItalic;
  late bool _isUnderline;
  bool _dailyReminderEnabled = false;
  late TimeOfDay _reminderTime;

  @override
  void initState() {
    super.initState();
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _isBold = themeProvider.isBold;
    _isItalic = themeProvider.isItalic;
    _isUnderline = themeProvider.isUnderline;
    _reminderTime = const TimeOfDay(hour: 8, minute: 0);
    _loadReminderSettings();
  }

  Future<void> _loadReminderSettings() async {
    final enabled = await NotificationHelper.isDailyReminderEnabled();
    final (hour, minute) = await NotificationHelper.getReminderTime();
    setState(() {
      _dailyReminderEnabled = enabled;
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  void _resetSettings() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    setState(() {
      _isBold = false;
      _isItalic = false;
      _isUnderline = false;
    });
    themeProvider.setFontSize(16.0);
    themeProvider.setFontStyle(
      isBold: false,
      isItalic: false,
      isUnderline: false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إعادة تعيين الإعدادات بنجاح.')),
    );
  }

  Future<void> _clearTempData() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        tempDir.listSync().forEach((file) {
          file.deleteSync(recursive: true);
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم مسح البيانات المؤقتة بنجاح.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل مسح البيانات المؤقتة.')),
        );
      }
    }
  }

  Future<void> _shareApp() async {
    try {
      const url = 'https://elsoghayar.vercel.app/projects/6';

      await Share.share(
        '📲 جرّب تطبيق البخاري!\n\nحمّل التطبيق من هنا: $url',
        subject: 'تطبيق البخاري',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تعذر مشاركة التطبيق.')));
      }
    }
  }

  Future<void> _shareApk() async {
    try {
      final apkPath = await _getApkFilePath();
      if (apkPath != null) {
        await Share.shareXFiles([XFile(apkPath)], text: 'حمّل تطبيق البخاري!');
      } else {
        // Fallback to sharing link if APK file not accessible
        const url = 'https://drive.google.com/uc?export=download&id=1i_inm8g9IyRvfJ-0DjslSmwGvs0N_mvn';
        await Share.share('حمّل تطبيق البخاري من هنا: $url');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر مشاركة ملف APK: $e')),
        );
      }
    }
  }

  Future<String?> _getApkFilePath() async {
    // Attempt to find the APK in standard build locations (mostly for debugging/local builds)
    // In production/release, this is often restricted. 
    // This is a best-effort attempt.
    try {
      // For example, on Android user releases, you might not have access to the APK file directly easily without permissions.
      // We will return null to trigger the fallback URL sharing, which is safer.
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _resetAppDatabase() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة بناء قاعدة البيانات'),
        content: const Text(
          'هل أنت متأكد؟ سيتم حذف جميع البيانات (المفضلة، الملاحظات، المجموعات) وإعادة تثبيت قاعدة البيانات من الصفر.\n\nاستخدم هذا الخيار فقط إذا كنت تواجه مشاكل في اختفاء الفصول.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('نعم، أعد البناء', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DatabaseHelper.instance.resetDatabase();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إعادة بناء قاعدة البيانات بنجاح. أعد تشغيل التطبيق.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('حدث خطأ: $e')),
          );
        }
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $uri';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('تعذر فتح الرابط $url')));
      }
    }
  }

  Future<void> _showCustomColorPicker(BuildContext context, ThemeProvider themeProvider) async {
    Color newColor = themeProvider.primaryColor;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر لون مخصص', textDirection: TextDirection.rtl),
        content: SingleChildScrollView(
          child: ColorPicker(
            color: newColor,
            onColorChanged: (color) => newColor = color,
            pickersEnabled: const {
              ColorPickerType.wheel: true,
              ColorPickerType.accent: false,
            },
            enableShadesSelection: true,
            showRecentColors: true,
            heading: const Text('اختر اللون', textDirection: TextDirection.rtl),
            subheading: const Text('حدد الدرجة', textDirection: TextDirection.rtl),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              themeProvider.setCustomPrimaryColor(newColor);
              Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: const CustomAppBar(title: 'الإعدادات'),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(16.0).copyWith(bottom: 100.0),
          children: [
            // ===== تخصيص المظهر =====
            _buildSectionCard(
              context,
              icon: Icons.palette_outlined,
              title: 'تخصيص المظهر',
              children: [
                // Theme Mode Selector
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                       Row(
                        children: [
                          Icon(
                            Icons.brightness_6,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          const Text('وضع الإضاءة'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildThemeModeChip(context, themeProvider, 'light', 'نهاري', Icons.wb_sunny),
                          _buildThemeModeChip(context, themeProvider, 'dark', 'ليلي', Icons.nightlight_round),
                          _buildThemeModeChip(context, themeProvider, 'amoled', 'داكن (AMOLED)', Icons.bedtime),
                          _buildThemeModeChip(context, themeProvider, 'sepia', 'قراءة (Sepia)', Icons.menu_book),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Font size slider
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.text_format,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          const Text('حجم الخط'),
                        ],
                      ),
                      Slider(
                        value: themeProvider.fontSize,
                        min: 12.0,
                        max: 32.0,
                        divisions: 20,
                        label: themeProvider.fontSize.round().toString(),
                        onChanged: (double value) {
                          themeProvider.setFontSize(value);
                        },
                      ),
                      Text(
                        'حجم الخط الحالي: ${themeProvider.fontSize.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Font styles
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.style,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          const Text('نمط الخط'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStyleButton(
                            icon: Icons.format_bold,
                            label: 'غامق',
                            isActive: _isBold,
                            onTap: () {
                              setState(() {
                                _isBold = !_isBold;
                              });
                              themeProvider.setFontStyle(isBold: _isBold);
                            },
                          ),
                          _buildStyleButton(
                            icon: Icons.format_italic,
                            label: 'مائل',
                            isActive: _isItalic,
                            onTap: () {
                              setState(() {
                                _isItalic = !_isItalic;
                              });
                              themeProvider.setFontStyle(isItalic: _isItalic);
                            },
                          ),
                          _buildStyleButton(
                            icon: Icons.format_underline,
                            label: 'تحته خط',
                            isActive: _isUnderline,
                            onTap: () {
                              setState(() {
                                _isUnderline = !_isUnderline;
                              });
                              themeProvider.setFontStyle(
                                isUnderline: _isUnderline,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Color scheme picker
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.color_lens,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          const Text('اختر اللون الأساسي'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildColorOption(
                            context,
                            color: const Color(0xFF00695C),
                            label: 'أزرق مخضر',
                            scheme: 'teal',
                            themeProvider: themeProvider,
                          ),
                          _buildColorOption(
                            context,
                            color: const Color(0xFF1565C0),
                            label: 'أزرق',
                            scheme: 'blue',
                            themeProvider: themeProvider,
                          ),
                          _buildColorOption(
                            context,
                            color: const Color(0xFF7B1FA2),
                            label: 'بنفسجي',
                            scheme: 'purple',
                            themeProvider: themeProvider,
                          ),
                          _buildColorOption(
                            context,
                            color: const Color(0xFF2E7D32),
                            label: 'أخضر',
                            scheme: 'green',
                            themeProvider: themeProvider,
                          ),
                          _buildColorOption(
                            context,
                            color: const Color(0xFFE65100),
                            label: 'برتقالي',
                            scheme: 'orange',
                            themeProvider: themeProvider,
                          ),
                          _buildColorOption(
                            context,
                            color: const Color(0xFFC62828),
                            label: 'أحمر',
                            scheme: 'red',
                            themeProvider: themeProvider,
                          ),
                          _buildColorOption(
                            context,
                            color: const Color(0xFFC2185B),
                            label: 'وردي',
                            scheme: 'pink',
                            themeProvider: themeProvider,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Custom color picker button
                      ElevatedButton.icon(
                        onPressed: () => _showCustomColorPicker(context, themeProvider),
                        icon: const Icon(Icons.color_lens),
                        label: const Text('اختر لون مخصص'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Font family picker
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.text_fields,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          const Text('اختر خط النص'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildFontOption(
                            context,
                            label: 'Cairo',
                            fontFamily: 'cairo',
                            themeProvider: themeProvider,
                          ),
                          _buildFontOption(
                            context,
                            label: 'Tajawal',
                            fontFamily: 'tajawal',
                            themeProvider: themeProvider,
                          ),
                          _buildFontOption(
                            context,
                            label: 'Changa',
                            fontFamily: 'changa',
                            themeProvider: themeProvider,
                          ),
                          _buildFontOption(
                            context,
                            label: 'PlaypenSansArabic',
                            fontFamily: 'playpen',
                            themeProvider: themeProvider,
                          ),
                          _buildFontOption(
                            context,
                            label: 'ArefRuqaa',
                            fontFamily: 'arefruqaa',
                            themeProvider: themeProvider,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ===== التنبيهات والتذكيرات =====
            _buildSectionCard(
              context,
              icon: Icons.notifications_active_outlined,
              title: 'التنبيهات والتذكيرات',
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.alarm,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('تذكير يومي'),
                    subtitle: const Text('اقرأ الحديث يومياً في وقت محدد'),
                    trailing: Switch(
                      value: _dailyReminderEnabled,
                      onChanged: (bool value) async {
                        if (value) {
                          // Show time picker
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: _reminderTime,
                          );
                          if (picked != null) {
                            setState(() {
                              _reminderTime = picked;
                            });
                            await NotificationHelper.scheduleDailyReminder(
                              hour: picked.hour,
                              minute: picked.minute,
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'تم تفعيل التذكير الساعة ${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
                                  ),
                                ),
                              );
                            }
                          }
                        } else {
                          await NotificationHelper.disableDailyReminder();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تم تعطيل التذكير')),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ),
                if (_dailyReminderEnabled)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'الساعة: ${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final TimeOfDay? picked = await showTimePicker(
                                context: context,
                                initialTime: _reminderTime,
                              );
                              if (picked != null) {
                                setState(() {
                                  _reminderTime = picked;
                                });
                                await NotificationHelper.scheduleDailyReminder(
                                  hour: picked.hour,
                                  minute: picked.minute,
                                );
                              }
                            },
                            child: const Text('غيّر الوقت'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // ===== إدارة البيانات =====
            _buildSectionCard(
              context,
              icon: Icons.storage_outlined,
              title: 'إدارة البيانات',
              children: [
                _buildOptionTile(
                  context,
                  icon: Icons.refresh,
                  title: 'إعادة تعيين الإعدادات',
                  subtitle: 'استعادة الإعدادات الافتراضية',
                  onTap: _resetSettings,
                ),
                const SizedBox(height: 8),
                _buildOptionTile(
                  context,
                  icon: Icons.delete_sweep,
                  title: 'مسح البيانات المؤقتة',
                  subtitle: 'احذف ملفات مؤقتة لتحرير المساحة',
                  onTap: _clearTempData,
                ),
                const SizedBox(height: 8),
                _buildOptionTile(
                  context,
                  icon: Icons.build_circle_outlined,
                  title: 'إصلاح قاعدة البيانات',
                  subtitle: 'اضغط هنا إذا كانت الفصول مختفية',
                  onTap: _resetAppDatabase,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ===== حول التطبيق =====
            _buildSectionCard(
              context,
              icon: Icons.info_outline,
              title: 'حول التطبيق',
              children: [
                _buildOptionTile(
                  context,
                  icon: Icons.info,
                  title: 'عن التطبيق',
                  subtitle: 'معلومات عن المطورين والإصدار',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutPageWidget(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildOptionTile(
                  context,
                  icon: Icons.share,
                  title: 'مشاركة التطبيق',
                  subtitle: 'شارك التطبيق مع أصدقائك',
                  onTap: _shareApp,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ===== التواصل والدعم =====
            _buildSectionCard(
              context,
              icon: Icons.support_agent_outlined,
              title: 'للتواصل والدعم',
              children: [
                Text(
                  'تابعنا على الشبكات الاجتماعية',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSocialButton(
                      FontAwesomeIcons.whatsapp,
                      () => _launchUrl('https://wa.me/+201019593092'),
                      'WhatsApp',
                    ),
                    _buildSocialButton(
                      Icons.email,
                      () => _launchUrl('mailto:alsighiar@gmail.com'),
                      'البريد',
                    ),
                    _buildSocialButton(
                      Icons.language,
                      () => _launchUrl('https://m-el-soghayar.vercel.app/'),
                      'الموقع',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildStyleButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color: isActive
                  ? Colors.white
                  : Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeModeChip(
    BuildContext context, 
    ThemeProvider provider, 
    String mode, 
    String label, 
    IconData icon
  ) {
    final isSelected = provider.themeMode == mode;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon, 
            size: 16, 
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          provider.setThemeMode(mode);
        }
      },
      selectedColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? Colors.transparent : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, VoidCallback onTap, String label) {
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            size: 26,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  // ignore: unused_element
  // Future<void> _shareApk() async {
  //   try {
  //     const apkUrl =
  //         'https://drive.google.com/uc?export=download&id=1i_inm8g9IyRvfJ-0DjslSmwGvs0N_mvn';
  //     await _launchUrl(apkUrl);
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('تم فتح رابط التحميل بنجاح')),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(const SnackBar(content: Text('فشل فتح رابط التحميل')));
  //     }
  //   }
  // }

  Widget _buildColorOption(
    BuildContext context, {
    required Color color,
    required String label,
    required String scheme,
    required ThemeProvider themeProvider,
  }) {
    final isSelected = themeProvider.selectedColorScheme == scheme;
    return GestureDetector(
      onTap: () {
        themeProvider.setColorScheme(scheme);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? Center(
                    child: Icon(Icons.check, color: Colors.white, size: 28),
                  )
                : null,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFontOption(
    BuildContext context, {
    required String label,
    required String fontFamily,
    required ThemeProvider themeProvider,
  }) {
    final isSelected = themeProvider.selectedFontFamily == fontFamily;
    return GestureDetector(
      onTap: () {
        themeProvider.setFontFamily(fontFamily);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : null,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
