import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth_service.dart';
import 'chore_service.dart';
import 'house_service.dart';

class GameCenterService {
  GameCenterService._();

  static final GameCenterService instance = GameCenterService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> requireHouseId() => HouseService.instance.getCurrentUserHouseId();

  Future<List<Map<String, dynamic>>> loadPaymentMethods() async {
    final user = AuthService.instance.currentUser;
    if (user == null) throw Exception('You need to be logged in.');
    final snap = await _firestore.collection('users').doc(user.uid).get();
    final raw = snap.data()?['paymentMethods'];
    if (raw is! List) return [];
    return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> savePaymentMethods(List<Map<String, dynamic>> methods) async {
    final user = AuthService.instance.currentUser;
    if (user == null) throw Exception('You need to be logged in.');
    await _firestore.collection('users').doc(user.uid).update({
      'paymentMethods': methods,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchCurrentUserSettings() {
    final user = AuthService.instance.currentUser;
    if (user == null) throw Exception('You need to be logged in.');
    return _firestore.collection('users').doc(user.uid).snapshots();
  }

  Future<void> updateCurrentUserSettings(Map<String, dynamic> fields) async {
    final user = AuthService.instance.currentUser;
    if (user == null) throw Exception('You need to be logged in.');
    await _firestore.collection('users').doc(user.uid).update({
      ...fields,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> assignMysteryChore({
    required String title,
    required String description,
    required bool isHighPriority,
  }) async {
    final houseId = await requireHouseId();
    final uid = AuthService.instance.currentUser!.uid;
    await ChoreService.instance.createChore(
      houseId: houseId,
      title: title,
      description: description,
      dueAt: DateTime.now().add(const Duration(days: 1)),
      isHighPriority: isHighPriority,
      assignedUserIds: [uid],
    );
  }

  Future<void> reportFridgeInspection({
    required List<String> checkedItems,
  }) async {
    final houseId = await requireHouseId();
    final uid = AuthService.instance.currentUser!.uid;
    final checklist = checkedItems.join(', ');
    await _firestore.collection('chores').add({
      'houseId': houseId,
      'title': 'Fridge inspection completed',
      'description': checklist,
      'dueAt': Timestamp.fromDate(DateTime.now()),
      'status': 'completed',
      'isHighPriority': false,
      'assignedUserIds': [uid],
      'assigneeCount': 1,
      'completedByUserIds': [uid],
      'completedByCount': 1,
      'createdBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'completedAt': FieldValue.serverTimestamp(),
    });
  }
}
