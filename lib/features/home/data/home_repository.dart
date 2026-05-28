import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/domain/user_model.dart';
import '../../categories/domain/category_model.dart';
import '../../level_map/domain/level_model.dart';
import '../../level_map/domain/progress_model.dart';

/// Repository for the Home screen, fetching user dashboard data
class HomeRepository {
  final FirebaseFirestore _firestore;

  HomeRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get user's top 4 active categories
  Future<List<CategoryModel>> getTopCategories() async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .orderBy('order')
          .get();
      return snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .where((cat) => cat.isActive)
          .take(4)
          .toList();
    } catch (e) {
      throw Exception('فشل في جلب الفئات: $e');
    }
  }

  /// Get recently played levels that are unlocked or completed
  Future<List<Map<String, dynamic>>> getRecentInProgressLevels(String userId) async {
     try {
       // Get recent progress — filter in Dart to avoid composite index
       final progressSnapshot = await _firestore
           .collection('progress')
           .doc(userId)
           .collection('levels')
           .get();
       
       // Filter and sort in Dart
       final filteredDocs = progressSnapshot.docs.where((doc) {
         final data = doc.data();
         final status = data['status'] as String? ?? '';
         return status == 'unlocked' || status == 'completed';
       }).toList();
       
       // Sort by completedAt descending
       filteredDocs.sort((a, b) {
         final aTime = a.data()['completedAt'];
         final bTime = b.data()['completedAt'];
         if (aTime == null && bTime == null) return 0;
         if (aTime == null) return 1;
         if (bTime == null) return -1;
         return (bTime as dynamic).compareTo(aTime);
       });
       
       final limitedDocs = filteredDocs.take(2).toList();

       List<Map<String, dynamic>> recentLevels = [];

       for (var doc in limitedDocs) {
         final progress = ProgressModel.fromFirestore(doc);
         // Get level details
         final levelDoc = await _firestore
            .collection('categories')
            .doc(progress.categoryId)
            .collection('levels')
            .doc(progress.levelId)
            .get();
            
         // Get Category details
         final categoryDoc = await _firestore
            .collection('categories')
            .doc(progress.categoryId)
            .get();

         if (levelDoc.exists && categoryDoc.exists) {
            recentLevels.add({
              'progress': progress,
              'level': LevelModel.fromFirestore(levelDoc, progress.categoryId),
              'category': CategoryModel.fromFirestore(categoryDoc)
            });
         }
       }
       return recentLevels;
     } catch (e) {
       print('Error in getRecentInProgressLevels: $e');
       return [];
     }
  }
}
