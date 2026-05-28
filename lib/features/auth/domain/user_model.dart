import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// User roles
enum UserRole { student, teacher, admin }

/// User account status
enum UserStatus { pending, approved, rejected, disabled }

/// User data model
class UserModel extends Equatable {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final UserStatus status;
  final int xp;
  final int streak;
  final DateTime? lastActiveDate;
  final List<String> badges;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    this.xp = 0,
    this.streak = 0,
    this.lastActiveDate,
    this.badges = const [],
    required this.createdAt,
  });

  /// Create from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] as String? ?? doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: _parseRole(data['role'] as String? ?? 'student'),
      status: _parseStatus(data['status'] as String? ?? 'pending'),
      xp: data['xp'] as int? ?? 0,
      streak: data['streak'] as int? ?? 0,
      lastActiveDate: (data['lastActiveDate'] as Timestamp?)?.toDate(),
      badges: List<String>.from(data['badges'] as List? ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create from Map (for Hive cache)
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] as String? ?? '',
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: _parseRole(data['role'] as String? ?? 'student'),
      status: _parseStatus(data['status'] as String? ?? 'pending'),
      xp: data['xp'] as int? ?? 0,
      streak: data['streak'] as int? ?? 0,
      lastActiveDate: data['lastActiveDate'] != null
          ? DateTime.tryParse(data['lastActiveDate'] as String)
          : null,
      badges: List<String>.from(data['badges'] as List? ?? []),
      createdAt: DateTime.tryParse(data['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role.name,
      'status': status.name,
      'xp': xp,
      'streak': streak,
      'lastActiveDate': lastActiveDate != null
          ? Timestamp.fromDate(lastActiveDate!)
          : null,
      'badges': badges,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Convert to cache-friendly map (no Timestamps)
  Map<String, dynamic> toCacheMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role.name,
      'status': status.name,
      'xp': xp,
      'streak': streak,
      'lastActiveDate': lastActiveDate?.toIso8601String(),
      'badges': badges,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    UserRole? role,
    UserStatus? status,
    int? xp,
    int? streak,
    DateTime? lastActiveDate,
    List<String>? badges,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      badges: badges ?? this.badges,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Whether the user can access student content
  bool get isApprovedStudent =>
      role == UserRole.student && status == UserStatus.approved;

  bool get isTeacher => role == UserRole.teacher;
  bool get isAdmin => role == UserRole.admin;
  bool get isPending => status == UserStatus.pending;

  /// Display initials for avatar
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}';
    }
    return name.isNotEmpty ? name[0] : '؟';
  }

  static UserRole _parseRole(String role) {
    switch (role) {
      case 'teacher':
        return UserRole.teacher;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.student;
    }
  }

  static UserStatus _parseStatus(String status) {
    switch (status) {
      case 'approved':
        return UserStatus.approved;
      case 'rejected':
        return UserStatus.rejected;
      case 'disabled':
        return UserStatus.disabled;
      default:
        return UserStatus.pending;
    }
  }

  @override
  List<Object?> get props => [
        uid,
        name,
        email,
        role,
        status,
        xp,
        streak,
        lastActiveDate,
        badges,
        createdAt,
      ];
}
