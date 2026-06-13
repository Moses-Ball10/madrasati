import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/teacher_repository.dart';
import '../../domain/activity_log_model.dart';
import 'teacher_event.dart';
import 'teacher_state.dart';

class TeacherBloc extends Bloc<TeacherEvent, TeacherState> {
  final TeacherRepository teacherRepository;

  // ── Cache timestamps ──
  // Stores the last fetch time for each data type so we can avoid
  // redundant Firestore reads when switching between tabs.
  DateTime? _dashboardStatsFetchedAt;
  DateTime? _contentStatsFetchedAt;
  DateTime? _resultsStatsFetchedAt;
  DateTime? _studentsFetchedAt;
  DateTime? _overviewFetchedAt;

  // How long cached data stays fresh before a background re-fetch
  static const _cacheDuration = Duration(minutes: 30);

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
    on<RefreshDashboardStats>(_onRefreshDashboardStats);
  }

  bool _isCacheValid(DateTime? fetchedAt) {
    if (fetchedAt == null) return false;
    return DateTime.now().difference(fetchedAt) < _cacheDuration;
  }

  Future<void> _onLoadDashboardStats(LoadTeacherDashboardStats event, Emitter<TeacherState> emit) async {
    // If we already have dashboard data and cache is valid, skip the fetch
    if (state is TeacherDashboardLoaded && _isCacheValid(_dashboardStatsFetchedAt)) {
      return;
    }

    emit(TeacherLoading());
    try {
      final stats = await teacherRepository.getDashboardStats();
      _dashboardStatsFetchedAt = DateTime.now();
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

  /// Force-refresh: bypasses cache (used by pull-to-refresh / manual refresh button)
  Future<void> _onRefreshDashboardStats(RefreshDashboardStats event, Emitter<TeacherState> emit) async {
    _dashboardStatsFetchedAt = null;
    _contentStatsFetchedAt = null;
    _resultsStatsFetchedAt = null;
    _studentsFetchedAt = null;
    _overviewFetchedAt = null;
    add(LoadTeacherDashboardStats());
  }

  Future<void> _onLoadDashboardContentStats(LoadDashboardContentStats event, Emitter<TeacherState> emit) async {
    if (state is TeacherDashboardLoaded) {
      final currentState = state as TeacherDashboardLoaded;
      // Return cached data if still valid
      if (currentState.contentStats != null && _isCacheValid(_contentStatsFetchedAt)) {
        return;
      }
      try {
        final contentStats = await teacherRepository.getLevelsContentStats();
        _contentStatsFetchedAt = DateTime.now();
        emit(currentState.copyWith(contentStats: contentStats));
      } catch (e) {
        emit(TeacherError('فشل في تحميل محتوى المستويات: $e'));
      }
    }
  }

  Future<void> _onLoadDashboardOverview(LoadDashboardOverview event, Emitter<TeacherState> emit) async {
    if (state is TeacherDashboardLoaded) {
      final currentState = state as TeacherDashboardLoaded;
      // If all overview data is cached and valid, skip
      if (currentState.contentStats != null &&
          currentState.resultsStats != null &&
          currentState.students != null &&
          _isCacheValid(_overviewFetchedAt)) {
        return;
      }
      try {
        // Only fetch what's missing or stale
        final contentStats = (currentState.contentStats != null && _isCacheValid(_contentStatsFetchedAt))
            ? currentState.contentStats!
            : await teacherRepository.getLevelsContentStats();
        final resultsStats = (currentState.resultsStats != null && _isCacheValid(_resultsStatsFetchedAt))
            ? currentState.resultsStats!
            : await teacherRepository.getStudentResultsStats();
        final students = (currentState.students != null && _isCacheValid(_studentsFetchedAt))
            ? currentState.students!
            : await teacherRepository.getAllStudents();

        _overviewFetchedAt = DateTime.now();
        _contentStatsFetchedAt ??= DateTime.now();
        _resultsStatsFetchedAt ??= DateTime.now();
        _studentsFetchedAt ??= DateTime.now();

        emit(currentState.copyWith(
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
      final currentState = state as TeacherDashboardLoaded;
      if (currentState.resultsStats != null && _isCacheValid(_resultsStatsFetchedAt)) {
        return;
      }
      try {
        final resultsStats = await teacherRepository.getStudentResultsStats();
        _resultsStatsFetchedAt = DateTime.now();
        emit(currentState.copyWith(resultsStats: resultsStats));
      } catch (e) {
        emit(TeacherError('فشل في تحميل نتائج الطلاب: $e'));
      }
    }
  }

  Future<void> _onLoadDashboardStudents(LoadDashboardStudents event, Emitter<TeacherState> emit) async {
    if (state is TeacherDashboardLoaded) {
      final currentState = state as TeacherDashboardLoaded;
      if (currentState.students != null && _isCacheValid(_studentsFetchedAt)) {
        return;
      }
      try {
        final students = await teacherRepository.getAllStudents();
        _studentsFetchedAt = DateTime.now();
        emit(currentState.copyWith(students: students));
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
      _invalidateDashboardCache();
      add(LoadCategories());
    } catch (e) {
      emit(TeacherError('فشل في إضافة الفئة: $e'));
    }
  }

  Future<void> _onUpdateCategory(UpdateCategory event, Emitter<TeacherState> emit) async {
    emit(TeacherLoading());
    try {
      await teacherRepository.updateCategory(event.category);
      _invalidateDashboardCache();
      add(LoadCategories());
    } catch (e) {
      emit(TeacherError('فشل في تحديث الفئة: $e'));
    }
  }

  Future<void> _onDeleteCategory(DeleteCategory event, Emitter<TeacherState> emit) async {
    emit(TeacherLoading());
    try {
      await teacherRepository.deleteCategory(event.categoryId);
      _invalidateDashboardCache();
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
      _invalidateDashboardCache();
      add(LoadLevels(event.level.categoryId));
    } catch (e) {
      emit(TeacherError('فشل في إضافة المستوى: $e'));
    }
  }

  Future<void> _onUpdateLevel(UpdateLevel event, Emitter<TeacherState> emit) async {
    emit(TeacherLoading());
    try {
      await teacherRepository.updateLevel(event.level);
      _invalidateDashboardCache();
      add(LoadLevels(event.level.categoryId));
    } catch (e) {
      emit(TeacherError('فشل في تحديث المستوى: $e'));
    }
  }

  Future<void> _onDeleteLevel(DeleteLevel event, Emitter<TeacherState> emit) async {
    emit(TeacherLoading());
    try {
      await teacherRepository.deleteLevel(event.categoryId, event.levelId);
      _invalidateDashboardCache();
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
      _invalidateDashboardCache();
      add(LoadLessons(event.categoryId, event.lesson.levelId));
    } catch (e) {
      emit(TeacherError('فشل في إضافة الدرس: $e'));
    }
  }

  Future<void> _onUpdateLesson(UpdateLesson event, Emitter<TeacherState> emit) async {
    emit(TeacherLoading());
    try {
      await teacherRepository.updateLesson(event.categoryId, event.lesson);
      _invalidateDashboardCache();
      add(LoadLessons(event.categoryId, event.lesson.levelId));
    } catch (e) {
      emit(TeacherError('فشل في تحديث الدرس: $e'));
    }
  }

  Future<void> _onDeleteLesson(DeleteLesson event, Emitter<TeacherState> emit) async {
    emit(TeacherLoading());
    try {
      await teacherRepository.deleteLesson(event.categoryId, event.levelId, event.lessonId);
      _invalidateDashboardCache();
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
      _invalidateDashboardCache();
      add(LoadQuestions(event.categoryId, event.question.levelId));
    } catch (e) {
      emit(TeacherError('فشل في إضافة السؤال: $e'));
    }
  }

  Future<void> _onUpdateQuestion(UpdateQuestion event, Emitter<TeacherState> emit) async {
    emit(TeacherLoading());
    try {
      await teacherRepository.updateQuestion(event.categoryId, event.question);
      _invalidateDashboardCache();
      add(LoadQuestions(event.categoryId, event.question.levelId));
    } catch (e) {
      emit(TeacherError('فشل في تحديث السؤال: $e'));
    }
  }

  Future<void> _onDeleteQuestion(DeleteQuestion event, Emitter<TeacherState> emit) async {
    emit(TeacherLoading());
    try {
      await teacherRepository.deleteQuestion(event.categoryId, event.levelId, event.questionId);
      _invalidateDashboardCache();
      add(LoadQuestions(event.categoryId, event.levelId));
    } catch (e) {
      emit(TeacherError('فشل في حذف السؤال: $e'));
    }
  }

  Future<void> _onImportLessonsCSV(ImportLessonsCSV event, Emitter<TeacherState> emit) async {
    emit(TeacherImporting());
    try {
      await teacherRepository.importLessonsCSV(event.categoryId, event.csvString);
      _invalidateDashboardCache();
      emit(TeacherImportSuccess());
      add(LoadLevels(event.categoryId));
    } catch (e) {
      emit(TeacherError('فشل في استيراد CSV: $e'));
    }
  }

  /// Invalidates all dashboard caches so the next visit re-fetches fresh data.
  /// Called after any content mutation (add/update/delete).
  void _invalidateDashboardCache() {
    _dashboardStatsFetchedAt = null;
    _contentStatsFetchedAt = null;
    _resultsStatsFetchedAt = null;
    _studentsFetchedAt = null;
    _overviewFetchedAt = null;
  }
}
