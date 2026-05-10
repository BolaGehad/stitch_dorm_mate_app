import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'notification_service.dart';

class ChoreService {
  ChoreService._();

  static final ChoreService instance = ChoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchNextPendingChore(String houseId) {
    return _firestore
        .collection('chores')
        .where('houseId', isEqualTo: houseId)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchPendingChores(String houseId) {
    return _firestore
        .collection('chores')
        .where('houseId', isEqualTo: houseId)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchCompletedChores(String houseId) {
    return _firestore
        .collection('chores')
        .where('houseId', isEqualTo: houseId)
        .where('status', isEqualTo: 'completed')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchAllChores(String houseId) {
    return _firestore
        .collection('chores')
        .where('houseId', isEqualTo: houseId)
        .snapshots();
  }

  Future<void> createChore({
    required String houseId,
    required String title,
    required String description,
    required DateTime dueAt,
    required bool isHighPriority,
    required List<String> assignedUserIds,
  }) async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      throw Exception('You need to be logged in.');
    }

    final now = FieldValue.serverTimestamp();
    final assignees =
        assignedUserIds.isEmpty ? <String>[user.uid] : assignedUserIds;

    await _firestore.collection('chores').add({
      'houseId': houseId,
      'title': title,
      'description': description,
      'dueAt': Timestamp.fromDate(dueAt),
      'status': 'pending',
      'isHighPriority': isHighPriority,
      'assignedUserIds': assignees,
      'assigneeCount': assignees.length,
      'completedByUserIds': <String>[],
      'completedByCount': 0,
      'createdBy': user.uid,
      'createdAt': now,
      'updatedAt': now,
      'completedAt': null,
    });

    await NotificationService.instance.notifyHousemates(
      houseId: houseId,
      type: 'chore',
      title: 'New chore',
      body:
          '${user.displayName ?? user.email ?? 'Someone'} added a chore: $title.',
      excludeUserId: user.uid,
    );
  }

  Future<void> markChoreDone(String choreId) async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      throw Exception('You need to be logged in.');
    }

    final docRef = _firestore.collection('chores').doc(choreId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) {
        throw Exception('Chore not found.');
      }

      final data = snap.data() as Map<String, dynamic>;
      final doneBy = List<String>.from(data['completedByUserIds'] ?? []);
      final assigneeCount = (data['assigneeCount'] as num?)?.toInt() ?? 1;
      final currentCount = (data['completedByCount'] as num?)?.toInt() ?? doneBy.length;

      if (doneBy.contains(user.uid)) {
        return;
      }

      final updatedDoneBy = [...doneBy, user.uid];
      final newCount = currentCount + 1;
      final isFullyDone = newCount >= assigneeCount;

      tx.update(docRef, {
        'completedByUserIds': updatedDoneBy,
        'completedByCount': newCount,
        'status': isFullyDone ? 'completed' : 'pending',
        'completedAt': isFullyDone ? FieldValue.serverTimestamp() : null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
