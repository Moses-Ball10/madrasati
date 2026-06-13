import '../../../categories/domain/category_model.dart';
import '../../../level_map/domain/level_model.dart';
import '../../../lesson/domain/lesson_model.dart';
import '../../../test_engine/domain/question_model.dart';

abstract class TeacherEvent {}

class LoadTeacherDashboardStats extends TeacherEvent {}

class LoadDashboardContentStats extends TeacherEvent {}

class LoadDashboardOverview extends TeacherEvent {}

class LoadDashboardResultsStats extends TeacherEvent {}

class LoadDashboardStudents extends TeacherEvent {}

class LoadDashboardActivityLogs extends TeacherEvent {}

/// Force-refresh all dashboard data, bypassing cache
class RefreshDashboardStats extends TeacherEvent {}

class LoadCategories extends TeacherEvent {}

class AddCategory extends TeacherEvent {
  final CategoryModel category;
  AddCategory(this.category);
}

class UpdateCategory extends TeacherEvent {
  final CategoryModel category;
  UpdateCategory(this.category);
}

class DeleteCategory extends TeacherEvent {
  final String categoryId;
  DeleteCategory(this.categoryId);
}

class LoadLevels extends TeacherEvent {
  final String categoryId;
  LoadLevels(this.categoryId);
}

class AddLevel extends TeacherEvent {
  final LevelModel level;
  AddLevel(this.level);
}

class UpdateLevel extends TeacherEvent {
  final LevelModel level;
  UpdateLevel(this.level);
}

class DeleteLevel extends TeacherEvent {
  final String categoryId;
  final String levelId;
  DeleteLevel(this.categoryId, this.levelId);
}

class LoadLessons extends TeacherEvent {
  final String categoryId;
  final String levelId;
  LoadLessons(this.categoryId, this.levelId);
}

class AddLesson extends TeacherEvent {
  final String categoryId;
  final LessonModel lesson;
  AddLesson(this.categoryId, this.lesson);
}

class UpdateLesson extends TeacherEvent {
  final String categoryId;
  final LessonModel lesson;
  UpdateLesson(this.categoryId, this.lesson);
}

class DeleteLesson extends TeacherEvent {
  final String categoryId;
  final String levelId;
  final String lessonId;
  DeleteLesson(this.categoryId, this.levelId, this.lessonId);
}

class LoadQuestions extends TeacherEvent {
  final String categoryId;
  final String levelId;
  LoadQuestions(this.categoryId, this.levelId);
}

class AddQuestion extends TeacherEvent {
  final String categoryId;
  final QuestionModel question;
  AddQuestion(this.categoryId, this.question);
}

class UpdateQuestion extends TeacherEvent {
  final String categoryId;
  final QuestionModel question;
  UpdateQuestion(this.categoryId, this.question);
}

class DeleteQuestion extends TeacherEvent {
  final String categoryId;
  final String levelId;
  final String questionId;
  DeleteQuestion(this.categoryId, this.levelId, this.questionId);
}

class ImportLessonsCSV extends TeacherEvent {
  final String categoryId;
  final String csvString;
  ImportLessonsCSV(this.categoryId, this.csvString);
}
