import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ActivityLogModel extends Equatable {
  final String id;
  final String type;
  final String title;
  final String body;
  final DateTime timestamp;
  final String? relatedUserId;
  final String? relatedLevelId;
  final String? relatedCategoryId;

  const ActivityLogModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    this.relatedUserId,
    this.relatedLevelId,
    this.relatedCategoryId,
  });

  factory ActivityLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityLogModel(
      id: doc.id,
      type: data['type'] as String? ?? 'info',
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      relatedUserId: data['relatedUserId'] as String?,
      relatedLevelId: data['relatedLevelId'] as String?,
      relatedCategoryId: data['relatedCategoryId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'body': body,
      'timestamp': Timestamp.fromDate(timestamp),
      'relatedUserId': relatedUserId,
      'relatedLevelId': relatedLevelId,
      'relatedCategoryId': relatedCategoryId,
    };
  }

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        body,
        timestamp,
        relatedUserId,
        relatedLevelId,
        relatedCategoryId,
      ];
}
