/// Arabic language helper utilities
class ArabicHelpers {
  ArabicHelpers._();

  /// Eastern Arabic numeral mapping
  static const Map<String, String> _arabicDigits = {
    '0': '٠',
    '1': '١',
    '2': '٢',
    '3': '٣',
    '4': '٤',
    '5': '٥',
    '6': '٦',
    '7': '٧',
    '8': '٨',
    '9': '٩',
  };

  /// Convert Western digits to Eastern Arabic digits
  static String toArabicNumber(dynamic number) {
    final str = number.toString();
    return str.split('').map((c) => _arabicDigits[c] ?? c).join();
  }

  /// Format percentage with Arabic digits
  static String toArabicPercentage(int value) {
    return '${toArabicNumber(value)}٪';
  }

  /// Format time as mm:ss in Arabic digits
  static String formatTimeArabic(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    return '${toArabicNumber(mm)}:${toArabicNumber(ss)}';
  }

  /// Format XP display: "+٥٠ نقطة XP"
  static String formatXp(int xp) {
    return '+${toArabicNumber(xp)} نقطة';
  }

  /// Format "X من Y" (X of Y) in Arabic
  static String formatOfTotal(int current, int total) {
    return '${toArabicNumber(current)} من ${toArabicNumber(total)}';
  }

  /// Format date in Arabic
  static String formatDateArabic(DateTime date) {
    final months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    return '${toArabicNumber(date.day)} ${months[date.month - 1]} ${toArabicNumber(date.year)}';
  }

  /// Ordinal label for level/lesson
  static String levelLabel(int order) {
    return 'المستوى ${toArabicNumber(order)}';
  }

  static String lessonLabel(int order) {
    return 'الدرس ${toArabicNumber(order)}';
  }

  /// Stars display string
  static String starsDisplay(int stars) {
    return '★' * stars + '☆' * (3 - stars);
  }

  /// Normalize Arabic text for comparison:
  /// 1. Trim
  /// 2. Remove tashkeel diacritics (U+064B to U+0652)
  /// 3. Normalize alef variants (أ إ آ → ا)
  /// 4. Normalize teh marbuta (ة → ه)
  /// 5. Normalize dotless yeh (ى → ي)
  /// 6. Lowercase (for any accidental Latin chars)
  static String normalizeArabic(String input) {
    String s = input.trim();
    // Remove tashkeel diacritics
    s = s.replaceAll(RegExp(r'[\u064B-\u0652]'), '');
    // Normalize alef variants
    s = s.replaceAll('أ', 'ا');
    s = s.replaceAll('إ', 'ا');
    s = s.replaceAll('آ', 'ا');
    // Normalize teh marbuta to heh
    s = s.replaceAll('ة', 'ه');
    // Normalize dotless yeh to yeh
    s = s.replaceAll('ى', 'ي');
    // Lowercase for any Latin chars
    s = s.toLowerCase();
    return s;
  }

  /// Strip leading ال from a normalized Arabic string
  static String _stripAl(String s) {
    if (s.startsWith('ال')) return s.substring(2);
    return s;
  }

  /// Check fill-in-the-blank answer with Arabic normalization:
  /// Step 1: direct normalized comparison
  /// Step 2: strip ال prefix and compare again
  static bool checkFillBlankAnswer(String userInput, String correctAnswer) {
    final normalizedUser = normalizeArabic(userInput);
    final normalizedAnswer = normalizeArabic(correctAnswer);

    // Step 1: direct comparison
    if (normalizedUser == normalizedAnswer) return true;

    // Step 2: strip ال and compare
    if (_stripAl(normalizedUser) == _stripAl(normalizedAnswer)) return true;

    return false;
  }
}
