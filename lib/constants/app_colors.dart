// import 'package:flutter/material.dart';

// class AppColors {
//   // Primary Colors
//   static const Color primary = Color(0xFFE91E63); // Pink
//   static const Color primaryLight = Color(0xFFF8BBD0);
//   static const Color primaryDark = Color(0xFFC2185B);

//   // Background Colors
//   static const Color background = Color(0xFFFAFAFA);
//   static const Color cardBackground = Colors.white;
//   static const Color pinkBackground = Color(0xFFFCE4EC);

//   // Text Colors
//   static const Color textPrimary = Color(0xFF212121);
//   static const Color textSecondary = Color(0xFF757575);
//   static const Color textHint = Color(0xFFBDBDBD);

//   // Accent Colors
//   static const Color success = Color(0xFF4CAF50);
//   static const Color warning = Color(0xFFFFC107);
//   static const Color error = Color(0xFFF44336);
//   static const Color info = Color(0xFF2196F3);

//   // Status Colors
//   static const Color completed = Color(0xFF4CAF50);
//   static const Color pending = Color(0xFFFFC107);
//   static const Color inProgress = Color(0xFF2196F3);

//   // Chart Colors
//   static const List<Color> chartColors = [
//     Color(0xFFE91E63),
//     Color(0xFF9C27B0),
//     Color(0xFF2196F3),
//     Color(0xFF4CAF50),
//     Color(0xFFFFC107),
//   ];

//   // Gradient
//   static const LinearGradient primaryGradient = LinearGradient(
//     colors: [Color(0xFFE91E63), Color(0xFFF48FB1)],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   );
// }

import 'package:flutter/material.dart';

class AppColors {
  // 🔥 Primary Brand (Purple = Power + Premium + AI Feel)
  static const Color primary = Color(0xFF6C3EF4); // Rich Purple
  static const Color primaryLight = Color(0xFFB39DFF);
  static const Color primaryDark = Color(0xFF4A2DBF);

  // 🌫 Backgrounds (Clean + Soft)
  static const Color background = Color(0xFFF7F6FB);
  static const Color cardBackground = Colors.white;
  static const Color surface = Color(0xFFEFECFF);
  static const Color pinkBackground = Color(0xFFFCE4EC);

  // 🧠 Text Colors (Better hierarchy)
  static const Color textPrimary = Color(0xFF1F1B2E);
  static const Color textSecondary = Color(0xFF6E6B7B);
  static const Color textHint = Color(0xFFA8A5B5);

  // ✨ Accent (Controlled feminine touch — NOT over pink)
  static const Color accent = Color(0xFF9F7BFF); // soft pink accent only

  // 🚦 Status Colors (slightly refined)
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // 📊 Chart Colors (more modern palette)
  static const List<Color> chartColors = [
    Color(0xFF6C3EF4),
    Color(0xFFFF6F91),
    Color(0xFF3B82F6),
    Color(0xFF22C55E),
    Color(0xFFF59E0B),
  ];

  // 🌈 Main Gradient (premium feel)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C3EF4), Color(0xFF9F7BFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 🌌 Background Gradient (for splash / auth screens)
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF6C3EF4), Color(0xFFB39DFF), Color(0xFFF7F6FB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
