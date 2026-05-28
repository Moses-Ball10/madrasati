import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/teacher_repository.dart';
import '../../domain/activity_log_model.dart';
import 'teacher_event.dart';
import 'teacher_state.dart';

class TeacherBloc extends Bloc<TeacherEvent, TeacherState> {
  final TeacherRepository teacherRepository;

  TeacherBloc({required this.teacherRepository}) : super(TeacherInitial()) {
    on<LoadTeacherDashboardStats>(_onLoadDashboardStats);
    on<LoadDashboardContentStats>(_onLoadDashboardContentStats);
    on<LoadDashboardOverview>(_onLoadDashboardOverview);
    on<LoadDashboardResultsStats>(_onLoadDashboardResultsStats);
    on<LoadDashboardStudents>(_onLoadDashboardStudents);
    on<LoadDashboardActivityLogs>(_onLoadDashboardActivityLogs);
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
    on<LoadLevels>(_onLoadLevels);
    on<AddLevel>(_onAddLevel);
    on<UpdateLevel>(_onUpdateLevel);
    on<DeleteLevel>(_onDeleteLevel);
    on<LoadLessons>(_onLoadLessons);
    on<AddLesson>(_onAddLesson);
    on<UpdateLesson>(_onUpdateLesson);
    on<DeleteLesson>(_onDeleteLesson);
    on<LoadQuestions>(_onLoadQuestions);
    on<AddQuestion>(_onAddQuestion);
    on<UpdateQuestion>(_onUpdateQuestion);
    on<DeleteQuestion>(_onDeleteQuestion);
    on<ImportLessonsCSV>(_onImportLessonsCSV);
  }

  Future<void> _onLoadDashboardStats(LoadTeacherDashboardStats event, Emitter<TeacherState> emit) async {
    emit(TeacherLoading());
    try {
      final stats = await teacherRepository.getDashboardStats();
      emit(TeacherDashboardLoaded(
        totalCategories: stats['categories'] ?? 0,
        totalLevels: stats['levels'] ?? 0,
        totalQuestions: stats['questions'] ?? 0,
        totalStudents: stats['students'] ?? 0,
      ));
    } catch (e) {
      emit(TeacherError('فشل في تحميل إحصائيات المعلم: $e'));
    }
  }

  Future<void> _onLoadDashboardContentStats(LoadDashboardContentStats event, Emitter<TeacherState> emit) async {
    if (state is TeacherDashboardLoaded) {
      try {
        final contentStats = await teacherRepository.getLevelsContentStats();
        emit((state as TeacherDashboardLoaded).copyWith(contentStats: contentStats));
      } catch (e) {
        emit(TeacherError('فشل في تحميل محتوى المستويات: $e'));
      }
    }
  }

  Future<void> _onLoadDashboardOverview(LoadDashboardOverview event, Emitter<TeacherState> emit) async {
    if (state is TeacherDashboardLoaded) {
      try {
        final contentStats = await teacherRepository.getLevelsContentStats();
        final resultsStats = await teacherRepository.getStudentResultsStats();
        final students = await teacherRepository.getAllStudents();
        emit((state as TeacherDashboardLoaded).copyWith(
          contentStats: contentStats,
          resultsStats: resultsStats,
          students: students,
        ));
      } catch (e) {
        emit(TeacherError('فشل في تحميل نظرة عامة: $e'));
      }
    }
  }

  Future<void> _onLoadDashboardResultsStats(LoadDashboardResultsStats event, Emitter<TeacherState> emit) async {
    if (state is TeacherDashboardLoaded) {
      try {
        final resultsStats = await teacherRepository.getStudentResultsStats();
        emit((state as TeacherDashboardLoaded).copyWith(resultsStats: resultsStats));
      } catch (e) {
        emit(TeacherError('فشل في تحميل نتائج الطلاب: $e'));
      }
    }
  }

  Future<void> _onLoadDashboardStudents(LoadDashboardStudents event, Emitter<TeacherState> emit) async {
    if (state is TeacherDashboardLoaded) {
      try {
        final students = await teacherRepository.getAllStudents();
        emit((state as TeacherDashboardLoaded).copyWith(students: students));
      } catch (e) {
        emit(TeacherError('فشل في تحميل الطلاب: $e'));
      }
    }
  }

  Future<void> _onLoadDashboardActivityLogs(LoadDashboardActivityLogs event, Emitter<TeacherState> emit) async {
    if (state is TeacherDashboardLoaded) {
      await emit.forEach<List<ActivityLogModel>>(
        teacherRepository.getActivityLogsStream(),
        onData: (logs) => (state as TeacherDashboardLoaded).copyWith(logs: logs),
        onError: (error, stackTrace) => TeacherError('فشل في تحميل النشاطات: $error'),
      );
    }
  }

  Future<void> _onLoadCategories(LoadCategories event, Emitter<TeacherState> emit) async {
    emit(TeacherLoading());
    try {
      final categories = await teacherRepository.getAllCategories();
      emit(TeacherCategoriesLoaded(categories: categories));
    } catch (e) {
      emit(TeacherError('فشل في تحميل الفئات: $e'));
    }
  }

  Future<void> _onAddCategory(AddCategory event, Emitter<TeacherState> emit) async {
    emit(TeacherLoading());
    try {
      await teacherRepository.addCategory(event.category);
      add(LoadCategories());
    } catch (e) {
      emit(TeacherError('فشل في إضافة الفئة: $e'));
    }
  }

  Future<void> _onUpdateCategory(UpdateCategory event, Emitter<TeacherState> emit) async {
    emit(TeacherLoading());
    try {
      await teacherRepository.updateCategory(event.category);
      add(LoadCategories());
    } catch (e) {
      emit(TeacherError('فشل في تحديث الفئة: $e'));
    }
  }

  Future<void> _onDeleteCategory(DeleteCategory event, Emitter<TeacherState> emit) async {
    emit(TeacherLoading());
    try {
      await teacherRepository.deleteCategory(event.categoryId);
      add(LoadCategories());
    } catch (e) {
      emit(TeacherError('فشل في حذف الفئة: $e'));
    }
  }

  Future<void> _onLoadLevels(LoadLevels event, Emitter<TeacherState> emit) async {
    emit(TeacherLoading());
    try {
      final levels = await teacherRepository.getLevels(event.categoryId);
      emit(TeacherLevelsLoaded(levels: levels));
    } catch (e) {
      emit(TeacherError('فشل في تحميل المستويات: $e'));
    }
  }

  Future<void> _onAddLevel(AddLevel event, Emitter<TeacherState> emit) async {
    emit(TeacherLoading());
    try {
      await teacherRepository.addLevel(event.level);
      add(LoadLevels(event.level.categoryId));
    } catch (e) {
      emit(TeacherError('فشل في إضافة المستوى: $e'));
    }
  }

  Future<void> _onUpdateLevel(UpdateLevel event, Emitter<TeacherState> emit) async {
    emit(TeacherLoading());
    try {
      await teacherRepository.updateLevel(event.level);
      add(LoadLevels(event.level.categoryId));
    } catch (e) {
      emit(TeacherError('فشل في تحديث المستوى: $e'));
    }
  }

  Future<void> _onDeleteLevel(DeleteLevel event, Emitter<TeacherState> emit) async {
    emit(TeacherLoading());
    try {
      await teacherRepository.deleteLevel(event.categoryId, event.levelId);
      add(LoadLevels(event.categoryId));
    } catch (e) {
      emit(TeacherError('فشل في حذف المستوى: $e'));
    }
  }

  Future<void> _onLoadLessons(LoadLessons event, Emitter<TeacherState> emit) async {
    emit(TeacherLoading());
    try {
      final lessons = await teacherRepository.getLessons(event.categoryId, event.levelId);
      emit(TeacherLessonsLoaded(lessons: lessons));
    } catch (e) {
      emit(TeacherError('فشل في تحميل الدروس: $e'));
    }
  }

  Future<void> _onAddLesson(AddLesson event, Emitter<TeacherState> emit) async {
    emit(TeacherLoading());
    try {
      await teacherRepository.addLesson(event.categoryId, event.lesson);
      add(LoadLessons(event.categoryId, event.lesson.levelId));
    } catch (e) {
      emit(TeacherError('فشل في إضافة الدرس: $e'));
    }
  }

  Future<void> _onUpdateLesson(UpdateLesson event, Emitter<TeacherState> emit) async {
    emit(TeacherLoading());
    try {
      await teacherRepository.updateLesson(event.categoryId, event.lesson);
      add(LoadLessons(event.categoryId, event.lesson.levelId));
    } catch (e) {
      emit(TeacherError('فشل في تحديث الدرس: $e'));
    }
  }

  Future<void> _onDeleteLesson(DeleteLesson event, Emitter<TeacherState> emit) async {
    emit(TeacherLoading());
    try {
      await teacherRepository.deleteLesson(event.categoryId, event.levelId, event.lessonId);
      add(LoadLessons(event.categoryId, event.levelId));
    } catch (e) {
      emit(TeacherError('فشل في حذف الدرس: $e'));
    }
  }

  Future<void> _onLoadQuestions(LoadQuestions event, Emitter<TeacherState> emit) async {
    emit(TeacherLoading());
    try {
      final questions = await teacherRepository.getQuestions(event.categoryId, event.levelId);
      emit(TeacherQuestionsLoaded(questions: questions));
    } catch (e) {
      emit(TeacherError('فشل في تحميل الأسئلة: $e'));
    }
  }

  Future<void> _onAddQuestion(AddQuestion event, Emitter<TeacherState> emit) async {
    emit(TeacherLoading());
    try {
      await teacherRepository.addQuestion(event.categoryId, event.question);
      add(LoadQuestions(event.categoryId, event.question.levelId));
    } catch (e) {
      emit(TeacherError('فشل في إضافة السؤال: $e'));
    }
  }

  Future<void> _onUpdateQuestion(UpdateQuestion event, Emitter<TeacherState> emit) async {
    emit(TeacherLoading());
    try {
      await teacherRepository.updateQuestion(event.categoryId, event.question);
      add(LoadQuestions(event.categoryId, event.question.levelId));
    } catch (e) {
      emit(TeacherError('فشل في تحديث السؤال: $e'));
    }
  }

  Future<void> _onDeleteQuestion(DeleteQuestion event, Emitter<TeacherState> emit) async {
    emit(TeacherLoading());
    try {
      await teacherRepository.deleteQuestion(event.categoryId, event.levelId, event.questionId);
      add(LoadQuestions(event.categoryId, event.levelId));
    } catch (e) {
      emit(TeacherError('فشل في حذف السؤال: $e'));
    }
  }

  Future<void> _onImportLessonsCSV(ImportLessonsCSV event, Emitter<TeacherState> emit) async {
    emit(TeacherImporting());
    try {
      await teacherRepository.importLessonsCSV(event.categoryId, event.csvString);
      emit(TeacherImportSuccess());
      add(LoadLevels(event.categoryId));
    } catch (e) {
      emit(TeacherError('فشل في استيراد CSV: $e'));
    }
  }
}
