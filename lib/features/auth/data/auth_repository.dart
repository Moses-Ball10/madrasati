import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../auth/domain/user_model.dart';
import '../../../core/utils/activity_logger.dart';

/// Repository handling all Firebase Auth and user Firestore operations
class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current Firebase user
  User? get currentUser => _auth.currentUser;

  /// Sign in with email and password
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user!.uid;
      return await getUserById(uid);
    } on FirebaseAuthException {
      rethrow;
    }
  }

  /// Register a new student account
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user!.uid;

      final user = UserModel(
        uid: uid,
        name: name.trim(),
        email: email.trim(),
        role: UserRole.student,
        status: UserStatus.pending,
        xp: 0,
        streak: 0,
        badges: [],
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(user.toMap());
      
      await ActivityLogger.log(
        type: 'student_registered',
        title: 'تسجيل طالب جديد',
        body: 'طلب ${user.name} الانضمام إلى التطبيق',
        relatedUserId: uid,
      );
      
      return user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Get user data from Firestore by UID
  Future<UserModel> getUserById(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw Exception('المستخدم غير موجود');
    }
    return UserModel.fromFirestore(doc);
  }

  /// Stream user data (real-time updates)
  Stream<UserModel?> userStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  /// Check current user status
  Future<UserModel?> checkCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    try {
      return await getUserById(firebaseUser.uid);
    } catch (_) {
      return null;
    }
  }

  /// Update user XP
  Future<void> updateXp(String uid, int additionalXp) async {
    await _firestore.collection('users').doc(uid).update({
      'xp': FieldValue.increment(additionalXp),
    });
  }

  /// Update user streak
  Future<void> updateStreak(String uid, int streak) async {
    await _firestore.collection('users').doc(uid).update({
      'streak': streak,
      'lastActiveDate': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Add badge to user
  Future<void> addBadge(String uid, String badge) async {
    await _firestore.collection('users').doc(uid).update({
      'badges': FieldValue.arrayUnion([badge]),
    });
  }

  /// Update user status (admin action)
  Future<void> updateUserStatus(String uid, UserStatus status) async {
    await _firestore.collection('users').doc(uid).update({
      'status': status.name,
    });
    
    if (status == UserStatus.approved) {
      try {
        final user = await getUserById(uid);
        await ActivityLogger.log(
          type: 'student_approved',
          title: 'تمت الموافقة على طالب',
          body: 'تمت الموافقة على ${user.name}',
          relatedUserId: uid,
        );
      } catch (_) {}
    } else if (status == UserStatus.rejected) {
      try {
        final user = await getUserById(uid);
        await ActivityLogger.log(
          type: 'student_rejected',
          title: 'تم رفض طالب',
          body: 'تم رفض طلب انضمام ${user.name}',
          relatedUserId: uid,
        );
      } catch (_) {}
    }
  }

  /// Update user role (admin action)
  Future<void> updateUserRole(String uid, UserRole role) async {
    await _firestore.collection('users').doc(uid).update({
      'role': role.name,
    });
  }

  /// Get all users (admin)
  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  /// Get pending registration requests (admin)
  Future<List<UserModel>> getPendingUsers() async {
    final snapshot = await _firestore
        .collection('users')
        .where('status', isEqualTo: 'pending')
        .get();
    final users = snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return users;
  }

  /// Create teacher account (admin action)
  Future<void> createTeacherAccount({
    required String name,
    required String email,
  }) async {
    // Create the Firestore user doc with teacher role
    // The teacher will set their password via password reset email
    final tempPassword = 'Temp${DateTime.now().millisecondsSinceEpoch}!';
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: tempPassword,
    );

    final uid = credential.user!.uid;
    final user = UserModel(
      uid: uid,
      name: name.trim(),
      email: email.trim(),
      role: UserRole.teacher,
      status: UserStatus.approved,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(uid).set(user.toMap());

    // Send password reset email so teacher can set their own password
    await _auth.sendPasswordResetEmail(email: email.trim());

    // Sign back out (we signed in as the new user)
    // The admin should still be signed in via their own session
  }

  /// Send password reset email
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Get Firebase Auth error message in Arabic
  static String getArabicErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'لا يوجد حساب بهذا البريد الإلكتروني';
        case 'wrong-password':
          return 'كلمة المرور غير صحيحة';
        case 'email-already-in-use':
          return 'البريد الإلكتروني مستخدم بالفعل';
        case 'weak-password':
          return 'كلمة المرور ضعيفة جداً';
        case 'invalid-email':
          return 'البريد الإلكتروني غير صالح';
        case 'user-disabled':
          return 'تم تعطيل هذا الحساب';
        case 'too-many-requests':
          return 'محاولات كثيرة، يرجى المحاولة لاحقاً';
        case 'network-request-failed':
          return 'خطأ في الاتصال بالإنترنت';
        default:
          return 'حدث خطأ، يرجى المحاولة مجدداً';
      }
    }
    return 'حدث خطأ، يرجى المحاولة مجدداً';
  }
}
