import 'package:cloud_firestore/cloud_firestore.dart';
import '../../categories/domain/category_model.dart';
import '../../level_map/domain/level_model.dart';
import '../../lesson/domain/lesson_model.dart';
import '../../test_engine/domain/question_model.dart';
import '../domain/activity_log_model.dart';
import '../../../core/utils/activity_logger.dart';
import 'package:csv/csv.dart';

class TeacherRepository {
  final FirebaseFirestore _firestore;

  TeacherRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Map<String, int>> getDashboardStats() async {
    try {
      final categoriesSnapshot = await _firestore.collection('categories').count().get();
      final levelsQuery = await _firestore.collectionGroup('levels').count().get();
      final questionsQuery = await _firestore.collectionGroup('questions').count().get();
      final usersSnapshot = await _firestore.collection('users').where('role', isEqualTo: 'student').count().get();

      return {
        'categories': categoriesSnapshot.count ?? 0,
        'levels': levelsQuery.count ?? 0,
        'questions': questionsQuery.count ?? 0,
        'students': usersSnapshot.count ?? 0,
      };
    } catch (e) {
      throw Exception('Failed to get stats: $e');
    }
  }

  // ── Categories ──

  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').orderBy('order').get();
      return snapshot.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      final docRef = _firestore.collection('categories').doc();
      final newCategory = CategoryModel(
        id: docRef.id,
        name: category.name,
        icon: category.icon,
        order: category.order,
        createdBy: category.createdBy,
        createdAt: category.createdAt,
        isActive: category.isActive,
      );
      await docRef.set(newCategory.toMap());
    } catch (e) {
      throw Exception('Failed to add category: $e');
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      await _firestore.collection('categories').doc(category.id).update(category.toMap());
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _firestore.collection('categories').doc(categoryId).delete();
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  // ── Levels ──

  Future<List<LevelModel>> getLevels(String categoryId) async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .doc(categoryId)
          .collection('levels')
          .orderBy('order')
          .get();
      return snapshot.docs.map((doc) => LevelModel.fromFirestore(doc, categoryId)).toList();
    } catch (e) {
      throw Exception('Failed to get levels: $e');
    }
  }

  Future<void> addLevel(LevelModel level) async {
    try {
      final docRef = _firestore
          .collection('categories')
          .doc(level.categoryId)
          .collection('levels')
          .doc();
      final newLevel = LevelModel(
        id: docRef.id,
        categoryId: level.categoryId,
        title: level.title,
        order: level.order,
        xpReward: level.xpReward,
        passThreshold: level.passThreshold,
        isActive: level.isActive,
        createdAt: level.createdAt,
      );
      await docRef.set(newLevel.toMap());
    } catch (e) {
      throw Exception('Failed to add level: $e');
    }
  }

  Future<void> updateLevel(LevelModel level) async {
    try {
      await _firestore
          .collection('categories')
          .doc(level.categoryId)
          .collection('levels')
          .doc(level.id)
          .update(level.toMap());
    } catch (e) {
      throw Exception('Failed to update level: $e');
    }
  }

  Future<void> deleteLevel(String categoryId, String levelId) async {
    try {
      await _firestore
          .collection('categories')
          .doc(categoryId)
          .collection('levels')
          .doc(levelId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete level: $e');
    }
  }

  // ── Lessons ──

  Future<List<LessonModel>> getLessons(String categoryId, String levelId) async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .doc(categoryId)
          .collection('levels')
          .doc(levelId)
          .collection('lessons')
          .orderBy('order')
          .get();
      return snapshot.docs.map((doc) => LessonModel.fromFirestore(doc, levelId)).toList();
    } catch (e) {
      throw Exception('Failed to get lessons: $e');
    }
  }

  Future<void> addLesson(String categoryId, LessonModel lesson) async {
    try {
      final docRef = _firestore
          .collection('categories')
          .doc(categoryId)
          .collection('levels')
          .doc(lesson.levelId)
          .collection('lessons')
          .doc();
      final newLesson = LessonModel(
        id: docRef.id,
        levelId: lesson.levelId,
        order: lesson.order,
        cards: lesson.cards,
        createdAt: lesson.createdAt,
      );
      await docRef.set(newLesson.toMap());

      try {
         final levelDoc = await _firestore.collection('categories').doc(categoryId).collection('levels').doc(lesson.levelId).get();
         final levelName = levelDoc.data()?['title'] ?? 'مستوى';
         await ActivityLogger.log(
           type: 'content_added',
           title: 'محتوى جديد',
           body: 'تمت إضافة بطاقات دروس إلى مستوى $levelName',
           relatedLevelId: lesson.levelId,
           relatedCategoryId: categoryId,
         );
      } catch (_) {}
    } catch (e) {
      throw Exception('Failed to add lesson: $e');
    }
  }

  Future<void> updateLesson(String categoryId, LessonModel lesson) async {
    try {
      await _firestore
          .collection('categories')
          .doc(categoryId)
          .collection('levels')
          .doc(lesson.levelId)
          .collection('lessons')
          .doc(lesson.id)
          .update(lesson.toMap());
    } catch (e) {
      throw Exception('Failed to update lesson: $e');
    }
  }

  Future<void> deleteLesson(String categoryId, String levelId, String lessonId) async {
    try {
      await _firestore
          .collection('categories')
          .doc(categoryId)
          .collection('levels')
          .doc(levelId)
          .collection('lessons')
          .doc(lessonId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete lesson: $e');
    }
  }

  Future<void> importLessonsCSV(String categoryId, String csvString) async {
    try {
      List<List<dynamic>> rows = csv.decode(csvString);
      if (rows.isEmpty) return;
      
      // Skip header
      if (rows.first.isNotEmpty && rows.first[0].toString().toLowerCase().contains('level')) {
        rows.removeAt(0);
      }

      // Group cards by Level Title
      Map<String, List<LessonCard>> levelCardsMap = {};
      Map<String, int> levelXPMap = {};
      Map<String, int> levelPassMap = {};

      for (var row in rows) {
        if (row.length < 5) continue;
        
        final levelTitle = row[0].toString().trim();
        final levelXP = int.tryParse(row[1].toString()) ?? 100;
        final levelPass = int.tryParse(row[2].toString()) ?? 70;
        final lessonTitle = row[3].toString().trim();
        final lessonContent = row[4].toString().trim();
        final lessonEmoji = row.length > 5 ? row[5].toString().trim() : '📝';
        
        if (levelTitle.isEmpty || lessonTitle.isEmpty || lessonContent.isEmpty) continue;
        
        levelXPMap[levelTitle] = levelXP;
        levelPassMap[levelTitle] = levelPass;
        
        if (!levelCardsMap.containsKey(levelTitle)) {
          levelCardsMap[levelTitle] = [];
        }
        
        levelCardsMap[levelTitle]!.add(LessonCard(
          icon: lessonEmoji.isEmpty ? '📝' : lessonEmoji,
          title: lessonTitle,
          body: lessonContent,
        ));
      }

      final existingLevels = await getLevels(categoryId);
      Map<String, LevelModel> existingLevelsMap = {};
      for (var l in existingLevels) {
        existingLevelsMap[l.title] = l;
      }
      
      int currentLevelOrder = existingLevels.length;

      for (var entry in levelCardsMap.entries) {
        final levelTitle = entry.key;
        final cards = entry.value;
        
        LevelModel? level = existingLevelsMap[levelTitle];
        
        if (level == null) {
          final docRef = _firestore.collection('categories').doc(categoryId).collection('levels').doc();
          level = LevelModel(
            id: docRef.id,
            categoryId: categoryId,
            title: levelTitle,
            order: currentLevelOrder++,
            xpReward: levelXPMap[levelTitle] ?? 100,
            passThreshold: levelPassMap[levelTitle] ?? 70,
            isActive: true,
            createdAt: DateTime.now(),
          );
          await docRef.set(level.toMap());
        }
        
        final lessonDocRef = _firestore
            .collection('categories').doc(categoryId)
            .collection('levels').doc(level.id)
            .collection('lessons').doc();
            
        final lessonsSnapshot = await _firestore
            .collection('categories').doc(categoryId)
            .collection('levels').doc(level.id)
            .collection('lessons').get();
            
        final newLesson = LessonModel(
          id: lessonDocRef.id,
          levelId: level.id,
          order: lessonsSnapshot.docs.length,
          cards: cards,
          createdAt: DateTime.now(),
        );
        
        await lessonDocRef.set(newLesson.toMap());
        
        try {
           await ActivityLogger.log(
             type: 'content_added',
             title: 'استيراد CSV',
             body: 'تم استيراد ${cards.length} بطاقات درس إلى مستوى $levelTitle',
             relatedLevelId: level.id,
             relatedCategoryId: categoryId,
           );
        } catch (_) {}
      }
    } catch (e) {
      throw Exception('Failed to import CSV: $e');
    }
  }

  // ── Questions ──

  Future<List<QuestionModel>> getQuestions(String categoryId, String levelId) async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .doc(categoryId)
          .collection('levels')
          .doc(levelId)
          .collection('questions')
          .get();
      return snapshot.docs.map((doc) => QuestionModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get questions: $e');
    }
  }

  Future<void> addQuestion(String categoryId, QuestionModel question) async {
    try {
      final docRef = _firestore
          .collection('categories')
          .doc(categoryId)
          .collection('levels')
          .doc(question.levelId)
          .collection('questions')
          .doc();
      final newQuestion = QuestionModel(
        id: docRef.id,
        levelId: question.levelId,
        type: question.type,
        question: question.question,
        options: question.options,
        correctIndex: question.correctIndex,
        sentence: question.sentence,
        answer: question.answer,
        wordIndex: question.wordIndex,
        order: question.order,
      );
      await docRef.set(newQuestion.toMap());

      try {
         final levelDoc = await _firestore.collection('categories').doc(categoryId).collection('levels').doc(question.levelId).get();
         final levelName = levelDoc.data()?['title'] ?? 'مستوى';
         await ActivityLogger.log(
           type: 'content_added',
           title: 'محتوى جديد',
           body: 'تمت إضافة سؤال إلى مستوى $levelName',
           relatedLevelId: question.levelId,
           relatedCategoryId: categoryId,
         );
      } catch (_) {}
    } catch (e) {
      throw Exception('Failed to add question: $e');
    }
  }

  Future<void> updateQuestion(String categoryId, QuestionModel question) async {
    try {
      await _firestore
          .collection('categories')
          .doc(categoryId)
          .collection('levels')
          .doc(question.levelId)
          .collection('questions')
          .doc(question.id)
          .update(question.toMap());
    } catch (e) {
      throw Exception('Failed to update question: $e');
    }
  }

  Future<void> deleteQuestion(String categoryId, String levelId, String questionId) async {
    try {
      await _firestore
          .collection('categories')
          .doc(categoryId)
          .collection('levels')
          .doc(levelId)
          .collection('questions')
          .doc(questionId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete question: $e');
    }
  }

  // ── Dashboard Analytics ──

  Stream<List<ActivityLogModel>> getActivityLogsStream() {
    return _firestore
        .collection('activity_log')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ActivityLogModel.fromFirestore(doc))
            .toList());
  }

  Future<List<Map<String, dynamic>>> getLevelsContentStats() async {
    final categoriesSnapshot = await _firestore.collection('categories').orderBy('order').get();
    List<Map<String, dynamic>> levelsStats = [];

    for (var catDoc in categoriesSnapshot.docs) {
      final categoryName = catDoc.data()['name'] ?? 'فئة غير معروفة';
      final categoryId = catDoc.id;

      final levelsSnapshot = await catDoc.reference.collection('levels').orderBy('order').get();
      for (var levelDoc in levelsSnapshot.docs) {
        final levelData = levelDoc.data();
        final levelName = levelData['title'] ?? 'مستوى';
        final levelId = levelDoc.id;

        // Count lessons
        final lessonsSnapshot = await levelDoc.reference.collection('lessons').get();
        int cardsCount = 0;
        for (var lessonDoc in lessonsSnapshot.docs) {
          final lessonData = lessonDoc.data();
          final cards = lessonData['cards'] as List<dynamic>? ?? [];
          cardsCount += cards.length;
        }

        // Count questions
        final questionsSnapshot = await levelDoc.reference.collection('questions').get();
        final questionsCount = questionsSnapshot.size;

        levelsStats.add({
          'categoryId': categoryId,
          'categoryName': categoryName,
          'levelId': levelId,
          'levelName': levelName,
          'cardsCount': cardsCount,
          'questionsCount': questionsCount,
          'isActive': levelData['isActive'] ?? true,
        });
      }
    }
    return levelsStats;
  }

  Future<List<Map<String, dynamic>>> getStudentResultsStats() async {
    final progressSnapshot = await _firestore.collection('progress').get();
    
    // Map to aggregate stats: levelId -> { attempts, totalScore, fails }
    Map<String, Map<String, dynamic>> levelStatsMap = {};

    for (var userDoc in progressSnapshot.docs) {
      final userLevelsSnapshot = await userDoc.reference.collection('levels').get();
      for (var levelDoc in userLevelsSnapshot.docs) {
        final data = levelDoc.data();
        final levelId = levelDoc.id;
        final stars = data['stars'] as int? ?? 0;
        final score = data['bestScore'] as int? ?? 0;
        final status = data['status'] as String? ?? 'locked';

        if (status != 'locked') {
           if (!levelStatsMap.containsKey(levelId)) {
             levelStatsMap[levelId] = {
               'attempts': 0,
               'totalScore': 0,
               'fails': 0,
             };
           }
           levelStatsMap[levelId]!['attempts'] += 1;
           levelStatsMap[levelId]!['totalScore'] += score;
           if (stars == 0) {
             levelStatsMap[levelId]!['fails'] += 1;
           }
        }
      }
    }

    // Now enrich with level/category names
    List<Map<String, dynamic>> result = [];
    final categoriesSnapshot = await _firestore.collection('categories').get();
    
    for (var catDoc in categoriesSnapshot.docs) {
      final categoryName = catDoc.data()['name'] ?? '';
      final levelsSnapshot = await catDoc.reference.collection('levels').get();
      
      for (var levelDoc in levelsSnapshot.docs) {
        final levelId = levelDoc.id;
        final levelName = levelDoc.data()['title'] ?? '';
        
        if (levelStatsMap.containsKey(levelId)) {
          final stats = levelStatsMap[levelId]!;
          final attempts = stats['attempts'] as int;
          final fails = stats['fails'] as int;
          final totalScore = stats['totalScore'] as int;
          
          final avgScore = attempts > 0 ? (totalScore / attempts).round() : 0;
          final failRate = attempts > 0 ? ((fails / attempts) * 100).round() : 0;
          final passRate = 100 - failRate;

          result.add({
            'levelId': levelId,
            'levelName': levelName,
            'categoryName': categoryName,
            'attempts': attempts,
            'avgScore': avgScore,
            'passRate': passRate,
            'failRate': failRate,
          });
        }
      }
    }

    return result;
  }

  Future<List<Map<String, dynamic>>> getAllStudents() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .get();
        
    final users = snapshot.docs.map((doc) => doc.data()).toList();
    users.sort((a, b) {
      final aDate = a['createdAt'] as Timestamp?;
      final bDate = b['createdAt'] as Timestamp?;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });
    return users;
  }
}
