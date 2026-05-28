import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityLogger {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> log({
    required String type,
    required String title,
    required String body,
    String? relatedUserId,
    String? relatedLevelId,
    String? relatedCategoryId,
  }) async {
    try {
      await _firestore.collection('activity_log').add({
        'type': type,
        'title': title,
        'body': body,
        'timestamp': FieldValue.serverTimestamp(),
        'relatedUserId': relatedUserId,
        'relatedLevelId': relatedLevelId,
        'relatedCategoryId': relatedCategoryId,
      });
    } catch (e) {
      print('Failed to log activity: $e');
    }
  }
}
