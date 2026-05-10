import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../debug_agent_log.dart';
import 'house_ai_context.dart';

/// Chat with Firebase AI Logic (Gemini) as the dorm “manager” assistant.
class ChatService {
  ChatService()
      : _app = Firebase.app(),
        _auth = FirebaseAuth.instance {
    // ignore: avoid_print
    print('AI ACTIVE MODEL: $modelName');
    // #region agent log
    agentDebugLog(
      hypothesisId: 'H1,H5',
      location: 'chat_service.dart:ChatService',
      message: 'ChatService constructed',
      data: {
        'modelNameConst': modelName,
        'identityHash': identityHashCode(this),
      },
    );
    // #endregion
  }

  final FirebaseApp _app;
  final FirebaseAuth _auth;

  /// Use a currently supported model.
  static const String modelName = 'gemini-2.5-flash-lite';
  static const String _fallbackModelName = 'gemini-2.5-flash-lite';

  static const String _outOfScopeReply =
      'أنا مدير السكن في Dorm Mate. بجاوب بس على أسئلة ليها علاقة بسكنك وبيانات التطبيق (مهام، مشتريات، مصاريف، أعضاء، قواعد…). السؤال ده خارج النطاق ده، فمش هقدر أساعدك.';

  static const String _greetingScopeReply =
      'أهلاً، أنا مدير السكن في Dorm Mate. كيف يمكنني مساعدتك؟';

  static const String _capabilityReply =
      'أنا مدير السكن في Dorm Mate. بقدر أوضح لك من بيانات سكنك في التطبيق: المهام، المشتريات، المصروفات، الأعضاء، القواعد، وعدد السكان—من Firestore فقط.';

  /// كلمات نواقص/مطبخ (بعد `_normAr`) — الأطول أولاً لتفادي مطابقات جزئية غلط.
  static const List<String> _pantryKeywordsNorm = [
    'نسكافيه',
    'مكرونه',
    'علبه',
    'جبنه',
    'قهوه',
    'قهوة',
    'مياه',
    'لبن',
    'شاي',
    'جبن',
    'بيض',
    'ارز',
    'سكر',
    'عصير',
    'فاكهه',
    'خضار',
    'زيت',
    'دقيق',
    'خبز',
    'مخلل',
    'بيبسي',
    'كولا',
  ];

  static String? _findPantryKeyword(String arNorm) {
    for (final tok in _pantryKeywordsNorm) {
      if (arNorm.contains(tok)) return tok;
    }
    return null;
  }

  static const String _systemPrompt = '''
أنت الآن Dormy AI Assistant. مهمتك إدارة سكن المستخدم المربوط تقنياً ببياناتك حالياً.

**ربط مسميات المنتج بحقول JSON** (انظر `_schema_hints` في اللقطة): houseTasks = المصفوفة `chores`، houseExpenses = المصفوفة `expenses`، houseRules = `house.houseRules`، المشتريات = `shopping_items`، الأعضاء = `house_members`.

1) **الهوية واللقب**
- المستخدم الذي يتحدث معك الآن هو المحدد في `ai_session.speaking_user`.
- خاطبه دائماً بـ `address_as` المذكور في البيانات. ممنوع نهائياً تسأله «اسمك إيه؟» أو «أنت مين؟».
- للتفاصيل الإضافية طابق `user_id` مع مصفوفة `users` وسجل عضويته في `house_members`.

2) **نطاق المعرفة (Dorm Scope)**
- **الأعضاء:** أنت تعرف كل زملائه من `house_members` (وملفات `users` المرفقة). تعامل معهم كأشخاص حقيقيين وليس مجرد أسماء جافة.
- **المشتريات والأكل:** أي سؤال عن لبن، بيض، جبنة، منظفات، شاي، نواقص، أو «في إيه أكل؟» مكانه `shopping_items` (راجع عناوين البنود والحقول المتاحة). لا تخمّن برّه القائمة.
- **الفلوس والمصاريف:** أنت المحاسب. راجع **houseExpenses** في JSON = المصفوفة `expenses` لتعرف مين دفع إيه ومين عليه فلوس حسب ما هو مسجل.
- **المهام والقواعد:** راجع **houseTasks** في JSON = المصفوفة `chores` للمهام اليومية، و **houseRules** في JSON = `house.houseRules` للقوانين.

3) **قواعد السلوك**
- ممنوع طلب «رقم السكن» أو «كود الدعوة/الدخول» أو اسم سكن للتعريف؛ السكن محدد تلقائياً بـ `ai_session.resolved_house_id`.
- لو سأل عن حاجة مش موجودة في الداتا (مثلاً: «مين اللي غسل المواعين؟» والمهام فاضية أو مفيش مطابقة)، قوله بوضوح إنها **مش مسجّلة في houseTasks** (`chores`) واعرض عليه يسجّلها في التطبيق.
- لو عنصر مش في `shopping_items`، قول إنه مش مسجّل في القائمة حالياً واقترح الإضافة من شاشة المشتريات.
- **عدد الأشخاص في السكن:** استخدم الرقم فقط من `_computed.answer_for_how_many_people_use_this_number_only` بدون تخمين.
- **اللهجة:** مصرية، «Startup Style»: ذكي، عملي، ومريح—من غير مبالغة.

4) **الأولوية**
- بيانات الـ Firestore الممرّرة لك في JSON (ضمن "### بيانات السكن") هي المصدر الوحيد والنهائي للحقيقة. لا تخمّن معلومات من خارج السكن ولا من الإنترنت.
- لا تكتب placeholders مثل «أدخل العدد هنا».
- لو وصلتك `dormy_messages` استخدمها كسياق إضافي فقط إن كانت الحقول واضحة؛ وإلا اعتمد على باقي اللقطة.
''';

  static String _normAr(String raw) {
    return raw
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .toLowerCase();
  }

  /// سؤال له علاقة بالسكن/التطبيق (قبل استدعاء Gemini).
  static bool _isDormScopeQuestion(String raw) {
    final s = raw.toLowerCase().trim();
    if (s.isEmpty) return false;
    final ar = _normAr(raw);

    const arKeys = [
      'سكن',
      'سكنا',
      'شقه',
      'شقة',
      'بيت',
      'غرفه',
      'غرفة',
      'طالب',
      'طلاب',
      'زميل',
      'زملاء',
      'ساكن',
      'سكان',
      'عضو',
      'اعضاء',
      'أعضاء',
      'مهمه',
      'مهمة',
      'مهام',
      'المهام',
      'واجب',
      'واجبات',
      'المشتريات',
      'تنظيف',
      'غسيل',
      'مطبخ',
      'حمام',
      'هدوء',
      'ضجيج',
      'ضيف',
      'ضيوف',
      'مصروف',
      'مصاريف',
      'ميزانيه',
      'ميزانية',
      'فلوس',
      'مبلغ',
      'دفع',
      'تقسيم',
      'قائمه',
      'قائمة',
      'مشتريات',
      'تسوق',
      'تسوّق',
      'دعوه',
      'دعوة',
      'كود',
      'انضمام',
      'قواعد',
      'خلاف',
      'مشكله',
      'مشكلة',
      'جدول',
      'اشعار',
      'إشعار',
      'اشعارات',
      'إشعارات',
      'عدد',
      'كام',
      'واحد',
      'شخص',
      'اشخاص',
      'أشخاص',
      'سكنات',
      'السكن',
      'دورم',
    ];
    const enKeys = [
      'dorm',
      'roommate',
      'roommates',
      'house',
      'apartment',
      'chore',
      'chores',
      'task',
      'tasks',
      'expense',
      'expenses',
      'budget',
      'shopping',
      'invite',
      'member',
      'members',
      'split',
      'bill',
      'wallet',
      'quiet',
      'noise',
      'kitchen',
      'bathroom',
      'campus',
      'dormmate',
      'dorm mate',
    ];

    for (final k in arKeys) {
      if (ar.contains(k)) return true;
    }
    for (final k in enKeys) {
      if (s.contains(k)) return true;
    }
    if (_findPantryKeyword(ar) != null) return true;
    // «كم» ككلمة منفصلة (تجنّب «كمبيوتر» ونحوها).
    for (final w in ar.split(RegExp(r'[^\u0600-\u06FFa-z0-9]+'))) {
      if (w == 'كم') return true;
    }
    return false;
  }

  static bool _isGreetingOnly(String raw) {
    final t = raw.trim().toLowerCase();
    if (t.isEmpty) return true;
    if (t.length > 48) return false;
    final cleaned = t.replaceAll(RegExp(r'[^\w\s\u0600-\u06FF]+'), ' ');
    final words =
        cleaned.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return true;
    const greetings = {
      'hi',
      'hello',
      'hey',
      'yo',
      'اهلا',
      'الو',
      'لو',
      'مرحبا',
      'مرحب',
      'سلام',
      'عليكم',
      'وعليكم',
      'ورحمه',
      'ورحمة',
      'وبركاته',
      'الله',
      'صباح',
      'مساء',
      'morning',
      'evening',
      'good',
      'thanks',
      'thank',
      'شكرا',
      'شكر',
    };
    var hit = 0;
    for (final w in words) {
      final hitG = greetings.any((g) => w == g || w.startsWith(g));
      if (hitG) {
        hit++;
      } else {
        return false;
      }
    }
    return hit > 0;
  }

  static bool _asksWhatYouCanDo(String raw) {
    final s = raw.toLowerCase();
    final ar = raw
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .toLowerCase();
    return s.contains('what can you') ||
        s.contains('what do you do') ||
        s.contains('help me') ||
        s.contains('help?') ||
        ar.contains('ايه اللي تقدر') ||
        ar.contains('ايش تقدر') ||
        ar.contains('بتقدر تعمل') ||
        ar.contains('بتعمل ايه') ||
        ar.contains('تقدر تساعد');
  }

  /// سؤال عن اسم المستخدم الحالي أو هويته (يمرّ من غير فلتر كلمات السكن).
  static bool _asksSpeakingUserIdentity(String raw) {
    final ar = _normAr(raw);
    final s = raw.toLowerCase();
    if (s.contains('my name') ||
        s.contains("what's my name") ||
        s.contains('what is my name') ||
        s.contains('who am i')) {
      return true;
    }
    if (ar.contains('اسمي')) return true;
    if (ar.contains('اسمى')) return true;
    if (ar.contains('ايه اسمي') ||
        ar.contains('اي اسمي') ||
        ar.contains('ايش اسمي') ||
        ar.contains('شو اسمي')) {
      return true;
    }
    if ((ar.contains('مين') || ar.contains('من')) && ar.contains('انا')) {
      return true;
    }
    return false;
  }

  static bool _hasWordKam(String arNorm) {
    for (final w in arNorm.split(RegExp(r'[^\u0600-\u06FFa-z0-9]+'))) {
      if (w == 'كم') return true;
    }
    return false;
  }

  /// سؤال عن عدد الأشخاص/الأعضاء في السكن (نرد من `_computed` بدون LLM).
  static bool _isMemberCountQuestion(String raw) {
    final ar = _normAr(raw);
    final s = raw.toLowerCase();

    if (s.contains('how many') &&
        (s.contains('people') ||
            s.contains('member') ||
            s.contains('person') ||
            s.contains('roommate'))) {
      return true;
    }
    if (s.contains('member count') || s.contains('number of members')) {
      return true;
    }

    if (ar.contains('عدد') &&
        (ar.contains('عضو') ||
            ar.contains('اعضاء') ||
            ar.contains('طالب') ||
            ar.contains('طلاب') ||
            ar.contains('شخص') ||
            ar.contains('اشخاص') ||
            ar.contains('ساكن') ||
            ar.contains('سكان') ||
            ar.contains('سكن'))) {
      return true;
    }
    final qty = ar.contains('كام') || _hasWordKam(ar);
    if (qty &&
        (ar.contains('واحد') ||
            ar.contains('شخص') ||
            ar.contains('اشخاص') ||
            ar.contains('طالب') ||
            ar.contains('طلاب') ||
            ar.contains('ساكن') ||
            ar.contains('عضو') ||
            ar.contains('في السكن') ||
            ar.contains('سكن'))) {
      return true;
    }
    if ((ar.contains('كام') || _hasWordKam(ar)) && ar.contains('سكن')) {
      return true;
    }
    return false;
  }

  static int? _tryMemberCountFromPayload(Map<String, dynamic>? map) {
    if (map == null || map['error'] != null) return null;
    final c = map['_computed'];
    if (c is! Map) return null;
    final n = c['answer_for_how_many_people_use_this_number_only'];
    if (n is int) return n;
    if (n is num) return n.toInt();
    return null;
  }

  static String? _resolvedHouseName(Map<String, dynamic>? map) {
    if (map == null) return null;
    final sess = map['ai_session'];
    if (sess is! Map) return null;
    final n = sess['resolved_house_name'];
    if (n is String && n.trim().isNotEmpty) return n.trim();
    return null;
  }

  /// الاسم المعروض للمستخدم المتحدث من لقطة السياق.
  static String? _speakingAddressFromPayload(Map<String, dynamic>? map) {
    if (map == null) return null;
    final sess = map['ai_session'];
    if (sess is! Map) return null;
    final su = sess['speaking_user'];
    if (su is! Map) return null;
    final a = su['address_as'];
    if (a is String && a.trim().isNotEmpty) return a.trim();
    final c = map['_computed'];
    if (c is Map) {
      final d = c['speaking_user_display_name'];
      if (d is String && d.trim().isNotEmpty) return d.trim();
    }
    return null;
  }

  static String _memberCountDeterministicReply(int n, String? houseName) {
    final suffix = houseName != null ? ' ($houseName)' : '';
    return 'من بيانات التطبيق المربوطة بحسابك على السيرفر، سكنك الحالي$suffix فيه $n عضو مسجّلين في house_members. مفيش حاجة تكتب اسم السكن أو رقمه—النظام عارف سكنك تلقائياً.';
  }

  static bool _isHouseRulesQuestion(String raw) {
    final ar = _normAr(raw);
    final s = raw.toLowerCase();
    if (s.contains('house rules') ||
        s.contains('apartment rules') ||
        s.contains('dorm rules')) {
      return true;
    }
    if (s.contains('rules') &&
        (s.contains('house') || s.contains('apartment') || s.contains('dorm'))) {
      return true;
    }
    if (!ar.contains('قواعد')) return false;
    return ar.contains('شقه') ||
        ar.contains('سكن') ||
        ar.contains('بيت') ||
        ar.contains('غرفه');
  }

  static String _houseRulesReplyFromPayload(Map<String, dynamic> map) {
    final h = map['house'];
    if (h is! Map) {
      return 'مفيش بيانات وثيقة السكن (house) في اللقطة الحالية.';
    }
    final rulesRaw = h['houseRules'];
    final rules = <String>[];
    if (rulesRaw is List) {
      for (final e in rulesRaw) {
        if (e is String && e.trim().isNotEmpty) {
          rules.add(e.trim());
        }
      }
    }
    final nameRaw = h['name'];
    final houseName =
        nameRaw is String && nameRaw.trim().isNotEmpty ? nameRaw.trim() : null;

    if (rules.isEmpty) {
      return 'مفيش قواعد مسجّلة للشقة في التطبيق حالياً (قائمة houseRules فاضية). المالك يقدر يضيفها من إعدادات السكن.';
    }

    final buf = StringBuffer();
    if (houseName != null) {
      buf.writeln('قواعد «$houseName» من بيانات التطبيق:');
    } else {
      buf.writeln('قواعد الشقة من بيانات التطبيق:');
    }
    for (var i = 0; i < rules.length; i++) {
      buf.writeln('${i + 1}. ${rules[i]}');
    }
    return buf.toString().trim();
  }

  static List<Map<String, dynamic>> _coerceMapList(dynamic v) {
    if (v is! List) return [];
    final out = <Map<String, dynamic>>[];
    for (final e in v) {
      if (e is Map<String, dynamic>) {
        out.add(e);
      } else if (e is Map) {
        out.add(
          Map<String, dynamic>.from(
            e.map((k, val) => MapEntry(k.toString(), val)),
          ),
        );
      }
    }
    return out;
  }

  static bool _isChoresListQuestion(String raw) {
    final ar = _normAr(raw);
    final s = raw.toLowerCase();
    if (s.contains('chore') || s.contains('chores')) return true;
    if (s.contains('task') || s.contains('tasks')) return true;
    return ar.contains('مهام') ||
        ar.contains('واجب') ||
        ar.contains('واجبات');
  }

  static bool _isShoppingQuestion(String raw) {
    final ar = _normAr(raw);
    final s = raw.toLowerCase();
    if (s.contains('shopping') ||
        s.contains('grocery') ||
        s.contains('groceries') ||
        s.contains('buy list')) {
      return true;
    }
    if (ar.contains('مشتريات')) return true;
    if (ar.contains('قائمه التسوق') || ar.contains('قائمة التسوق')) {
      return true;
    }
    if ((ar.contains('قائمه') || ar.contains('قائمة')) &&
        ar.contains('تسوق')) {
      return true;
    }
    if (ar.contains('تسوق') &&
        (ar.contains('ايه') ||
            ar.contains('اي') ||
            ar.contains('ايش') ||
            ar.contains('شو') ||
            ar.contains('كام') ||
            ar.contains('فيه') ||
            ar.contains('عندنا') ||
            ar.contains('عندكم'))) {
      return true;
    }
    if ((ar.contains('كام') || _hasWordKam(ar)) &&
        (ar.contains('علبه') ||
            ar.contains('لبن') ||
            ar.contains('جبن') ||
            ar.contains('مياه'))) {
      return true;
    }
    if ((ar.contains('لستة') || ar.contains('لسته')) &&
        (ar.contains('مشتريات') ||
            ar.contains('تسوق') ||
            ar.contains('سوق'))) {
      return true;
    }
    if (_findPantryKeyword(ar) != null) return true;
    return false;
  }

  static String _statusAr(String? status) {
    switch (status) {
      case 'completed':
        return 'مكتملة';
      case 'pending':
        return 'معلّقة';
      default:
        return status ?? '—';
    }
  }

  static String _choresReplyFromPayload(Map<String, dynamic> map) {
    final rows = _coerceMapList(map['chores']);
    if (rows.isEmpty) {
      return 'مفيش مهام مسجّلة في التطبيق للسكن ده حالياً (مجموعة chores فاضية في اللقطة).';
    }
    final buf = StringBuffer('المهام من بيانات التطبيق (chores):\n');
    for (var i = 0; i < rows.length; i++) {
      final c = rows[i];
      final title = (c['title'] ?? 'بدون عنوان').toString();
      final st = _statusAr(c['status']?.toString());
      final due = c['dueAt']?.toString();
      var line = '${i + 1}. $title — الحالة: $st';
      if (due != null && due.isNotEmpty) {
        line += ' — الاستحقاق: $due';
      }
      if (c['isHighPriority'] == true) {
        line += ' — أولوية عالية';
      }
      buf.writeln(line);
    }
    return buf.toString().trim();
  }

  static String _shoppingReplyFromPayload(Map<String, dynamic> map, String q) {
    final ar = _normAr(q);
    final rows = _coerceMapList(map['shopping_items']);
    final pantryKw = _findPantryKeyword(ar);
    final wantsItemPing = pantryKw != null &&
        (ar.contains('كام') ||
            _hasWordKam(ar) ||
            ar.contains('في') ||
            ar.contains('فيه') ||
            ar.contains('عندنا') ||
            ar.contains('عندكم') ||
            ar.contains('طب') ||
            ar.contains('طيب') ||
            ar.contains('؟') ||
            ar.contains('?') ||
            q.trim().length <= 28);

    if (pantryKw != null && wantsItemPing) {
      if (rows.isEmpty) {
        return 'في التطبيق لسه مفيش حاجة مسجّلة في قائمة المشتريات (shopping_items فاضية). «$pantryKw» مش ظاهر—لما تضيفوا من شاشة المشتريات هيبان هنا.';
      }
      var n = 0;
      for (final it in rows) {
        final t = _normAr((it['title'] ?? '').toString());
        if (t.contains(pantryKw)) n++;
      }
      if (n == 0) {
        return 'دلوقتي «$pantryKw» مش متسجّل في اسم أي بند في قائمة المشتريات (shopping_items). لو محتاجينه—ضيفوه من شاشة المشتريات في Dorm Mate وهيظهر في اللقطة الجاية.';
      }
      return 'من قائمة المشتريات في التطبيق، عدد البنود اللي في اسمها «$pantryKw»: $n.';
    }

    if (rows.isEmpty) {
      return 'مفيش عناصر في قائمة المشتريات مسجّلة حالياً (shopping_items فاضية).';
    }

    final buf = StringBuffer('قائمة المشتريات من بيانات التطبيق (shopping_items):\n');
    var j = 0;
    for (final it in rows) {
      final title = (it['title'] ?? '').toString();
      if (title.isEmpty) continue;
      j++;
      final price = it['estimatedPrice'];
      final checked = it['isChecked'] == true;
      var line = '$j. $title';
      if (price is num && price > 0) {
        line += ' — تقدير السعر: $price';
      }
      if (checked) line += ' (متعلّم كمُنجز)';
      buf.writeln(line);
    }
    return buf.toString().trim();
  }

  static String _userFacingAiError(Object e) {
    final lower = e.toString().toLowerCase();
    if (lower.contains('429') ||
        lower.contains('quota') ||
        lower.contains('rate limit') ||
        lower.contains('resource exhausted')) {
      return 'خدمة الذكاء الاصطناعي مشغولة أو وصلت لحد الطلبات. جرّب تاني بعد شوية.';
    }
    if (lower.contains('403') ||
        lower.contains('permission') ||
        lower.contains('denied') ||
        lower.contains('forbidden')) {
      return 'صلاحية الاتصال بخدمة الذكاء الاصطناعي مرفوضة. تأكد من تمكين Firebase AI في المشروع ومفتاح الـ API.';
    }
    if (lower.contains('network') ||
        lower.contains('socket') ||
        lower.contains('host lookup') ||
        lower.contains('connection') ||
        lower.contains('timed out')) {
      return 'مشكلة في الشبكة أثناء الاتصال بخدمة الذكاء الاصطناعي. تحقق من الإنترنت وحاول مرة تانية.';
    }
    return 'تعذر الاتصال بخدمة الذكاء الاصطناعي حالياً. راجع رسالة الخطأ في الـ console (تشغيل التطبيق من IDE) أو جرّب تاني بعد قليل.';
  }

  late GenerativeModel _generativeModel = _createModel(modelName);

  GenerativeModel _createModel(String model) {
    final ai = FirebaseAI.googleAI(app: _app, auth: _auth);
    final gm = ai.generativeModel(
      model: model,
      systemInstruction: Content.system(_systemPrompt.trim()),
    );
    // #region agent log
    final resolved = gm.model;
    agentDebugLog(
      hypothesisId: 'H2,H4',
      location: 'chat_service.dart:_createModel',
      message: 'generativeModel created',
      data: {
        'requestedModel': model,
        'resolvedName': resolved.name,
        'resolvedPrefix': resolved.prefix,
      },
    );
    // #endregion
    return gm;
  }

  /// Send a user message; each call reloads house data from Firestore and answers only from that snapshot.
  Future<String> sendMessage(String text) async {
    final q = text.trim();
    if (q.isEmpty) {
      return _outOfScopeReply;
    }
    if (_asksWhatYouCanDo(q)) {
      return _capabilityReply;
    }
    if (_isGreetingOnly(q)) {
      return _greetingScopeReply;
    }
    final identityQ = _asksSpeakingUserIdentity(q);
    if (!identityQ && !_isDormScopeQuestion(q)) {
      return _outOfScopeReply;
    }

    // #region agent log
    try {
      final m = _generativeModel.model;
      agentDebugLog(
        hypothesisId: 'H3',
        location: 'chat_service.dart:sendMessage:before',
        message: 'before sendMessage',
        data: {
          'modelName': m.name,
          'prefix': m.prefix,
        },
      );
    } catch (e) {
      agentDebugLog(
        hypothesisId: 'H2',
        location: 'chat_service.dart:sendMessage:modelInspect',
        message: 'failed to read model',
        data: {'error': e.toString()},
      );
    }
    // #endregion

    final houseJson = await HouseAiContextService.fetchHouseContextJson();

    Map<String, dynamic>? payload;
    try {
      if (!houseJson.contains('[truncated')) {
        final decoded = jsonDecode(houseJson);
        if (decoded is Map<String, dynamic>) payload = decoded;
      }
    } catch (_) {}

    if (payload != null && payload['error'] != null) {
      final err = payload['error'];
      if (err == 'not_signed_in') {
        return 'محتاج تسجيل الدخول عشان أجيب بيانات سكنك من السيرفر.';
      }
      return 'مش قادر أجيب بيانات السكن حالياً: $err';
    }

    if (identityQ) {
      final name = _speakingAddressFromPayload(payload);
      if (name != null && name != 'الطالب') {
        return 'يا $name، الاسم اللي ظاهر عندي ليك من بيانات التطبيق و Firestore هو ده. لو مش مظبوط، حدّث الاسم من إعدادات البروفايل في Dorm Mate.';
      }
      if (name == 'الطالب') {
        return 'مش لاقي اسم واضح متسجّل ليك (ظاهر عندي كـ«الطالب»). اعمل تحديث للـ fullName في حسابك أو memberName في السكن من التطبيق.';
      }
      return 'مش قادر أطلع اسمك من اللقطة الحالية؛ تأكد إنك مسجّل دخول ومتضمّن في house_members وإن ملف users فيه fullName أو إن عندك displayName في الحساب.';
    }

    final memberCount = _tryMemberCountFromPayload(payload);
    if (memberCount != null && _isMemberCountQuestion(q)) {
      return _memberCountDeterministicReply(
        memberCount,
        _resolvedHouseName(payload),
      );
    }

    if (payload != null && _isHouseRulesQuestion(q)) {
      return _houseRulesReplyFromPayload(payload);
    }

    if (payload != null) {
      final choresQ = _isChoresListQuestion(q);
      final shopQ = _isShoppingQuestion(q);
      if (choresQ && shopQ) {
        return '${_choresReplyFromPayload(payload)}\n\n${_shoppingReplyFromPayload(payload, q)}';
      }
      if (choresQ) {
        return _choresReplyFromPayload(payload);
      }
      if (shopQ) {
        return _shoppingReplyFromPayload(payload, q);
      }
    }

    final prompt =
        '### بيانات السكن (من Firestore، JSON)\n$houseJson\n\n### سؤال المستخدم (لسكنه المربوط فقط — انظر ai_session؛ لا تطلب منه اسم السكن أو رقم السكن)\n$text';

    try {
      final response = await _generativeModel.generateContent([
        Content.text(prompt),
      ]);
      final out = response.text;
      if (out == null || out.isEmpty) {
        return 'تعذر إرجاع رد واضح. جرّب إعادة الصياغة أو تحقق من الاتصال وإعدادات Firebase AI في المشروع.';
      }
      return out;
    } on FirebaseAIException catch (e) {
      // #region agent log
      agentDebugLog(
        hypothesisId: 'H4',
        location: 'chat_service.dart:sendMessage:FirebaseAIException',
        message: 'caught FirebaseAIException',
        data: {
          'message': e.message,
          'type': '${e.runtimeType}',
        },
      );
      // #endregion
      final lower = '${e.message} ${e.toString()}'.toLowerCase();
      final shouldFallback =
          lower.contains('404') ||
          lower.contains('not found') ||
          lower.contains('retired') ||
          lower.contains('discontinued') ||
          lower.contains('model') && lower.contains('available');
      if (shouldFallback) {
        // ignore: avoid_print
        print(
            'AI model fallback: switching from $modelName to $_fallbackModelName');
        _generativeModel = _createModel(_fallbackModelName);
        final retry = await _generativeModel.generateContent([
          Content.text(prompt),
        ]);
        final retryText = retry.text;
        if (retryText != null && retryText.isNotEmpty) {
          return retryText;
        }
      }
      // Required for debugging issues like CORS/API key.
      // ignore: avoid_print
      print('AI ERROR MESSAGE: ${e.message}');
      // ignore: avoid_print
      print('AI ERROR TYPE: ${e.runtimeType}');
      // ignore: avoid_print
      print('FULL ERROR: ${e.toString()}');
      return _userFacingAiError(e);
    } catch (e) {
      // ignore: avoid_print
      print('FULL ERROR: ${e.toString()}');
      return _userFacingAiError(e);
    }
  }

  void resetChat() {
    _generativeModel = _createModel(modelName);
    // #region agent log
    agentDebugLog(
      hypothesisId: 'H6',
      location: 'chat_service.dart:resetChat',
      message: 'resetChat recreated model',
      data: {'modelNameConst': modelName},
    );
    // #endregion
  }
}
