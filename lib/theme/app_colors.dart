import 'package:flutter/material.dart';

/// لوحة ألوان مستوحاة من هوية eFootball البصرية: خلفية داكنة عميقة،
/// توهج أزرق كهربائي، ولمسات ذهبية للعناصر التفاعلية والتتويج.
class AppColors {
  AppColors._();

  // الخلفيات
  static const Color backgroundTop = Color(0xFF060B1E);
  static const Color backgroundBottom = Color(0xFF0A1130);
  static const Color surface = Color(0xFF0E1730);
  static const Color surfaceElevated = Color(0xFF121D3D);
  static const Color surfaceLight = Color(0xFF16213F);

  // الأزرق الكهربائي (اللون الأساسي للهوية)
  static const Color electricBlue = Color(0xFF1E5FFF);
  static const Color electricBlueLight = Color(0xFF4E8BFF);
  static const Color electricBlueGlow = Color(0xFF2E6BFF);

  // الذهبي (أزرار الإجراء الرئيسية، التتويج، العناصر المفعّلة)
  static const Color gold = Color(0xFFFFC400);
  static const Color goldLight = Color(0xFFFFD54F);
  static const Color goldDark = Color(0xFFE0A800);

  // ألوان الحالة
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFFF9F1C);
  static const Color danger = Color(0xFFE74C3C);

  // النصوص
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB8C2E0);
  static const Color textMuted = Color(0xFF6B7597);

  // حدود البطاقات
  static const Color borderBlue = Color(0xFF23407A);
  static const Color borderGold = Color(0xFFFFC400);

  /// تدرج الخلفية الرئيسي للتطبيق (شبيه بخلفية الاستاد الداكنة)
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundTop, backgroundBottom],
  );

  /// تدرج ذهبي لأزرار الإجراء الرئيسية (CTA)
  static const LinearGradient goldButtonGradient = LinearGradient(
    begin: Alignment.centerRight,
    end: Alignment.centerLeft,
    colors: [goldDark, goldLight],
  );

  /// تدرج أزرق للعناصر الثانوية والشارات
  static const LinearGradient blueGlowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [electricBlue, Color(0xFF0D3AA8)],
  );

  /// ألوان هوية كل بطولة (نفس فكرة الفصل 9.6 لكن بدرجات متوافقة مع الهوية الداكنة)
  static const Map<String, Color> tournamentAccent = {
    'worldCup': gold,
    'africaCup': Color(0xFF2ECC71),
    'europeCup': electricBlue,
    'copaAmerica': Color(0xFFE74C3C),
    'uclOldFormat': electricBlue,
    'uclNewFormat': Color(0xFF7C3AED),
    'laLiga': Color(0xFFE74C3C),
    'premierLeague': Color(0xFF7C3AED),
    'serieA': electricBlue,
    'bundesliga': Color(0xFFE74C3C),
    'ligue1': Color(0xFF2ECC71),
    'customLeague': electricBlue,
    'customCup': gold,
    'customGroupsKnockout': Color(0xFF2ECC71),
  };
}
