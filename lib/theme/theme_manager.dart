import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager with ChangeNotifier {
  // --- STATE ---
  String _currentThemeName = "FloraBlush Garden";
  bool _isDarkMode = true;

  // --- GETTERS ---
  String get currentThemeName => _currentThemeName;
  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme {
    final themeInfo = _builtInThemes.firstWhere(
      (t) => t['name'] == _currentThemeName,
      orElse: () => _builtInThemes[0],
    );

    return _buildTheme(
      name: themeInfo['name'] as String,
      primary: themeInfo['primary'] as Color,
      secondary: themeInfo['secondary'] as Color,
      darkBackground: themeInfo['background'] as Color,
      darkSurface: themeInfo['surface'] as Color,
      fontBuilder: themeInfo['font'] as Function,
      isDark: _isDarkMode,
    );
  }

  // --- ACTIONS ---
  ThemeManager() {
    _loadSettings();
  }

  void toggleBrightness(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
    _saveSettings();
  }

  void setTheme(String name) {
    _currentThemeName = name;
    notifyListeners();
    _saveSettings();
  }

  // --- PERSISTENCE ---
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_name', _currentThemeName);
    await prefs.setBool('is_dark_mode', _isDarkMode);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _currentThemeName = prefs.getString('theme_name') ?? "FloraBlush Garden";
    _isDarkMode = prefs.getBool('is_dark_mode') ?? true;
    notifyListeners();
  }

  // --- BUILDER HELPER ---
  static ThemeData _buildTheme({
    required String name,
    required Color primary,
    required Color secondary,
    required Color darkBackground,
    required Color darkSurface,
    required Function fontBuilder,
    required bool isDark,
  }) {
    // --- COLOR LOGIC ---
    
    // Light Mode Strategy: 
    // Instead of pure white, we mix 8% of the Primary color into white.
    // This gives a "tinted" background that matches the theme's mood.
    final Color lightBackground = Color.alphaBlend(
      primary.withValues(alpha: 0.08), 
      const Color(0xFFFAFAFA),
    );
    
    // Light Surface (Cards):
    // Slightly lighter tint (3%) so cards stand out from the background
    final Color lightSurface = Color.alphaBlend(
      primary.withValues(alpha: 0.03), 
      const Color(0xFFFFFFFF),
    );

    // Select based on mode
    final Color background = isDark ? darkBackground : lightBackground;
    final Color surface = isDark ? darkSurface : lightSurface;
    final Color textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final Brightness brightness = isDark ? Brightness.dark : Brightness.light;

    // Font Logic
    final TextTheme baseTextTheme = isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;
    final TextTheme customTextTheme = fontBuilder(baseTextTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      cardColor: surface,
      
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: isDark ? Colors.black : Colors.white,
        secondary: secondary,
        onSecondary: Colors.black,
        surface: surface,
        onSurface: textColor,
        error: Colors.redAccent,
        onError: Colors.white,
      ),

      textTheme: customTextTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: primary, // Colored title
        elevation: 0,
        iconTheme: IconThemeData(color: primary),
      ),
      
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: isDark ? Colors.black : Colors.white,
      ),
      
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary.withValues(alpha: 0.3);
          return Colors.grey.withValues(alpha: 0.3);
        }),
      ),
    );
  }

  // --- DATA: 16 THEMES ---
  static final List<Map<String, dynamic>> _builtInThemes = [
    {
      'name': 'FloraBlush Garden',
      'primary': Color(0xFFEB4C4C), 'secondary': Color(0xFFFFA6A6),
      'background': Color(0xFF1C1212), 'surface': Color(0xFF241616),
      'font': GoogleFonts.playfairDisplayTextTheme,
    },
    {
      'name': 'Rustic Meridian',
      'primary': Color(0xFF25343F), 'secondary': Color(0xFFFF9B51),
      'background': Color(0xFF141A1F), 'surface': Color(0xFF1E262D),
      'font': GoogleFonts.rokkittTextTheme,
    },
    {
      'name': 'Crimson Horizon',
      'primary': Color(0xFFDE1A58), 'secondary': Color(0xFF8F0177),
      'background': Color(0xFF160029), 'surface': Color(0xFF22003E),
      'font': GoogleFonts.oswaldTextTheme,
    },
    {
      'name': 'Nocturne Tide',
      'primary': Color(0xFF708993), 'secondary': Color(0xFFA1C2BD),
      'background': Color(0xFF0F1126), 'surface': Color(0xFF171A33),
      'font': GoogleFonts.latoTextTheme,
    },
    {
      'name': 'Velvet Roast',
      'primary': Color(0xFF6C4E31), 'secondary': Color(0xFF603F26),
      'background': Color(0xFF1B140F), 'surface': Color(0xFF241A13),
      'font': GoogleFonts.merriweatherTextTheme,
    },
    {
      'name': 'Imperial Blush',
      'primary': Color(0xFFF5AFAF), 'secondary': Color(0xFFF9DFDF),
      'background': Color(0xFF1A1416), 'surface': Color(0xFF241C1F),
      'font': GoogleFonts.bodoniModaTextTheme,
    },
    {
      'name': 'Verdant Empress',
      'primary': Color(0xFFA8DF8E), 'secondary': Color(0xFFFFAAB8),
      'background': Color(0xFF132017), 'surface': Color(0xFF1C2C20),
      'font': GoogleFonts.quicksandTextTheme,
    },
    {
      'name': 'Solar Marina',
      'primary': Color(0xFF26CCC2), 'secondary': Color(0xFF6AECE1),
      'background': Color(0xFF0C1E22), 'surface': Color(0xFF142A30),
      'font': GoogleFonts.poppinsTextTheme,
    },
    {
      'name': 'Arctic Dominion',
      'primary': Color(0xFF4988C4), 'secondary': Color(0xFF1C4D8D),
      'background': Color(0xFF0A162E), 'surface': Color(0xFF102043),
      'font': GoogleFonts.exo2TextTheme,
    },
    {
      'name': 'Nebula Regent',
      'primary': Color(0xFF982598), 'secondary': Color(0xFFE491C9),
      'background': Color(0xFF0C0D24), 'surface': Color(0xFF15183A),
      'font': GoogleFonts.orbitronTextTheme,
    },
    {
      'name': 'Harvest Sovereign',
      'primary': Color(0xFF8A8635), 'secondary': Color(0xFFAA2B1D),
      'background': Color(0xFF1C1A10), 'surface': Color(0xFF262315),
      'font': GoogleFonts.aleoTextTheme,
    },
    {
      'name': 'Pearl Meridian',
      'primary': Color(0xFF44A194), 'secondary': Color(0xFF537D96),
      'background': Color(0xFF101A1A), 'surface': Color(0xFF162626),
      'font': GoogleFonts.loraTextTheme,
    },
    {
      'name': 'Neon Dominion',
      'primary': Color(0xFF5B23FF), 'secondary': Color(0xFF008BFF),
      'background': Color(0xFF0F0C1E), 'surface': Color(0xFF18142A),
      'font': GoogleFonts.audiowideTextTheme,
    },
    {
      'name': 'Velour Machine',
      'primary': Color(0xFF41644A), 'secondary': Color(0xFF0D4715),
      'background': Color(0xFF0E1A12), 'surface': Color(0xFF15271C),
      'font': GoogleFonts.libreBaskervilleTextTheme,
    },
    {
      'name': 'Monarch Noir',
      'primary': Color(0xFF000000), 'secondary': Color(0xFFB6B09F),
      'background': Color(0xFF121212), 'surface': Color(0xFF1B1B1B),
      'font': GoogleFonts.dmSansTextTheme,
    },
    {
      'name': 'Imperial Inferno',
      'primary': Color(0xFFC40C0C), 'secondary': Color(0xFFFF6500),
      'background': Color(0xFF1A0707), 'surface': Color(0xFF240E0E),
      'font': GoogleFonts.russoOneTextTheme,
    },
  ];

  List<Map<String, dynamic>> get availableThemes => _builtInThemes;
}
