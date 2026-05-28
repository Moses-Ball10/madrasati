import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Category data model
class CategoryModel extends Equatable {
  final String id;
  final String name;
  final String icon;
  final int order;
  final String createdBy;
  final DateTime createdAt;
  final bool isActive;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.order,
    required this.createdBy,
    required this.createdAt,
    this.isActive = true,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      icon: data['icon'] as String? ?? '📚',
      order: data['order'] as int? ?? 0,
      createdBy: data['createdBy'] as String? ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  factory CategoryModel.fromMap(Map<String, dynamic> data) {
    return CategoryModel(
      id: data['id'] as String? ?? '',
      name: data['name'] as String? ?? '',
      icon: data['icon'] as String? ?? '📚',
      order: data['order'] as int? ?? 0,
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: DateTime.tryParse(data['createdAt'] as String? ?? '') ??
          DateTime.now(),
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'order': order,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }

  Map<String, dynamic> toCacheMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'order': order,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? icon,
    int? order,
    String? createdBy,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      order: order ?? this.order,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, icon, order, createdBy, createdAt, isActive];
}
