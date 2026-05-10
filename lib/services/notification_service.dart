import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth_service.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// In-app notifications for the signed-in user (stored under `users/{uid}/notifications`).
  Stream<QuerySnapshot<Map<String, dynamic>>> watchMyNotifications() {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      throw Exception('You need to be logged in.');
    }
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .snapshots();
  }

  Future<void> deleteNotification(String notificationId) async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      throw Exception('You need to be logged in.');
    }
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  /// Writes one notification doc per housemate except [excludeUserId].
  Future<void> notifyHousemates({
    required String houseId,
    required String type,
    required String title,
    required String body,
    String? excludeUserId,
  }) async {
    final actor = AuthService.instance.currentUser;
    if (actor == null) {
      throw Exception('You need to be logged in.');
    }

    final members = await _firestore
        .collection('house_members')
        .where('houseId', isEqualTo: houseId)
        .get();

    final batch = _firestore.batch();
    final now = FieldValue.serverTimestamp();
    var count = 0;

    for (final doc in members.docs) {
      final recipientId = (doc.data()['userId'] as String?) ?? '';
      if (recipientId.isEmpty) continue;
      if (excludeUserId != null && recipientId == excludeUserId) continue;

      final notifRef = _firestore
          .collection('users')
          .doc(recipientId)
          .collection('notifications')
          .doc();
      batch.set(notifRef, {
        'houseId': houseId,
        'type': type,
        'title': title,
        'body': body,
        'actorUserId': actor.uid,
        'actorName': actor.displayName ?? actor.email ?? 'Someone',
        'createdAt': now,
      });
      count++;
    }

    if (count > 0) {
      await batch.commit();
    }
  }
}
