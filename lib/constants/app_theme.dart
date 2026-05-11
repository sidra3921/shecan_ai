// import 'package:flutter/material.dart';
// import 'app_colors.dart';

// class AppTheme {
//   static ThemeData get lightTheme {
//     return ThemeData(
//       primaryColor: AppColors.primary,
//       scaffoldBackgroundColor: AppColors.background,
//       fontFamily: 'Roboto',

//       colorScheme: const ColorScheme.light(
//         primary: AppColors.primary,
//         secondary: AppColors.primaryLight,
//         surface: AppColors.cardBackground,
//         error: AppColors.error,
//       ),

//       appBarTheme: const AppBarTheme(
//         backgroundColor: AppColors.primary,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         titleTextStyle: TextStyle(
//           color: Colors.white,
//           fontSize: 20,
//           fontWeight: FontWeight.w600,
//         ),
//       ),

//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.primary,
//           foregroundColor: Colors.white,
//           padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           elevation: 0,
//           textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//       ),

//       outlinedButtonTheme: OutlinedButtonThemeData(
//         style: OutlinedButton.styleFrom(
//           foregroundColor: AppColors.primary,
//           padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//           side: const BorderSide(color: AppColors.primary, width: 1.5),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//       ),

//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: Colors.white,
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 16,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppColors.primary, width: 2),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppColors.error),
//         ),
//         hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
//       ),

//       cardTheme: CardThemeData(
//         color: AppColors.cardBackground,
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         margin: const EdgeInsets.all(8),
//       ),

//       bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//         backgroundColor: Colors.white,
//         selectedItemColor: AppColors.primary,
//         unselectedItemColor: AppColors.textSecondary,
//         type: BottomNavigationBarType.fixed,
//         elevation: 8,
//         selectedLabelStyle: TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w600,
//         ),
//         unselectedLabelStyle: TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w400,
//         ),
//       ),

//       textTheme: const TextTheme(
//         displayLarge: TextStyle(
//           fontSize: 32,
//           fontWeight: FontWeight.bold,
//           color: AppColors.textPrimary,
//         ),
//         displayMedium: TextStyle(
//           fontSize: 28,
//           fontWeight: FontWeight.bold,
//           color: AppColors.textPrimary,
//         ),
//         displaySmall: TextStyle(
//           fontSize: 24,
//           fontWeight: FontWeight.w600,
//           color: AppColors.textPrimary,
//         ),
//         headlineMedium: TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.w600,
//           color: AppColors.textPrimary,
//         ),
//         headlineSmall: TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.w600,
//           color: AppColors.textPrimary,
//         ),
//         titleLarge: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//           color: AppColors.textPrimary,
//         ),
//         bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimary),
//         bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondary),
//         bodySmall: TextStyle(fontSize: 12, color: AppColors.textSecondary),
//       ),
//     );
//   }
// }
