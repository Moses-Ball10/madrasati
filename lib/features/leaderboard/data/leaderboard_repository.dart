import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/domain/user_model.dart';
import '../../../core/constants/app_constants.dart';

class LeaderboardRepository {
  final FirebaseFirestore _firestore;

  LeaderboardRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<UserModel>> getLeaderboard() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .where('status', isEqualTo: 'approved')
        .orderBy('xp', descending: true)
        .limit(AppConstants.leaderboardLimit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }
}
