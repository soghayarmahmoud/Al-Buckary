// import 'package:buck/themes/theme_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:buck/pages/settings.dart';
// import 'package:buck/pages/statistics.dart';

// class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final String title;
//   final bool hasBackButton;

//   const CustomAppBar({
//     super.key,
//     required this.title,
//     this.hasBackButton = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = context.watch<ThemeProvider>();

//     return AppBar(
//       title: Text(
//         title,
//         style: TextStyle(
//           fontSize: 26,
//           fontWeight: FontWeight.bold,
//           color: themeProvider.themeData.colorScheme.onBackground,
//         ),
//       ),
//       centerTitle: true,

//       leading: hasBackButton
//           ? IconButton(
//               icon: Icon(
//                 Icons.arrow_back,
//                 color: themeProvider.themeData.colorScheme.onBackground,
//               ),
//               onPressed: () => Navigator.of(context).pop(),
//             )
//           : null,

//       actions: [
//         PopupMenuButton<String>(
//           icon: Icon(
//             Icons.menu,
//             color: themeProvider.themeData.colorScheme.onBackground,
//           ),
//           itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//             // قائمة للوضع الليلي والنهاري
//             PopupMenuItem<String>(
//               value: 'theme',
//               child: StatefulBuilder(
//                 builder: (BuildContext context, StateSetter setState) {
//                   return SwitchListTile(
//                     title: Text(
//                       'الوضع الليلي',
//                       style: TextStyle(
//                         fontSize: themeProvider.fontSize,
//                         color: themeProvider.themeData.colorScheme.onSurface,
//                       ),
//                     ),
//                     value: themeProvider.themeData == ThemeData.dark(),
//                     onChanged: (bool value) {
//                       themeProvider.toggleTheme();
//                       setState(() {});
//                     },
//                     secondary: Icon(
//                       themeProvider.themeData == ThemeData.dark()
//                           ? Icons.light_mode
//                           : Icons.dark_mode,
//                       color: themeProvider.themeData.colorScheme.onSurface,
//                     ),
//                   );
//                 },
//               ),
//             ),
//             // قائمة للتحكم في حجم الخط
//             PopupMenuItem<String>(
//               value: 'font_size',
//               child: Column(
//                 children: [
//                   Text(
//                     'حجم الخط',
//                     style: TextStyle(
//                       fontSize: themeProvider.fontSize,
//                       color: themeProvider.themeData.colorScheme.onSurface,
//                     ),
//                   ),
//                   Slider(
//                     value: themeProvider.fontSize,
//                     min: 14.0,
//                     max: 24.0,
//                     divisions: 10,
//                     label: themeProvider.fontSize.round().toString(),
//                     onChanged: (double value) {
//                       themeProvider.setFontSize(value);
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             // قائمة الانتقال إلى الإحصائيات
//             const PopupMenuItem<String>(
//               value: 'statistics',
//               child: Directionality(
//                 textDirection: TextDirection.rtl,
//                 child: Text('الإحصائيات'),
//               ),
//             ),
//             // قائمة الانتقال إلى الإعدادات
//             const PopupMenuItem<String>(
//               value: 'settings',
//               child: Directionality(
//                 textDirection: TextDirection.rtl,
//                 child: Text('الإعدادات'),
//               ),
//             ),
//           ],
//           onSelected: (String result) {
//             if (result == 'statistics') {
//               Navigator.push(context, MaterialPageRoute(builder: (context) => const StatisticsPage()));
//             } else if (result == 'settings') {
//               Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
//             }
//           },
//         ),
//       ],
//       backgroundColor: themeProvider.themeData.colorScheme.background,
//       elevation: 5.0,
//       actionsPadding: const EdgeInsets.all(8),
//     );
//   }

//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:buck/themes/theme_provider.dart';
import 'package:buck/pages/settings.dart';
import 'package:buck/pages/statistics_page.dart';
import 'package:buck/pages/about_page.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final Function(String)? onSearch;
  final VoidCallback? onSearchClosed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onSearch,
    this.onSearchClosed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _widthAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    if (_isSearching) {
      _animationController.reverse();
      _searchController.clear();
      setState(() => _isSearching = false);
      widget.onSearchClosed?.call();
    } else {
      _animationController.forward();
      setState(() => _isSearching = true);
    }
  }

  void _onSearchChanged(String value) {
    widget.onSearch?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();
    final primaryColor = themeProvider.primaryColor;

    return AppBar(
      title: _isSearching
          ? _buildSearchField(themeProvider, primaryColor)
          : Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
              textDirection: TextDirection.rtl,
            ),
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : primaryColor,
      centerTitle: !_isSearching,
      elevation: 8,
      shadowColor: primaryColor.withOpacity(0.3),
      actions: [
        if (!_isSearching)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Tooltip(
              message: 'بحث',
              child: IconButton(
                icon: Icon(Icons.search, color: Colors.white, size: 24),
                onPressed: _toggleSearch,
              ),
            ),
          ),
        if (_isSearching)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Tooltip(
              message: 'إغلاق',
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 24),
                onPressed: _toggleSearch,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchField(ThemeProvider themeProvider, Color primaryColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ScaleTransition(
      scale: _widthAnimation,
      child: FadeTransition(
        opacity: _widthAnimation,
        child: SizedBox(
          height: kToolbarHeight,
          child: TextField(
            controller: _searchController,
            textDirection: TextDirection.rtl,
            textAlignVertical: TextAlignVertical.center,
            onChanged: _onSearchChanged,
            inputFormatters: const [],
            decoration: InputDecoration(
              hintText: 'ابحث عن حديث...',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 16,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              prefixIcon: Icon(
                Icons.search,
                color: Colors.white.withValues(alpha: 0.7),
                size: 22,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
            cursorColor: Colors.white,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}
