import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth_service.dart';
import 'notification_service.dart';

class ExpenseService {
  ExpenseService._();

  static final ExpenseService instance = ExpenseService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchExpenses(String houseId) {
    return _firestore
        .collection('expenses')
        .where('houseId', isEqualTo: houseId)
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchExpenseById(String expenseId) {
    return _firestore.collection('expenses').doc(expenseId).snapshots();
  }

  Future<String> createExpense({
    required String houseId,
    required double amount,
    required String description,
  }) async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      throw Exception('You need to be logged in.');
    }

    final membersQuery = await _firestore
        .collection('house_members')
        .where('houseId', isEqualTo: houseId)
        .get();
    final memberIds = membersQuery.docs
        .map((doc) => (doc.data()['userId'] as String?) ?? '')
        .where((id) => id.isNotEmpty)
        .toList();
    if (memberIds.isEmpty) {
      throw Exception('No house members found.');
    }

    final share = amount / memberIds.length;
    final shares = <String, double>{
      for (final id in memberIds) id: share,
    };

    final doc = await _firestore.collection('expenses').add({
      'houseId': houseId,
      'amount': amount,
      'description': description,
      'paidBy': user.uid,
      'paidByName': user.displayName ?? user.email ?? 'Unknown',
      'participantUserIds': memberIds,
      'shares': shares,
      'settledByUserIds': <String>[user.uid],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await NotificationService.instance.notifyHousemates(
      houseId: houseId,
      type: 'expense',
      title: 'New expense',
      body:
          '${user.displayName ?? user.email ?? 'Someone'} added "$description" '
          '(\$${amount.toStringAsFixed(2)}).',
      excludeUserId: user.uid,
    );

    return doc.id;
  }

  Future<void> markMyShareSettled(String expenseId) async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      throw Exception('You need to be logged in.');
    }
    final ref = _firestore.collection('expenses').doc(expenseId);
    await ref.update({
      'settledByUserIds': FieldValue.arrayUnion([user.uid]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// How much [userId] owes on this expense (share), using `shares` when present,
  /// otherwise an equal split among `participantUserIds` (or inferred from `shares` keys).
  double shareAmountForUser(Map<String, dynamic> expense, String userId) {
    final shares = _parseSharesMap(expense['shares']);
    if (shares.containsKey(userId)) {
      return shares[userId]!;
    }
    final participantIds = _participantUserIds(expense, shares.keys);
    if (!participantIds.contains(userId)) return 0;
    final total = (expense['amount'] as num?)?.toDouble();
    if (total == null || total <= 0 || participantIds.isEmpty) {
      return 0;
    }
    return total / participantIds.length;
  }

  /// Resolves a user id from Firestore (String, DocumentReference, etc.).
  /// Critical for matching [paidBy] to Auth uid so "You are owed" updates when you pay.
  static String? payerUserId(dynamic raw) {
    return firestoreUserId(raw);
  }

  static String? firestoreUserId(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) {
      final s = raw.trim();
      return s.isEmpty ? null : s;
    }
    if (raw is DocumentReference) {
      return raw.id;
    }
    final s = '$raw'.trim();
    return s.isEmpty ? null : s;
  }

  ({double owe, double owed, int oweToPeople, int owedFromPeople})
      summarizeOutstandingForUser({
    required String userId,
    required Iterable<Map<String, dynamic>> expenses,
  }) {
    double owe = 0;
    double owed = 0;
    final oweToUsers = <String>{};
    final owedFromUsers = <String>{};

    for (final data in expenses) {
      final paidBy = payerUserId(data['paidBy']);
      final settled =
          Set<String>.from(_parseUserIdList(data['settledByUserIds']).where((id) => id.isNotEmpty));

      if (paidBy != null && paidBy == userId) {
        final sharesKeys = _parseSharesMap(data['shares']).keys;
        final participants = _participantUserIds(data, sharesKeys);
        for (final otherId in participants) {
          if (otherId.isEmpty || otherId == userId) continue;
          if (settled.contains(otherId)) continue;
          final portion = shareAmountForUser(data, otherId);
          if (portion <= 0) continue;
          owed += portion;
          owedFromUsers.add(otherId);
        }
      } else {
        if (settled.contains(userId)) continue;
        final myShare = shareAmountForUser(data, userId);
        if (myShare <= 0) continue;
        owe += myShare;
        final creditor = payerUserId(data['paidBy']);
        if (creditor != null && creditor.isNotEmpty && creditor != userId) {
          oweToUsers.add(creditor);
        }
      }
    }

    return (
      owe: owe,
      owed: owed,
      oweToPeople: oweToUsers.length,
      owedFromPeople: owedFromUsers.length,
    );
  }

  Set<String> settledUserIds(Map<String, dynamic> expense) {
    return Set<String>.from(
        _parseUserIdList(expense['settledByUserIds']).where((id) => id.isNotEmpty));
  }

  static Map<String, double> _parseSharesMap(dynamic raw) {
    if (raw == null || raw is! Map) return {};
    final map = Map<Object?, Object?>.from(raw);
    final out = <String, double>{};
    for (final MapEntry<Object?, Object?> e in map.entries) {
      final id = firestoreUserId(e.key);
      if (id == null || id.isEmpty) continue;
      final value = e.value;
      if (value == null) continue;
      final n =
          value is num ? value.toDouble() : double.tryParse('$value'.trim());
      if (n == null) continue;
      out[id] = n;
    }
    return out;
  }

  static List<String> _parseUserIdList(dynamic raw) {
    if (raw == null || raw is! Iterable) {
      return const [];
    }
    final out = <String>{};
    for (final e in raw) {
      final id = firestoreUserId(e);
      if (id != null && id.isNotEmpty) out.add(id);
    }
    return out.toList();
  }

  static List<String> _participantUserIds(
    Map<String, dynamic> expense,
    Iterable<String> inferredFromShares,
  ) {
    final ids = Set<String>.from(_parseUserIdList(expense['participantUserIds']));
    ids.addAll(inferredFromShares);
    ids.removeWhere((id) => id.isEmpty);

    final payer = payerUserId(expense['paidBy']);
    if (payer != null && payer.isNotEmpty) {
      ids.add(payer);
    }

    if (ids.isNotEmpty) return ids.toList();

    final onlyPayer = payerUserId(expense['paidBy']);
    return onlyPayer == null || onlyPayer.isEmpty ? [] : [onlyPayer];
  }

  /// Sums total expense [amount] per calendar day for the **current ISO week**
  /// (Monday index 0 … Sunday index 6). Uses [createdAt] when present.
  static List<double> weeklyHouseSpendingTotals(
    Iterable<Map<String, dynamic>> expenses,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: today.weekday - DateTime.monday));
    final totals = List<double>.filled(7, 0);

    for (final e in expenses) {
      final raw = e['createdAt'];
      DateTime? d;
      if (raw is Timestamp) d = raw.toDate();
      if (d == null) continue;
      final day = DateTime(d.year, d.month, d.day);
      if (day.isBefore(monday)) continue;
      final idx = day.difference(monday).inDays;
      if (idx < 0 || idx > 6) continue;
      final amt = (e['amount'] as num?)?.toDouble() ?? 0;
      if (amt > 0) totals[idx] += amt;
    }
    return totals;
  }

  /// Total expense amount recorded in the **current calendar month** (house-wide).
  static double monthToDateHouseTotal(Iterable<Map<String, dynamic>> expenses) {
    final now = DateTime.now();
    var s = 0.0;
    for (final e in expenses) {
      final raw = e['createdAt'];
      DateTime? d;
      if (raw is Timestamp) d = raw.toDate();
      if (d == null) continue;
      if (d.year != now.year || d.month != now.month) continue;
      final amt = (e['amount'] as num?)?.toDouble() ?? 0;
      if (amt > 0) s += amt;
    }
    return s;
  }

  /// Last **7 days** (ending today): totals per day + short weekday labels.
  static ({List<double> totals, List<String> labels}) lastSevenDaysSpending(
    Iterable<Map<String, dynamic>> expenses,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(const Duration(days: 6));
    final totals = List<double>.filled(7, 0);
    const short = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    for (final e in expenses) {
      final raw = e['createdAt'];
      DateTime? d;
      if (raw is Timestamp) d = raw.toDate();
      if (d == null) continue;
      final day = DateTime(d.year, d.month, d.day);
      if (day.isBefore(start) || day.isAfter(today)) continue;
      final idx = day.difference(start).inDays;
      if (idx < 0 || idx > 6) continue;
      final amt = (e['amount'] as num?)?.toDouble() ?? 0;
      if (amt > 0) totals[idx] += amt;
    }

    final labels = List.generate(7, (i) {
      final dt = start.add(Duration(days: i));
      return short[dt.weekday - 1];
    });
    return (totals: totals, labels: labels);
  }
}
