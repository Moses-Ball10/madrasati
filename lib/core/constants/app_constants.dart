/// App-wide constants — gamification rules, thresholds, and configuration
class AppConstants {
  AppConstants._();

  // ── App Identity ──
  static const String appName = 'منصة الوئام التعليمية';

  // ── Hearts ──
  static const int initialHearts = 3;

  // ── Pass Threshold ──
  static const int defaultPassThreshold = 70; // percentage

  // ── Stars ──
  static const int threeStarsThreshold = 95;
  static const int twoStarsThreshold = 75;
  static const int oneStarThreshold = 70;

  static int calculateStars(int scorePercent) {
    if (scorePercent >= threeStarsThreshold) return 3;
    if (scorePercent >= twoStarsThreshold) return 2;
    if (scorePercent >= oneStarThreshold) return 1;
    return 0;
  }

  // ── XP Rewards ──
  static const int xpOneStar = 50;
  static const int xpTwoStars = 75;
  static const int xpThreeStars = 100;
  static const int xpRedoImproved = 10;
  static const int defaultLevelXpReward = 50;

  static int xpForStars(int stars) {
    switch (stars) {
      case 3:
        return xpThreeStars;
      case 2:
        return xpTwoStars;
      case 1:
        return xpOneStar;
      default:
        return 0;
    }
  }

  // ── XP Levels (for display) ──
  static const int xpPerLevel = 500;

  static int userLevel(int totalXp) => (totalXp ~/ xpPerLevel) + 1;
  static int xpInCurrentLevel(int totalXp) => totalXp % xpPerLevel;
  static double xpProgress(int totalXp) =>
      (totalXp % xpPerLevel) / xpPerLevel;

  // ── Streaks ──
  static const int streakBadgeDays = 7;

  // ── Badges ──
  static const String badgeFirstLesson = 'first_lesson';
  static const String badgeWeekStreak = 'week_streak';
  static const String badgePerfectScore = 'perfect_score';
  static const String badgeCategoryMaster = 'category_master';
  static const String badgeTop3 = 'top_3';

  static const Map<String, String> badgeLabels = {
    badgeFirstLesson: 'الدرس الأول',
    badgeWeekStreak: 'أسبوع متواصل',
    badgePerfectScore: 'علامة كاملة',
    badgeCategoryMaster: 'متقن الفئة',
    badgeTop3: 'من أفضل ٣',
  };

  static const Map<String, String> badgeIcons = {
    badgeFirstLesson: '📖',
    badgeWeekStreak: '🔥',
    badgePerfectScore: '⭐',
    badgeCategoryMaster: '🏆',
    badgeTop3: '🥇',
  };

  // ── Leaderboard ──
  static const int leaderboardLimit = 20;

  // ── Arabic Letter Labels (for QCM options) ──
  static const List<String> optionLabels = ['أ', 'ب', 'ج', 'د'];

  // ── Islamic Decorations (for level map background) ──
  static const List<String> islamicDecorations = [
    '☪',
    '🌙',
    '⭐',
    '📿',
    '🕌',
    '✦',
  ];
}
