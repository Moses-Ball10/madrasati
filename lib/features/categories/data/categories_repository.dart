import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../categories/domain/category_model.dart';
import '../../../core/utils/network_info.dart';

class CategoriesRepository {
  final FirebaseFirestore _firestore;
  final NetworkInfo _networkInfo;

  CategoriesRepository({FirebaseFirestore? firestore, NetworkInfo? networkInfo})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _networkInfo = networkInfo ?? NetworkInfo();

  Future<List<Map<String, dynamic>>> getCategoriesWithStats(String userId) async {
    final isConnected = await _networkInfo.isConnected;
    
    if (isConnected) {
      return _fetchFromNetworkAndCache(userId);
    } else {
      return _fetchFromCache(userId);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchFromNetworkAndCache(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .orderBy('order')
          .get();

      List<Map<String, dynamic>> categoriesWithStats = [];
      final box = Hive.box('categories_box');
      
      // Clear old cache for fresh sync
      await box.clear();

      for (var doc in snapshot.docs) {
        final category = CategoryModel.fromFirestore(doc);
        if (!category.isActive) continue; // Filter in Dart to avoid composite index requirement
        
        final levelsSnapshot = await _firestore
            .collection('categories')
            .doc(category.id)
            .collection('levels')
            .where('isActive', isEqualTo: true)
            .get();
        final totalLevels = levelsSnapshot.docs.length;

        final progressSnapshot = await _firestore
            .collection('progress')
            .doc(userId)
            .collection('levels')
            .where('categoryId', isEqualTo: category.id)
            .where('status', isEqualTo: 'completed')
            .get();
        final completedLevels = progressSnapshot.docs.length;

        final item = {
          'category': category,
          'totalLevels': totalLevels,
          'completedLevels': completedLevels,
        };
        
        categoriesWithStats.add(item);
        
        // Save to cache
        await box.put(category.id, {
          'categoryData': category.toCacheMap(),
          'totalLevels': totalLevels,
          'completedLevels': completedLevels,
        });
      }

      return categoriesWithStats;
    } catch (e) {
      // Fallback to cache if network fails unexpectedly
      return _fetchFromCache(userId);
    }
  }
  
  Future<List<Map<String, dynamic>>> _fetchFromCache(String userId) async {
    try {
      final box = Hive.box('categories_box');
      List<Map<String, dynamic>> cachedData = [];
      
      for (var key in box.keys) {
        final data = box.get(key) as Map;
        final categoryMap = Map<String, dynamic>.from(data['categoryData'] as Map);
        final category = CategoryModel.fromMap(categoryMap);
        
        cachedData.add({
          'category': category,
          'totalLevels': data['totalLevels'] as int? ?? 0,
          'completedLevels': data['completedLevels'] as int? ?? 0,
        });
      }
      
      cachedData.sort((a, b) => (a['category'] as CategoryModel).order.compareTo((b['category'] as CategoryModel).order));
      return cachedData;
    } catch (e) {
      throw Exception('لا يوجد اتصال بالإنترنت ولا توجد بيانات محفوظة مسبقاً.');
    }
  }
}
