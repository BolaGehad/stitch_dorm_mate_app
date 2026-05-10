import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service.dart';
import 'house_service.dart';

/// Builds a compact, JSON-safe snapshot of the signed-in user's house for AI grounding.
class HouseAiContextService {
  HouseAiContextService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static dynamic _jsonSafe(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate().toUtc().toIso8601String();
    if (v is Map) {
      return v.map((k, val) => MapEntry(k.toString(), _jsonSafe(val)));
    }
    if (v is Iterable) {
      return v.map(_jsonSafe).toList();
    }
    return v;
  }

  static Map<String, dynamic>? _docMap(DocumentSnapshot<Map<String, dynamic>> d) {
    final data = d.data();
    if (data == null) return null;
    return Map<String, dynamic>.from(
      data.map((k, v) => MapEntry(k, _jsonSafe(v))),
    );
  }

  /// اسم يظهر للـ AI: Firestore `fullName` ثم Auth ثم `memberName` ثم جزء من الإيميل.
  static String _resolveSpeakingDisplayName({
    required User user,
    Map<String, dynamic>? firestoreUser,
    Map<String, dynamic>? memberRow,
  }) {
    final fromFs = firestoreUser?['fullName'];
    if (fromFs is String && fromFs.trim().isNotEmpty) {
      return fromFs.trim();
    }
    final dn = user.displayName;
    if (dn != null && dn.trim().isNotEmpty) {
      return dn.trim();
    }
    final mn = memberRow?['memberName'];
    if (mn is String && mn.trim().isNotEmpty) {
      return mn.trim();
    }
    final em = user.email ?? (firestoreUser?['email'] as String?);
    if (em != null && em.trim().isNotEmpty) {
      return em.split('@').first.trim();
    }
    return 'الطالب';
  }

  /// Returns a JSON string (possibly truncated) for injection into the model prompt.
  static Future<String> fetchHouseContextJson({int maxChars = 16000}) async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      return jsonEncode({'error': 'not_signed_in'});
    }
    try {
      final houseId = await HouseService.instance.getCurrentUserHouseId();

      final houseSnap = await _db.collection('houses').doc(houseId).get();
      final membersSnap = await _db
          .collection('house_members')
          .where('houseId', isEqualTo: houseId)
          .limit(40)
          .get();
      final choresSnap = await _db
          .collection('chores')
          .where('houseId', isEqualTo: houseId)
          .limit(35)
          .get();
      final shoppingSnap = await _db
          .collection('shopping_items')
          .where('houseId', isEqualTo: houseId)
          .limit(35)
          .get();
      final expensesSnap = await _db
          .collection('expenses')
          .where('houseId', isEqualTo: houseId)
          .limit(25)
          .get();

      final houseMap = _docMap(houseSnap);
      final memberRows = membersSnap.docs
          .map((d) => {'id': d.id, ...(_docMap(d) ?? {})})
          .toList();

      final memberUserIds = <String>{user.uid};
      for (final d in membersSnap.docs) {
        final uid = d.data()['userId'] as String?;
        if (uid != null && uid.isNotEmpty) {
          memberUserIds.add(uid);
        }
      }
      final userSnaps = await Future.wait(
        memberUserIds.map((id) => _db.collection('users').doc(id).get()),
      );
      final userRows = <Map<String, dynamic>>[];
      for (final s in userSnaps) {
        if (s.exists) {
          userRows.add({'id': s.id, ...(_docMap(s) ?? {})});
        }
      }

      final dormyRows = <Map<String, dynamic>>[];
      final dormySeen = <String>{};
      void mergeDormy(QuerySnapshot<Map<String, dynamic>> snap) {
        for (final d in snap.docs) {
          if (dormySeen.add(d.id)) {
            dormyRows.add({'id': d.id, ...(_docMap(d) ?? {})});
          }
        }
      }

      try {
        final snap = await _db
            .collection('dormy_messages')
            .where('houseId', isEqualTo: houseId)
            .limit(30)
            .get();
        mergeDormy(snap);
      } catch (_) {}
      try {
        final snap = await _db
            .collection('dormy_messages')
            .where('userId', isEqualTo: user.uid)
            .limit(30)
            .get();
        mergeDormy(snap);
      } catch (_) {}

      Map<String, dynamic>? currentUserFirestore;
      for (final row in userRows) {
        if (row['id'] == user.uid) {
          currentUserFirestore = row;
          break;
        }
      }
      Map<String, dynamic>? currentMemberRow;
      for (final row in memberRows) {
        if (row['userId'] == user.uid) {
          currentMemberRow = row;
          break;
        }
      }
      final addressAs = _resolveSpeakingDisplayName(
        user: user,
        firestoreUser: currentUserFirestore,
        memberRow: currentMemberRow,
      );
      final speakingUser = <String, dynamic>{
        'user_id': user.uid,
        'address_as': addressAs,
        'email':
            (currentUserFirestore?['email'] as String?) ?? user.email ?? '',
        if (currentMemberRow != null && currentMemberRow['role'] != null)
          'house_role': currentMemberRow['role'],
        if (currentMemberRow != null && currentMemberRow['memberName'] != null)
          'member_name_on_house_member_doc': currentMemberRow['memberName'],
        if (currentMemberRow != null && currentMemberRow['id'] != null)
          'house_member_document_id': currentMemberRow['id'],
        'instruction_ar':
            'المستخدم اللي بيكتب في الشات دلوقتي هو نفسه user_id أعلاه؛ اسمه الظاهر للرد عليه: address_as. خاطبه بالاسم لما يناسب، وما تسألوش «مين أنت» أو «اسمك إيه».',
      };

      final memberDocCount = memberRows.length;
      final membersCountField = houseMap?['membersCount'];
      int? membersCountAsInt;
      final mcf = membersCountField;
      if (mcf is int) {
        membersCountAsInt = mcf;
      } else if (mcf is num) {
        membersCountAsInt = mcf.toInt();
      }
      final inviteCode = houseMap?['inviteCode'] as String?;
      final houseDisplayName = houseMap?['name'] as String?;

      final payload = <String, dynamic>{
        // يُقرأ أولاً: السكن هنا = نفس السكن المربوط بالمستخدم في الـ backend (users.houseId).
        'ai_session': {
          'backend_resolved': true,
          'source': 'Firestore',
          'signed_in_user_id': user.uid,
          'resolved_house_id': houseId,
          'resolved_house_name': houseDisplayName,
          'speaking_user': speakingUser,
          'instruction_ar':
              'لا تطلب من المستخدم اسم السكن أو رقم السكن أو أي معرف إضافي. اللقطة دي للسكن المربوط بحسابه فقط (users.houseId = resolved_house_id). أي سؤال عن «السكن» أو «سكني» يقصد هذا السكن دائماً. اعرف المستخدم المتحدث من speaking_user (الاسم في address_as) ومن مصفوفة users وhouse_members.',
        },
        '_schema_hints': {
          'houseTasks': 'المهام في المصفوفة JSON اسمها chores',
          'shopping_items': 'نفس المفتاح shopping_items',
          'houseExpenses': 'المصروفات في المصفوفة expenses',
          'resolved_house_members': 'الأعضاء في المصفوفة house_members',
          'houseRules': 'مصفوفة النصوص داخل house.houseRules',
          'users': 'ملفات users لكل userId ظاهر في house_members + المستخدم الحالي',
          'dormy_messages':
              'رسائل/سجل مرتبط بالسكن (houseId) أو بالمستخدم (userId) حسب ما يتوفر في الوثائق',
          'speaking_user':
              'داخل ai_session: الطالب اللي بيتكلم دلوقتي (address_as + user_id + دوره في السكن إن وُجد)',
        },
        'houseId': houseId,
        'currentUserId': user.uid,
        'house': houseMap,
        'house_members': memberRows,
        'chores': choresSnap.docs
            .map((d) => {'id': d.id, ...(_docMap(d) ?? {})})
            .toList(),
        'shopping_items': shoppingSnap.docs
            .map((d) => {'id': d.id, ...(_docMap(d) ?? {})})
            .toList(),
        'expenses': expensesSnap.docs
            .map((d) => {'id': d.id, ...(_docMap(d) ?? {})})
            .toList(),
        'users': userRows,
        'dormy_messages': dormyRows,
        '_computed': {
          'scope':
              'هذه اللقطة للسكن المرتبط بحساب المستخدم فقط (houseId و ai_session.resolved_house_id).',
          'speaking_user_display_name': addressAs,
          'invite_code_on_house_doc': inviteCode,
          'house_members_document_count': memberDocCount,
          'house_doc_membersCount_field': membersCountField,
          'answer_for_how_many_people_use_this_number_only': memberDocCount,
          if (membersCountAsInt != null && membersCountAsInt != memberDocCount)
            'warning':
                'حقل membersCount في وثيقة house لا يساوي عدد وثائق house_members؛ اعتمد house_members_document_count كمصدر للعدد الحالي للأسماء المدرجة.',
        },
      };

      var encoded = const JsonEncoder.withIndent('  ').convert(payload);
      if (encoded.length > maxChars) {
        encoded =
            '${encoded.substring(0, maxChars)}\n... [truncated at $maxChars chars]';
      }
      return encoded;
    } catch (e) {
      return jsonEncode({'error': e.toString()});
    }
  }
}
