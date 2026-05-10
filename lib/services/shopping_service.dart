import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth_service.dart';
import 'notification_service.dart';

class ShoppingService {
  ShoppingService._();

  static final ShoppingService instance = ShoppingService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchItems(String houseId) {
    return _firestore
        .collection('shopping_items')
        .where('houseId', isEqualTo: houseId)
        .snapshots();
  }

  Future<void> addItem({
    required String houseId,
    required String title,
    required double estimatedPrice,
  }) async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      throw Exception('You need to be logged in.');
    }

    await _firestore.collection('shopping_items').add({
      'houseId': houseId,
      'title': title,
      'requestedBy': user.uid,
      'requestedByName': user.displayName ?? user.email ?? 'Member',
      'estimatedPrice': estimatedPrice,
      'isChecked': false,
      'checkedBy': null,
      'checkedByName': null,
      'isBilled': false,
      'billedExpenseId': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final priceNote = estimatedPrice > 0
        ? ' (~\$${estimatedPrice.toStringAsFixed(2)})'
        : '';
    await NotificationService.instance.notifyHousemates(
      houseId: houseId,
      type: 'shopping',
      title: 'Shopping list',
      body:
          '${user.displayName ?? user.email ?? 'Someone'} added "$title"$priceNote.',
      excludeUserId: user.uid,
    );
  }

  Future<void> toggleItem({
    required String itemId,
    required bool isChecked,
  }) async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      throw Exception('You need to be logged in.');
    }

    await _firestore.collection('shopping_items').doc(itemId).update({
      'isChecked': isChecked,
      'checkedBy': isChecked ? user.uid : null,
      'checkedByName': isChecked ? (user.displayName ?? user.email ?? 'Member') : null,
      'isBilled': false,
      'billedExpenseId': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markItemsAsBilled({
    required List<String> itemIds,
    required String expenseId,
  }) async {
    final batch = _firestore.batch();
    for (final id in itemIds) {
      final ref = _firestore.collection('shopping_items').doc(id);
      batch.update(ref, {
        'isBilled': true,
        'billedExpenseId': expenseId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
}
