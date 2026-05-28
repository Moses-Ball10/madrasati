import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../domain/question_model.dart';
import '../../../core/utils/network_info.dart';

class TestRepository {
  final FirebaseFirestore _firestore;
  final NetworkInfo _networkInfo;

  TestRepository({FirebaseFirestore? firestore, NetworkInfo? networkInfo})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _networkInfo = networkInfo ?? NetworkInfo();

  Future<List<QuestionModel>> getQuestionsForLevel(String categoryId, String levelId) async {
    final isConnected = await _networkInfo.isConnected;
    final box = Hive.box('questions_box');

    if (isConnected) {
       try {
         final snapshot = await _firestore
             .collection('categories')
             .doc(categoryId)
             .collection('levels')
             .doc(levelId)
             .collection('questions')
             .orderBy('order')
             .get();

         final questions = snapshot.docs.map((doc) => QuestionModel.fromFirestore(doc)).toList();
         
         // Cache questions using levelId as key
         final cacheList = questions.map((q) => q.toCacheMap()).toList();
         await box.put(levelId, cacheList);
         
         return questions;
       } catch (e) {
          return _getFromCache(box, levelId);
       }
    } else {
       return _getFromCache(box, levelId);
    }
  }

  List<QuestionModel> _getFromCache(Box box, String levelId) {
     final data = box.get(levelId);
     if (data != null) {
        final list = List<dynamic>.from(data as List);
        return list.map((item) => QuestionModel.fromMap(Map<String, dynamic>.from(item as Map))).toList();
     }
     throw Exception('لا يوجد اتصال بالإنترنت ولا توجد أسئلة محفوظة.');
  }
}

