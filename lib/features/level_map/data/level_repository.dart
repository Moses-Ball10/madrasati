import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../categories/domain/category_model.dart';
import '../domain/level_model.dart';
import '../domain/progress_model.dart';
import '../../../core/utils/network_info.dart';

class LevelRepository {
  final FirebaseFirestore _firestore;
  final NetworkInfo _networkInfo;

  LevelRepository({FirebaseFirestore? firestore, NetworkInfo? networkInfo})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _networkInfo = networkInfo ?? NetworkInfo();

  Future<CategoryModel> getCategory(String categoryId) async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
       final box = Hive.box('categories_box');
       final data = box.get(categoryId);
       if (data != null) {
          final categoryMap = Map<String, dynamic>.from(data['categoryData'] as Map);
          return CategoryModel.fromMap(categoryMap);
       }
       throw Exception('لا يوجد اتصال بالإنترنت.');
    }

    try {
      final doc = await _firestore.collection('categories').doc(categoryId).get();
      if (!doc.exists) {
        throw Exception('الفئة غير موجودة');
      }
      return CategoryModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('فشل في جلب تفاصيل الفئة: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getLevelsWithProgress(String categoryId, String userId) async {
    final isConnected = await _networkInfo.isConnected;
    
    if (isConnected) {
       return _fetchFromNetworkAndCache(categoryId, userId);
    } else {
       return _fetchFromCache(categoryId, userId);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchFromNetworkAndCache(String categoryId, String userId) async {
    try {
      // 1. Get levels
      final levelsSnapshot = await _firestore
          .collection('categories')
          .doc(categoryId)
          .collection('levels')
          .orderBy('order')
          .get();

      final levels = levelsSnapshot.docs
          .map((doc) => LevelModel.fromFirestore(doc, categoryId))
          .where((level) => level.isActive) // Filter in Dart to avoid composite index
          .toList();

      // 2. Get user progress for this category
      final progressSnapshot = await _firestore
          .collection('progress')
          .doc(userId)
          .collection('levels')
          .where('categoryId', isEqualTo: categoryId)
          .get();

      final progressMap = {
        for (var doc in progressSnapshot.docs)
          doc.id: ProgressModel.fromFirestore(doc)
      };

      // 3. Combine and determine lock status
      List<Map<String, dynamic>> result = [];
      bool previousCompleted = true; 

      final box = Hive.box('levels_box');
      
      for (int i = 0; i < levels.length; i++) {
        final level = levels[i];
        
        bool isUnlocked = i == 0 || previousCompleted;
        ProgressModel? progress = progressMap[level.id];
        
        if (progress == null) {
          progress = ProgressModel(
            userId: userId,
            categoryId: categoryId,
            levelId: level.id,
            status: isUnlocked ? LevelStatus.unlocked : LevelStatus.locked,
          );
        } else if (progress.status == LevelStatus.locked && isUnlocked) {
          progress = progress.copyWith(status: LevelStatus.unlocked);
        }

        result.add({
          'level': level,
          'progress': progress,
        });
        
        // Cache level and progress together using levelId as key
        await box.put(level.id, {
           'levelData': level.toCacheMap(),
           'progressData': progress.toCacheMap(),
        });

        previousCompleted = progress.status == LevelStatus.completed;
      }

      return result;
    } catch (e) {
      return _fetchFromCache(categoryId, userId);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchFromCache(String categoryId, String userId) async {
     try {
        final box = Hive.box('levels_box');
        List<Map<String, dynamic>> result = [];
        
        for (var key in box.keys) {
           final data = box.get(key) as Map;
           final levelMap = Map<String, dynamic>.from(data['levelData'] as Map);
           
           if (levelMap['categoryId'] == categoryId) {
               final level = LevelModel.fromMap(levelMap);
               final progressMap = Map<String, dynamic>.from(data['progressData'] as Map);
               final progress = ProgressModel.fromMap(progressMap);
               
               // Ensure progress matches current user if needed, though usually cache is per user
               if (progress.userId == userId || progress.userId.isEmpty) {
                   result.add({
                     'level': level,
                     'progress': progress.copyWith(userId: userId),
                   });
               }
           }
        }
        
        result.sort((a, b) => (a['level'] as LevelModel).order.compareTo((b['level'] as LevelModel).order));
        
        if (result.isEmpty) {
           throw Exception('لا يوجد اتصال بالإنترنت ولا توجد مستويات محفوظة.');
        }
        
        return result;
     } catch (e) {
        throw Exception('لا يوجد اتصال بالإنترنت ولا توجد بيانات محفوظة مسبقاً.');
     }
  }
}

