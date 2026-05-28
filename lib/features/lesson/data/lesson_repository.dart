import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../domain/lesson_model.dart';
import '../../../core/utils/network_info.dart';

class LessonRepository {
  final FirebaseFirestore _firestore;
  final NetworkInfo _networkInfo;

  LessonRepository({FirebaseFirestore? firestore, NetworkInfo? networkInfo})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _networkInfo = networkInfo ?? NetworkInfo();

  Future<LessonModel?> getLessonForLevel(String categoryId, String levelId) async {
    final isConnected = await _networkInfo.isConnected;
    final box = Hive.box('lessons_box');

    if (isConnected) {
       try {
         final snapshot = await _firestore
             .collection('categories')
             .doc(categoryId)
             .collection('levels')
             .doc(levelId)
             .collection('lessons')
             .orderBy('order')
             .get();

         if (snapshot.docs.isEmpty) {
           return null; // No lesson exists
         }

         List<LessonCard> allCards = [];
         for (var doc in snapshot.docs) {
           final lesson = LessonModel.fromFirestore(doc, levelId);
           allCards.addAll(lesson.cards);
         }

         final lesson = LessonModel(
           id: snapshot.docs.first.id,
           levelId: levelId,
           order: 1,
           cards: allCards,
           createdAt: DateTime.now(),
         );
         
         // Cache the lesson using levelId as key (assuming 1 lesson per level)
         await box.put(levelId, lesson.toCacheMap());
         
         return lesson;
       } catch (e) {
          return _getFromCache(box, levelId);
       }
    } else {
       return _getFromCache(box, levelId);
    }
  }

  LessonModel? _getFromCache(Box box, String levelId) {
     final data = box.get(levelId);
     if (data != null) {
        return LessonModel.fromMap(Map<String, dynamic>.from(data as Map));
     }
     return null;
  }
}

