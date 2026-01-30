import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Modern material 3 themed provider with a seeded color scheme and dynamic customization.

class ThemeProvider extends ChangeNotifier {
  late ThemeData _themeData;
  double _fontSize = 18.0;

  // Theme Modes: light, dark, amoled, sepia
  String _themeMode = 'light';

  // Color customization
  late Color _primaryColor;
  String _selectedColorScheme =
      'teal'; // teal, blue, purple, green, orange, red, pink

  // Font customization
  String _selectedFontFamily =
      'cairo'; // cairo, tajawal, changa, playpen, arefruqaa, system

  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;

  ThemeProvider() {
    // Initializing with a default value to prevent the LateInitializationError
    _primaryColor = const Color(0xFF00695C);
    _themeData = _buildTheme(_themeMode, _primaryColor, _selectedFontFamily);
    _loadSettings();
  }

  // Getters للوصول إلى البيانات
  ThemeData get themeData => _themeData;
  double get fontSize => _fontSize;
  bool get isDarkMode => _themeMode == 'dark' || _themeMode == 'amoled';
  String get themeMode => _themeMode;
  bool get isBold => _isBold;
  bool get isItalic => _isItalic;
  bool get isUnderline => _isUnderline;
  Color get primaryColor => _primaryColor;
  String get selectedColorScheme => _selectedColorScheme;
  String get selectedFontFamily => _selectedFontFamily;

  // تحميل الإعدادات من الذاكرة
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    // Migration: If old boolean exists, convert to string
    if (prefs.containsKey('isDarkMode')) {
      final bool isDark = prefs.getBool('isDarkMode') ?? false;
      _themeMode = isDark ? 'dark' : 'light';
      await prefs.remove('isDarkMode'); // Clean up old key
    } else {
      _themeMode = prefs.getString('themeMode') ?? 'light';
    }

    _fontSize = prefs.getDouble('fontSize') ?? 22.0;
    _isBold = prefs.getBool('isBold') ?? false;
    _isItalic = prefs.getBool('isItalic') ?? false;
    _isUnderline = prefs.getBool('isUnderline') ?? false;
    _selectedColorScheme = prefs.getString('colorScheme') ?? 'teal';
    _selectedFontFamily = prefs.getString('fontFamily') ?? 'cairo';
    
    // Load custom color if set
    final customColorValue = prefs.getInt('customPrimaryColor');
    if (customColorValue != null && _selectedColorScheme == 'custom') {
      _primaryColor = Color(customColorValue);
    } else {
      _primaryColor = _getColorForScheme(_selectedColorScheme);
    }
    
    _themeData = _buildTheme(_themeMode, _primaryColor, _selectedFontFamily);
    notifyListeners();
  }

  // حفظ جميع الإعدادات في الذاكرة
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', _themeMode);
    await prefs.setDouble('fontSize', _fontSize);
    await prefs.setBool('isBold', _isBold);
    await prefs.setBool('isItalic', _isItalic);
    await prefs.setBool('isUnderline', _isUnderline);
    await prefs.setString('colorScheme', _selectedColorScheme);
    await prefs.setString('fontFamily', _selectedFontFamily);
    // Save custom color value if custom scheme is selected
    if (_selectedColorScheme == 'custom') {
      await prefs.setInt('customPrimaryColor', _primaryColor.toARGB32());
    }
  }

  // تغيير وضع المظهر
  void setThemeMode(String mode) {
    if (['light', 'dark', 'amoled', 'sepia'].contains(mode)) {
      _themeMode = mode;
      _themeData = _buildTheme(_themeMode, _primaryColor, _selectedFontFamily);
      _saveSettings();
      notifyListeners();
    }
  }

  // Toggle for backward compatibility (Light <-> Dark)
  void toggleTheme() {
    setThemeMode(isDarkMode ? 'light' : 'dark');
  }

  // تعيين حجم الخط
  void setFontSize(double size) {
    _fontSize = size;
    _saveSettings();
    notifyListeners();
  }

  // تعيين أنماط الخط
  void setFontStyle({bool? isBold, bool? isItalic, bool? isUnderline}) {
    if (isBold != null) _isBold = isBold;
    if (isItalic != null) _isItalic = isItalic;
    if (isUnderline != null) _isUnderline = isUnderline;
    _saveSettings();
    notifyListeners();
  }

  // تعيين لون المظهر
  void setColorScheme(String scheme) {
    _selectedColorScheme = scheme;
    _primaryColor = _getColorForScheme(scheme);
    _themeData = _buildTheme(_themeMode, _primaryColor, _selectedFontFamily);
    _saveSettings();
    notifyListeners();
  }

  // Set custom primary color
  void setCustomPrimaryColor(Color color) {
    _primaryColor = color;
    _selectedColorScheme = 'custom';
    _themeData = _buildTheme(_themeMode, _primaryColor, _selectedFontFamily);
    _saveSettings();
    notifyListeners();
  }

  // تعيين عائلة الخط
  void setFontFamily(String fontFamily) {
    _selectedFontFamily = fontFamily;
    _themeData = _buildTheme(_themeMode, _primaryColor, fontFamily);
    _saveSettings();
    notifyListeners();
  }

  // Get color for scheme
  Color _getColorForScheme(String scheme) {
    switch (scheme) {
      case 'blue':
        return const Color(0xFF1565C0);
      case 'purple':
        return const Color(0xFF7B1FA2);
      case 'green':
        return const Color(0xFF2E7D32);
      case 'orange':
        return const Color(0xFFE65100);
      case 'red':
        return const Color(0xFFC62828);
      case 'pink':
        return const Color(0xFFC2185B);
      case 'teal':
      default:
        return const Color(0xFF00695C);
    }
  }

  // Get font data for family
  TextStyle _getFontStyle(String fontFamily) {
    switch (fontFamily) {
      case 'tajawal':
        return const TextStyle(fontFamily: 'Tajawal');
      case 'changa':
        return const TextStyle(fontFamily: 'Changa');
      case 'playpen':
        return const TextStyle(fontFamily: 'PlaypenSansArabic');
      case 'arefruqaa':
        return const TextStyle(fontFamily: 'ArefRuqaa');
      case 'cairo':
      default:
        return const TextStyle(fontFamily: 'Cairo');
    }
  }

  // Unified Theme Builder
  ThemeData _buildTheme(String mode, Color primaryColor, String fontFamily) {
    final baseTextStyle = _getFontStyle(fontFamily);
    
    // Define base colors based on mode
    Color scaffoldBg;
    Color cardBg;
    Color textColor;
    Brightness brightness;
    
    switch (mode) {
      case 'amoled':
        scaffoldBg = Colors.black;
        cardBg = const Color(0xFF121212);
        textColor = Colors.white;
        brightness = Brightness.dark;
        break;
      case 'sepia':
        scaffoldBg = const Color(0xFFF4ECD8); // Warm paper-like color
        cardBg = const Color(0xFFE8DECA); // Slightly darker for cards
        textColor = const Color(0xFF5D4037); // Brownish text
        brightness = Brightness.light;
        break;
      case 'dark':
        scaffoldBg = const Color(0xFF121212);
        cardBg = const Color(0xFF1E1E1E);
        textColor = Colors.white;
        brightness = Brightness.dark;
        break;
      case 'light':
      default:
        scaffoldBg = Colors.white;
        cardBg = Colors.white;
        textColor = Colors.black87;
        brightness = Brightness.light;
        break;
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: brightness,
        surface: scaffoldBg,
      ),
      scaffoldBackgroundColor: scaffoldBg,
      primaryColor: primaryColor,
      cardTheme: CardThemeData(
        elevation: mode == 'sepia' ? 1 : 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: cardBg,
        surfaceTintColor: primaryColor.withValues(alpha: 0.05),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: mode == 'sepia' ? primaryColor : (brightness == Brightness.dark ? cardBg : primaryColor),
        foregroundColor: mode == 'sepia' ? Colors.white : (brightness == Brightness.dark ? Colors.white : Colors.white),
        titleTextStyle: baseTextStyle.copyWith(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: baseTextStyle.copyWith(
          fontSize: 16,
          color: textColor,
          height: 1.5,
        ),
        bodyMedium: baseTextStyle.copyWith(fontSize: 14, color: textColor.withValues(alpha: 0.8)),
        titleLarge: baseTextStyle.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.dark ? const Color(0xFF2A2A2A) : Colors.grey.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: TextStyle(color: textColor.withValues(alpha: 0.7)),
        hintStyle: TextStyle(color: textColor.withValues(alpha: 0.5)),
      ),
    );
  }
}
