import '../../../categories/domain/category_model.dart';
import '../../../level_map/domain/level_model.dart';
import '../../../lesson/domain/lesson_model.dart';
import '../../../test_engine/domain/question_model.dart';

import '../../domain/activity_log_model.dart';
import '../../../auth/domain/user_model.dart';

abstract class TeacherState {}

class TeacherInitial extends TeacherState {}

class TeacherLoading extends TeacherState {}

class TeacherDashboardLoaded extends TeacherState {
  final int totalCategories;
  final int totalLevels;
  final int totalQuestions;
  final int totalStudents;
  
  final List<ActivityLogModel>? logs;
  final List<Map<String, dynamic>>? contentStats;
  final List<Map<String, dynamic>>? resultsStats;
  final List<Map<String, dynamic>>? students;
  final List<UserModel>? pendingUsers;

  TeacherDashboardLoaded({
    required this.totalCategories,
    required this.totalLevels,
    required this.totalQuestions,
    required this.totalStudents,
    this.logs,
    this.contentStats,
    this.resultsStats,
    this.students,
    this.pendingUsers,
  });

  TeacherDashboardLoaded copyWith({
    int? totalCategories,
    int? totalLevels,
    int? totalQuestions,
    int? totalStudents,
    List<ActivityLogModel>? logs,
    List<Map<String, dynamic>>? contentStats,
    List<Map<String, dynamic>>? resultsStats,
    List<Map<String, dynamic>>? students,
    List<UserModel>? pendingUsers,
  }) {
    return TeacherDashboardLoaded(
      totalCategories: totalCategories ?? this.totalCategories,
      totalLevels: totalLevels ?? this.totalLevels,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      totalStudents: totalStudents ?? this.totalStudents,
      logs: logs ?? this.logs,
      contentStats: contentStats ?? this.contentStats,
      resultsStats: resultsStats ?? this.resultsStats,
      students: students ?? this.students,
      pendingUsers: pendingUsers ?? this.pendingUsers,
    );
  }
}

class TeacherCategoriesLoaded extends TeacherState {
  final List<CategoryModel> categories;
  TeacherCategoriesLoaded({required this.categories});
}

class TeacherLevelsLoaded extends TeacherState {
  final List<LevelModel> levels;
  TeacherLevelsLoaded({required this.levels});
}

class TeacherLessonsLoaded extends TeacherState {
  final List<LessonModel> lessons;
  TeacherLessonsLoaded({required this.lessons});
}

class TeacherQuestionsLoaded extends TeacherState {
  final List<QuestionModel> questions;
  TeacherQuestionsLoaded({required this.questions});
}

class TeacherError extends TeacherState {
  final String message;
  TeacherError(this.message);
}

class TeacherImporting extends TeacherState {}

class TeacherImportSuccess extends TeacherState {}
