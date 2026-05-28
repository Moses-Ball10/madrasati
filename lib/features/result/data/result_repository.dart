import 'package:cloud_firestore/cloud_firestore.dart';
import '../../level_map/domain/progress_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/activity_logger.dart';

class ResultRepository {
  final FirebaseFirestore _firestore;

  ResultRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> saveResult({
    required String userId,
    required String categoryId,
    required String levelId,
    required int score,
    required int stars,
  }) async {
    try {
      final progressRef = _firestore
          .collection('progress')
          .doc(userId)
          .collection('levels')
          .doc(levelId);

      final doc = await progressRef.get();
      int xpToAdd = 0;
      bool isFirstTimeCompletion = false;

      if (doc.exists) {
        final existing = ProgressModel.fromFirestore(doc);
        
        int bestScore = existing.bestScore;
        if (score > bestScore) {
           bestScore = score;
        }

        if (existing.status != LevelStatus.completed && stars > 0) {
            // First time passing
            isFirstTimeCompletion = true;
            xpToAdd = AppConstants.xpForStars(stars);
        } else if (score > existing.bestScore) {
            // Redo and improved
            xpToAdd = AppConstants.xpRedoImproved;
        }

        final newStatus = (stars > 0 || existing.status == LevelStatus.completed)
            ? LevelStatus.completed.name
            : LevelStatus.unlocked.name;

        await progressRef.update({
          'status': newStatus,
          'bestScore': bestScore,
          'stars': stars > existing.stars ? stars : existing.stars,
          'completedAt': FieldValue.serverTimestamp(),
          'categoryId': categoryId,
        });

      } else {
        if (stars > 0) {
            isFirstTimeCompletion = true;
        }
        xpToAdd = AppConstants.xpForStars(stars);
        
        final newStatus = stars > 0 ? LevelStatus.completed.name : LevelStatus.unlocked.name;
        
        await progressRef.set({
          'userId': userId,
          'categoryId': categoryId,
          'levelId': levelId,
          'status': newStatus,
          'bestScore': score,
          'stars': stars,
          'completedAt': FieldValue.serverTimestamp(),
        });
      }

      // Streak & Badge Logic
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final int currentStreak = userData['streak'] ?? 0;
        final Timestamp? lastActiveTs = userData['lastActiveAt'] as Timestamp?;
        List<dynamic> currentBadges = userData['badges'] ?? [];
        
        int newStreak = currentStreak;
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        
        if (lastActiveTs != null) {
          final lastActiveDate = lastActiveTs.toDate();
          final lastActiveDay = DateTime(lastActiveDate.year, lastActiveDate.month, lastActiveDate.day);
          
          final difference = today.difference(lastActiveDay).inDays;
          if (difference == 1) {
            newStreak += 1;
          } else if (difference > 1) {
            newStreak = 1; // Reset streak if missed a day
          }
        } else {
          newStreak = 1; // First activity
        }

        List<String> newBadges = List<String>.from(currentBadges);
        
        // Check for new badges
        if (isFirstTimeCompletion && !newBadges.contains(AppConstants.badgeFirstLesson)) {
          newBadges.add(AppConstants.badgeFirstLesson);
        }
        if (score == 100 && !newBadges.contains(AppConstants.badgePerfectScore)) {
          newBadges.add(AppConstants.badgePerfectScore);
        }
        if (newStreak >= AppConstants.streakBadgeDays && !newBadges.contains(AppConstants.badgeWeekStreak)) {
          newBadges.add(AppConstants.badgeWeekStreak);
        }

        // Update user
        await _firestore.collection('users').doc(userId).update({
          if (xpToAdd > 0) 'xp': FieldValue.increment(xpToAdd),
          'streak': newStreak,
          'badges': newBadges,
          'lastActiveAt': FieldValue.serverTimestamp(),
        });
      } else if (xpToAdd > 0) {
        // Fallback if user doc weirdly doesn't exist but we want to add xp
        await _firestore.collection('users').doc(userId).update({
          'xp': FieldValue.increment(xpToAdd),
        });
      }

      // Log activity
      try {
         final userDocFetch = await _firestore.collection('users').doc(userId).get();
         final studentName = userDocFetch.data()?['name'] ?? 'طالب';
         
         final levelDocFetch = await _firestore.collection('categories').doc(categoryId).collection('levels').doc(levelId).get();
         final levelName = levelDocFetch.data()?['title'] ?? 'مستوى';

         if (stars > 0) {
           await ActivityLogger.log(
             type: 'level_completed',
             title: 'إكمال مستوى',
             body: 'أكمل $studentName مستوى $levelName بنتيجة $score%',
             relatedUserId: userId,
             relatedLevelId: levelId,
             relatedCategoryId: categoryId,
           );
         } else {
           await ActivityLogger.log(
             type: 'level_failed',
             title: 'رسوب في مستوى',
             body: 'رسب $studentName في مستوى $levelName',
             relatedUserId: userId,
             relatedLevelId: levelId,
             relatedCategoryId: categoryId,
           );
         }
      } catch (e) {
         print('Failed to log level activity: \$e');
      }

      // Unlock next level if this was the first time passing
      if (isFirstTimeCompletion && stars > 0) {
        await _unlockNextLevel(categoryId, levelId, userId);
      }

    } catch (e) {
      throw Exception('فشل في حفظ النتيجة: $e');
    }
  }

  Future<void> _unlockNextLevel(String categoryId, String currentLevelId, String userId) async {
    // 1. Get all levels to find the next one
    final levelsSnapshot = await _firestore
        .collection('categories')
        .doc(categoryId)
        .collection('levels')
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .get();

    String? nextLevelId;
    bool foundCurrent = false;

    for (var doc in levelsSnapshot.docs) {
      if (foundCurrent) {
        nextLevelId = doc.id;
        break;
      }
      if (doc.id == currentLevelId) {
        foundCurrent = true;
      }
    }

    if (nextLevelId != null) {
      final nextProgressRef = _firestore
          .collection('progress')
          .doc(userId)
          .collection('levels')
          .doc(nextLevelId);
          
      final nextDoc = await nextProgressRef.get();
      if (!nextDoc.exists || nextDoc.data()?['status'] == 'locked') {
        await nextProgressRef.set({
          'userId': userId,
          'categoryId': categoryId,
          'levelId': nextLevelId,
          'status': LevelStatus.unlocked.name,
          'bestScore': 0,
          'stars': 0,
        }, SetOptions(merge: true));
      }
    }
  }
}
