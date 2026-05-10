import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth_service.dart';
import 'notification_service.dart';

class HouseService {
  HouseService._();

  static final HouseService instance = HouseService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchCurrentUserProfile() {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      throw Exception('You need to be logged in.');
    }
    return _firestore.collection('users').doc(user.uid).snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchHouseById(String houseId) {
    return _firestore.collection('houses').doc(houseId).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchHouseMembers(String houseId) {
    return _firestore
        .collection('house_members')
        .where('houseId', isEqualTo: houseId)
        .snapshots();
  }

  Future<String> getCurrentUserHouseId() async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      throw Exception('You need to be logged in.');
    }
    final snap = await _firestore.collection('users').doc(user.uid).get();
    final houseId = snap.data()?['houseId'] as String?;
    if (houseId == null || houseId.isEmpty) {
      throw Exception('You are not part of a house yet.');
    }
    return houseId;
  }

  Future<String> createHouse({
    required String houseName,
    required int memberLimit,
    required String currency,
    required String theme,
  }) async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      throw Exception('You need to be logged in.');
    }

    final houseRef = _firestore.collection('houses').doc();
    final inviteCode = _generateInviteCode();
    final now = FieldValue.serverTimestamp();

    final batch = _firestore.batch();
    batch.set(houseRef, {
      'houseId': houseRef.id,
      'name': houseName,
      'ownerId': user.uid,
      'memberLimit': memberLimit,
      'currency': currency,
      'theme': theme,
      'inviteCode': inviteCode,
      'membersCount': 1,
      'houseRules': <String>[],
      'autoApproveExpense': false,
      'quietHoursNotify': false,
      'createdAt': now,
      'updatedAt': now,
    });
    batch.set(_firestore.collection('house_members').doc('${houseRef.id}_${user.uid}'), {
      'houseId': houseRef.id,
      'userId': user.uid,
      'memberName': user.displayName ?? user.email ?? 'Owner',
      'role': 'owner',
      'joinedAt': now,
    });
    batch.update(_firestore.collection('users').doc(user.uid), {
      'houseId': houseRef.id,
      'role': 'owner',
      'updatedAt': now,
    });

    await batch.commit();
    return houseRef.id;
  }

  Future<String> joinHouseByInviteCode(String rawCode) async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      throw Exception('You need to be logged in.');
    }

    final inviteCode = rawCode.trim().toUpperCase();
    if (inviteCode.isEmpty) {
      throw Exception('Please enter an invite code.');
    }

    final houseQuery = await _firestore
        .collection('houses')
        .where('inviteCode', isEqualTo: inviteCode)
        .limit(1)
        .get();
    if (houseQuery.docs.isEmpty) {
      throw Exception('Invite code is invalid.');
    }

    final houseDoc = houseQuery.docs.first;
    final houseId = houseDoc.id;
    final membersCount = (houseDoc.data()['membersCount'] as num?)?.toInt() ?? 0;
    final memberLimit = (houseDoc.data()['memberLimit'] as num?)?.toInt() ?? 0;
    if (memberLimit > 0 && membersCount >= memberLimit) {
      throw Exception('This house reached its member limit.');
    }

    final memberRef = _firestore.collection('house_members').doc('${houseId}_${user.uid}');
    final exists = await memberRef.get();
    if (exists.exists) {
      return houseId;
    }

    final now = FieldValue.serverTimestamp();
    final batch = _firestore.batch();
    batch.set(memberRef, {
      'houseId': houseId,
      'userId': user.uid,
      'memberName': user.displayName ?? user.email ?? 'Member',
      'role': 'member',
      'joinedAt': now,
    });
    batch.update(_firestore.collection('houses').doc(houseId), {
      'membersCount': FieldValue.increment(1),
      'updatedAt': now,
    });
    batch.update(_firestore.collection('users').doc(user.uid), {
      'houseId': houseId,
      'role': 'member',
      'updatedAt': now,
    });
    await batch.commit();

    await NotificationService.instance.notifyHousemates(
      houseId: houseId,
      type: 'member',
      title: 'New roommate',
      body:
          '${user.displayName ?? user.email ?? 'Someone'} joined the house.',
      excludeUserId: user.uid,
    );

    return houseId;
  }

  Future<void> updateHouseAsOwner({
    required String houseId,
    String? name,
    List<String>? houseRules,
    bool? autoApproveExpense,
    bool? quietHoursNotify,
  }) async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      throw Exception('You need to be logged in.');
    }
    final houseSnap =
        await _firestore.collection('houses').doc(houseId).get();
    final data = houseSnap.data();
    if (data == null || data['ownerId'] != user.uid) {
      throw Exception('Only the house owner can update these settings.');
    }
    final update = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (name != null) {
      final n = name.trim();
      if (n.isEmpty) throw Exception('House name cannot be empty.');
      update['name'] = n;
    }
    if (houseRules != null) update['houseRules'] = houseRules;
    if (autoApproveExpense != null) {
      update['autoApproveExpense'] = autoApproveExpense;
    }
    if (quietHoursNotify != null) {
      update['quietHoursNotify'] = quietHoursNotify;
    }
    await _firestore.collection('houses').doc(houseId).update(update);
  }

  Future<void> leaveHouse() async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      throw Exception('You need to be logged in.');
    }
    final profile =
        await _firestore.collection('users').doc(user.uid).get();
    final houseId = profile.data()?['houseId'] as String?;
    if (houseId == null || houseId.isEmpty) {
      throw Exception('You are not in a house.');
    }
    final houseRef = _firestore.collection('houses').doc(houseId);
    final houseSnap = await houseRef.get();
    final houseData = houseSnap.data();
    if (houseData == null) {
      throw Exception('House not found.');
    }
    if (houseData['ownerId'] == user.uid) {
      throw Exception(
        'House owners cannot leave from here. Transfer ownership first.',
      );
    }
    final membersCount = (houseData['membersCount'] as num?)?.toInt() ?? 1;
    if (membersCount <= 1) {
      throw Exception('Cannot leave: invalid member count.');
    }

    final now = FieldValue.serverTimestamp();
    final batch = _firestore.batch();
    batch.delete(
      _firestore.collection('house_members').doc('${houseId}_${user.uid}'),
    );
    batch.update(houseRef, {
      'membersCount': FieldValue.increment(-1),
      'updatedAt': now,
    });
    batch.update(_firestore.collection('users').doc(user.uid), {
      'houseId': FieldValue.delete(),
      'role': FieldValue.delete(),
      'updatedAt': now,
    });
    await batch.commit();
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = Random.secure();
    String part() =>
        List.generate(4, (_) => chars[rnd.nextInt(chars.length)]).join();
    return 'DORM-${part()}-${part()}';
  }
}
