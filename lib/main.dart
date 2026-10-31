import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hacktoberfest/tutor_service.dart';

void main() => runApp(const SabiApp());

const forest = Color(0xFF0F6B4F);
const forestDark = Color(0xFF07543D);
const yellow = Color(0xFFF9B233);
const terra = Color(0xFFD9683B);
const paper = Color(0xFFFFF9F0);
const ink = Color(0xFF1F2937);
const muted = Color(0xFF667085);
const paleGreen = Color(0xFFE7F3EC);
const line = Color(0xFFECE5DB);

enum SabiScreen {
  splash,
  onboarding,
  auth,
  consent,
  levelIntro,
  test,
  testResult,
  home,
  chapter,
  lesson,
  exercise,
  correction,
  mastered,
  tutor,
  progress,
  badges,
  history,
  offline,
  profile,
  settings,
  privacy,
  help,
  notifications,
  teacherLogin,
  classSetup,
  dashboard,
  skills,
  students,
  studentDetail,
  remediation,
  reports,
  content,
  contentDetail,
  flowMap,
}

class SabiApp extends StatelessWidget {
  const SabiApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Sabi — Comprendre, à ton rythme',
    debugShowCheckedModeBanner: false,
    locale: const Locale('fr'),
    supportedLocales: const [Locale('fr')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: paper,
      colorScheme: ColorScheme.fromSeed(
        seedColor: forest,
        primary: forest,
        secondary: yellow,
        surface: paper,
        error: terra,
      ),
      fontFamily: 'Nunito',
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: ink, fontSize: 16, height: 1.5),
        bodyMedium: TextStyle(color: ink, fontSize: 14, height: 1.45),
        titleLarge: TextStyle(
          color: ink,
          fontSize: 23,
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
        titleMedium: TextStyle(
          color: ink,
          fontSize: 17,
          fontWeight: FontWeight.w800,
          height: 1.3,
        ),
        labelLarge: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
    ),
    home: const SabiPrototype(),
  );
}

class SabiPrototype extends StatefulWidget {
  const SabiPrototype({super.key});

  @override
  State<SabiPrototype> createState() => _SabiPrototypeState();
}

typedef TutorAnswer = ({
  String title,
  String explanation,
  String example,
  String reason,
  List<String> steps,
  String hint,
});

class _SabiPrototypeState extends State<SabiPrototype> {
  SabiScreen _screen = SabiScreen.splash;
  final List<SabiScreen> _history = [];
  final TextEditingController _answerController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _tutorInputController = TextEditingController();
  final TutorService _tutorService = TutorService();
  Timer? _splashTimer;
  bool _hasSized = false;
  bool _isOnline = false;
  bool _isSignup = true;
  bool _consentGiven = true;
  bool _cloudTutorConsentGiven = false;
  bool _isAskingTutor = false;
  bool _isCorrect = false;
  bool _showHint = false;
  bool _showSolution = false;
  bool _largeText = false;
  bool _audioEnabled = true;
  bool _audioPlaying = false;
  bool _dataSaver = false;
  bool _lowStorage = false;
  bool _studentAdded = false;
  String _searchQuery = '';
  String? _tutorStatus;
  String _tutorQuestion = 'Je ne comprends pas la factorisation.';
  TutorAnswer _tutorAnswer = (
    title: 'On reprend tout doucement 💛',
    explanation:
        'Factoriser, c’est l’inverse de développer. On transforme une addition ou une soustraction en multiplication.',
    example: '6x + 12 = 6(x + 2)',
    reason: 'Pourquoi ? Car 6 se retrouve dans les deux morceaux.',
    steps: [
      'Repère ce qui se répète.',
      'Mets-le devant les parenthèses.',
      'Vérifie en développant.',
    ],
    hint: 'Factorise 4x + 8. Qu’est-ce qui se répète ?',
  );
  String _historyFilter = 'Tout';
  String _studentFilter = 'Toute la classe';
  String _studentSearch = '';
  String _contentFilter = 'Tous';
  String _reportRange = 'Cette semaine';
  String _reportGroup = 'Toute la classe';
  String? _reportReason;
  final Map<String, double> _downloads = {
    'Factorisation': .35,
    'Équations et inéquations': 1,
  };
  final Map<String, bool> _pausedDownloads = {};
  final Set<String> _selectedExercises = {
    'Repérer le facteur commun',
    'Identité remarquable a² − b²',
  };
  int _lessonCard = 0;
  int _onboardingPage = 0;
  int _question = 1;
  int _selectedAnswer = -1;
  String _exerciseDifficulty = 'facile';
  String _studentId = 'Mboa-24';
  String _selectedClass = '3e A • Lycée de Bonabéri';
  String _selectedChapter = 'Factorisation';

  int get _exerciseFactor => switch (_exerciseDifficulty) {
    'facile' => 7,
    'moyen' => 4,
    _ => 3,
  };

  int get _exerciseSquare => _exerciseFactor * _exerciseFactor;

  String get _exerciseAnswer => '(x − $_exerciseFactor)(x + $_exerciseFactor)';

  String get _exerciseHint =>
      '$_exerciseSquare, c’est $_exerciseFactor². As-tu reconnu a² − b² ?';

  TutorAnswer _answerFor(String question) {
    final normalized = _normalizeText(question);

    if (normalized.contains('thales') ||
        normalized.contains('triangle') ||
        normalized.contains('parallele')) {
      return (
        title: 'On regarde les triangles ensemble 💛',
        explanation:
            'Avec une droite parallèle à un côté d’un triangle, les longueurs correspondantes sont proportionnelles.',
        example: 'Si (MN) // (BC), alors AM/AB = AN/AC.',
        reason:
            'Les deux triangles ont la même forme, même si leur taille change.',
        steps: [
          'Vérifie que les points sont alignés.',
          'Repère les droites parallèles.',
          'Écris les rapports des côtés correspondants.',
        ],
        hint: 'Commence par noter les points alignés et les parallèles.',
      );
    }

    if (normalized.contains('equation') ||
        normalized.contains('inequation') ||
        normalized.contains('resoudre')) {
      return (
        title: 'Une équation, ça se résout pas à pas 💛',
        explanation:
            'Le but est de laisser x tout seul. Pour garder l’égalité, fais la même opération des deux côtés.',
        example: 'x + 5 = 12  →  x = 12 − 5  →  x = 7',
        reason: 'On vérifie : 7 + 5 = 12. C’est juste !',
        steps: [
          'Repère l’opération faite avec x.',
          'Fais l’opération inverse des deux côtés.',
          'Remplace x dans l’équation pour vérifier.',
        ],
        hint: 'Quelle opération permet d’annuler le + 5 ?',
      );
    }

    if (normalized.contains('identite') ||
        normalized.contains('a2') ||
        normalized.contains('carre') ||
        normalized.contains('difference de deux')) {
      return (
        title: 'Reconnaissons l’identité remarquable 💛',
        explanation:
            'Une différence de deux carrés se transforme en produit : le carré du premier terme moins le carré du second.',
        example: 'a² − b² = (a − b)(a + b)',
        reason: 'Par exemple, x² − 25 = (x − 5)(x + 5), car 25 = 5².',
        steps: [
          'Repère deux carrés séparés par un signe moins.',
          'Trouve la racine carrée de chaque terme.',
          'Écris les deux parenthèses avec − puis +.',
        ],
        hint: 'Dans x² − 49, quel nombre au carré donne 49 ?',
      );
    }

    if (normalized.contains('factor') ||
        normalized.contains('developp') ||
        normalized.contains('parenthese')) {
      return (
        title: 'On reprend la factorisation tout doucement 💛',
        explanation:
            'Factoriser, c’est l’inverse de développer. On transforme une addition ou une soustraction en multiplication.',
        example: '6x + 12 = 6(x + 2)',
        reason: 'Le 6 se retrouve dans les deux morceaux : 6x et 12.',
        steps: [
          'Repère le facteur commun.',
          'Mets-le devant les parenthèses.',
          'Vérifie en développant.',
        ],
        hint: 'Dans 4x + 8, quel nombre divise 4x et 8 ?',
      );
    }

    return (
      title: 'Cherchons ensemble 💛',
      explanation:
          'Je peux t’aider avec la factorisation, les identités remarquables, les équations et le théorème de Thalès.',
      example: 'Essaie : x² − 25 = (x − 5)(x + 5)',
      reason:
          'Choisis une notion ou reformule ta question avec un mot du cours.',
      steps: [
        'Choisis le chapitre qui te bloque.',
        'Repère les nombres et les signes importants.',
        'Avançons une étape à la fois.',
      ],
      hint: 'Tu peux écrire « équation », « factorisation » ou « Thalès ». ',
    );
  }

  String _normalizeText(String value) => value
      .toLowerCase()
      .replaceAll('é', 'e')
      .replaceAll('è', 'e')
      .replaceAll('ê', 'e')
      .replaceAll('à', 'a')
      .replaceAll('â', 'a')
      .replaceAll('î', 'i')
      .replaceAll('ï', 'i')
      .replaceAll('ô', 'o')
      .replaceAll('ù', 'u')
      .replaceAll('û', 'u')
      .replaceAll('ç', 'c');

  Future<void> _askTutor(String question) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty || _isAskingTutor) return;

    if (TutorService.isConfigured && !_cloudTutorConsentGiven) {
      final consent = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Envoyer ta question à Gemma ?'),
          content: const Text(
            'Ta question sera envoyée au serveur Sabi puis au service d’IA de Google pour préparer une réponse. '
            'N’écris pas ton nom, ton adresse, le nom de ton école ni d’autre information personnelle. '
            'Tu peux annuler et garder une réponse préparée sur ce téléphone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Rester ici'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Envoyer ma question'),
            ),
          ],
        ),
      );
      if (consent != true || !mounted) return;
      _cloudTutorConsentGiven = true;
    }

    setState(() {
      _tutorQuestion = trimmed;
      _tutorAnswer = _answerFor(trimmed);
      _tutorStatus = TutorService.isConfigured
          ? 'Je prépare une explication…'
          : 'Réponse préparée sur ce téléphone.';
      _isAskingTutor = TutorService.isConfigured;
      _tutorInputController.clear();
    });

    if (!TutorService.isConfigured) return;

    try {
      final response = await _tutorService.ask(trimmed);
      if (!mounted) return;
      setState(() {
        _tutorAnswer = (
          title: 'Une explication pour toi 💛',
          explanation: response,
          example: '',
          reason: '',
          steps: const [],
          hint: _answerFor(trimmed).hint,
        );
        _tutorStatus = 'Réponse générée par Gemma.';
        _isOnline = true;
        _isAskingTutor = false;
      });
    } on TutorServiceException catch (error) {
      if (!mounted) return;
      setState(() {
        _tutorStatus =
            '${error.message} Je te propose une réponse préparée hors ligne.';
        _isOnline = false;
        _isAskingTutor = false;
      });
    }
  }

  Widget _homeSearch() {
    final entries = [
      (
        title: 'Factorisation',
        detail: 'Facteur commun, identités remarquables',
        keywords: 'factorisation facteur commun',
        chapter: 'Factorisation',
        destination: SabiScreen.chapter,
      ),
      (
        title: 'Identités remarquables',
        detail: 'a² − b² et développement',
        keywords: 'identités remarquables carre difference',
        chapter: 'Factorisation',
        destination: SabiScreen.lesson,
      ),
      (
        title: 'Équations et inéquations',
        detail: 'Isoler x et vérifier une solution',
        keywords: 'equation inéquation resoudre x',
        chapter: 'Équations et inéquations',
        destination: SabiScreen.chapter,
      ),
      (
        title: 'Théorème de Thalès',
        detail: 'Triangles, parallèles et longueurs',
        keywords: 'thales triangle parallèle proportionnalité',
        chapter: 'Théorème de Thalès',
        destination: SabiScreen.chapter,
      ),
    ];
    final query = _normalizeText(_searchQuery.trim());
    final matches = query.isEmpty
        ? const []
        : entries
              .where(
                (entry) =>
                    _normalizeText(entry.title).contains(query) ||
                    _normalizeText(entry.detail).contains(query) ||
                    _normalizeText(entry.keywords).contains(query),
              )
              .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Chercher une leçon ou une notion',
            prefixIcon: const Icon(Icons.search_rounded, color: forest),
            suffixIcon: _searchQuery.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Effacer la recherche',
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        if (query.isNotEmpty) ...[
          const SizedBox(height: 8),
          if (matches.isEmpty)
            _whiteCard(
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Aucun résultat dans les leçons hors ligne.',
                        style: TextStyle(color: muted),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _tutorInputController.text = _searchQuery;
                        _navigate(SabiScreen.tutor);
                      },
                      child: const Text('Demander à Sabi'),
                    ),
                  ],
                ),
              ),
            )
          else
            ...matches.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(19),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(19),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: paleGreen,
                        child: Icon(Icons.menu_book_rounded, color: forest),
                      ),
                      title: Text(
                        entry.title,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(entry.detail),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: muted,
                      ),
                      onTap: () {
                        _selectedChapter = entry.chapter;
                        _navigate(entry.destination);
                      },
                    ),
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }

  bool get _isStudentTab => const {
    SabiScreen.home,
    SabiScreen.tutor,
    SabiScreen.progress,
    SabiScreen.profile,
  }.contains(_screen);

  void _navigate(SabiScreen next) {
    if (next == _screen) return;
    setState(() {
      _history.add(_screen);
      _screen = next;
    });
  }

  void _replace(SabiScreen next) {
    setState(() {
      _screen = next;
      _history.clear();
    });
  }

  void _back() {
    if (_screen == SabiScreen.test) {
      _showExitTest();
      return;
    }
    if (_history.isNotEmpty) {
      setState(() => _screen = _history.removeLast());
    } else {
      _replace(SabiScreen.home);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    if (!_hasSized) {
      _hasSized = true;
      _splashTimer = Timer(const Duration(seconds: 2), () {
        if (!mounted || _screen != SabiScreen.splash) return;
        if (wide) {
          _replace(SabiScreen.dashboard);
        } else {
          _replace(SabiScreen.onboarding);
        }
      });
    }
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    _answerController.dispose();
    _searchController.dispose();
    _tutorInputController.dispose();
    _tutorService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = switch (_screen) {
      SabiScreen.splash => _splash(),
      SabiScreen.onboarding => _onboarding(),
      SabiScreen.auth => _auth(),
      SabiScreen.consent => _consent(),
      SabiScreen.levelIntro => _levelIntro(),
      SabiScreen.test => _placementTest(),
      SabiScreen.testResult => _testResult(),
      SabiScreen.home => _home(),
      SabiScreen.chapter => _chapter(),
      SabiScreen.lesson => _lesson(),
      SabiScreen.exercise => _exercise(),
      SabiScreen.correction => _correction(),
      SabiScreen.mastered => _mastered(),
      SabiScreen.tutor => _tutor(),
      SabiScreen.progress => _progress(),
      SabiScreen.badges => _badges(),
      SabiScreen.history => _historyPage(),
      SabiScreen.offline => _offline(),
      SabiScreen.profile => _profile(),
      SabiScreen.settings => _settings(),
      SabiScreen.privacy => _privacy(),
      SabiScreen.help => _help(),
      SabiScreen.notifications => _notifications(),
      SabiScreen.teacherLogin => _teacherLogin(),
      SabiScreen.classSetup => _classSetup(),
      SabiScreen.dashboard => _dashboard(),
      SabiScreen.skills => _skills(),
      SabiScreen.students => _students(),
      SabiScreen.studentDetail => _studentDetail(),
      SabiScreen.remediation => _remediation(),
      SabiScreen.reports => _reports(),
      SabiScreen.content => _content(),
      SabiScreen.contentDetail => _contentDetail(),
      SabiScreen.flowMap => _flowMap(),
    };
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(_largeText ? 1.18 : 1)),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _back();
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: KeyedSubtree(key: ValueKey(_screen), child: screen),
        ),
      ),
    );
  }

  Widget _splash() => Scaffold(
    body: Stack(
      fit: StackFit.expand,
      children: [
        const CustomPaint(painter: KentePainter()),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const OwlAvatar(size: 116),
            const SizedBox(height: 18),
            const Text(
              'sabi',
              style: TextStyle(
                fontSize: 54,
                fontWeight: FontWeight.w900,
                letterSpacing: -2,
                color: forest,
              ),
            ),
            Text(
              'Comprendre, à ton rythme',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: forestDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 38),
            const SizedBox(
              width: 23,
              height: 23,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: forest),
            ),
          ],
        ),
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Center(
            child: TextButton(
              onPressed: () => _replace(SabiScreen.onboarding),
              child: const Text('Découvrir Sabi'),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _onboarding() {
    const slides = [
      (
        icon: Icons.lightbulb_rounded,
        title: 'On avance ensemble',
        body:
            'Des explications simples, étape par étape. Tu peux demander autrement.',
        color: Color(0xFFFFE9BD),
        label: 'Explications simples',
      ),
      (
        icon: Icons.extension_rounded,
        title: 'Des exercices pour toi',
        body:
            'Sabi repère ce qui te bloque et prépare un exercice à ton niveau.',
        color: Color(0xFFE4F2E9),
        label: 'Exercices pour toi',
      ),
      (
        icon: Icons.wifi_off_rounded,
        title: 'Même sans réseau',
        body:
            'Télécharge tes chapitres au lycée ou au village. Apprends partout.',
        color: Color(0xFFFCE9DE),
        label: 'Marche sans Internet',
      ),
    ];
    final slide = slides[_onboardingPage];
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity == null) return;
            setState(() {
              _onboardingPage = details.primaryVelocity! < 0
                  ? (_onboardingPage + 1).clamp(0, slides.length - 1)
                  : (_onboardingPage - 1).clamp(0, slides.length - 1);
            });
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _navigate(SabiScreen.auth),
                    child: const Text('Passer'),
                  ),
                ),
                const Spacer(),
                Center(
                  child: Container(
                    width: 205,
                    height: 205,
                    decoration: BoxDecoration(
                      color: slide.color,
                      borderRadius: BorderRadius.circular(64),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Positioned(
                          right: 14,
                          top: 20,
                          child: Icon(Icons.star, color: yellow, size: 31),
                        ),
                        Icon(slide.icon, size: 92, color: forest),
                        const Positioned(
                          bottom: 13,
                          child: OwlAvatar(size: 72),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 44),
                Center(
                  child: Text(
                    slide.label,
                    style: const TextStyle(
                      color: forest,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  slide.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 29,
                    color: forestDark,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  slide.body,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 17,
                    height: 1.6,
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    slides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: index == _onboardingPage ? 26 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: index == _onboardingPage ? forest : line,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                PrimaryButton(
                  label: _onboardingPage == slides.length - 1
                      ? 'Commencer'
                      : 'Continuer',
                  onPressed: () {
                    if (_onboardingPage < slides.length - 1) {
                      setState(() => _onboardingPage++);
                    } else {
                      _navigate(SabiScreen.auth);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _auth() => _entryScaffold(
    title: 'Bonjour !',
    subtitle: 'Un petit code, et on commence.',
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 18),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF2EEE6),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              _authTab('Inscription', _isSignup, () {
                setState(() => _isSignup = true);
              }),
              _authTab('Connexion', !_isSignup, () {
                setState(() => _isSignup = false);
              }),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const FieldLabel(label: 'Ton petit code'),
        const SizedBox(height: 8),
        TextField(
          decoration: _inputDecoration('Ex. Mboa-24', Icons.badge_outlined),
          onChanged: (value) => _studentId = value.isEmpty ? 'Mboa-24' : value,
        ),
        const SizedBox(height: 20),
        const FieldLabel(label: 'Ton code secret à 4 chiffres'),
        const SizedBox(height: 8),
        TextField(
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: _inputDecoration(
            '••••',
            Icons.lock_outline,
          ).copyWith(counterText: ''),
        ),
        const SizedBox(height: 10),
        const InfoBanner(
          icon: Icons.shield_outlined,
          text: 'Pas besoin de ton nom de famille ni de ton adresse e-mail.',
          color: paleGreen,
        ),
        const SizedBox(height: 22),
        PrimaryButton(
          label: 'Continuer',
          onPressed: () =>
              _navigate(_isSignup ? SabiScreen.consent : SabiScreen.home),
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: () => _navigate(SabiScreen.teacherLogin),
          icon: const Icon(Icons.school_outlined),
          label: const Text('Je suis enseignant'),
        ),
      ],
    ),
  );

  Widget _authTab(String label, bool active, VoidCallback onTap) => Expanded(
    child: Material(
      color: active ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: SizedBox(
          height: 48,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: active ? forest : muted,
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _consent() => _entryScaffold(
    title: 'On demande aux grands',
    subtitle: 'Tu es presque prêt·e.',
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const OwlTip(
          text:
              'Pour créer ton compte, demande à ton parent ou à ton tuteur de lire ceci avec toi.',
        ),
        const SizedBox(height: 16),
        _whiteCard(
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'À quoi sert Sabi ?',
                  style: TextStyle(
                    fontSize: 17,
                    color: forest,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Sabi aide les élèves de Troisième à comprendre les maths. '
                  'Un professeur reste toujours là pour accompagner la classe. '
                  'Les réponses de l’élève ne sont pas publiées.',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        CheckboxListTile(
          value: _consentGiven,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: forest,
          title: const Text(
            'J’ai l’autorisation de mon parent ou tuteur.',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          onChanged: (value) => setState(() => _consentGiven = value ?? false),
        ),
        const SizedBox(height: 14),
        PrimaryButton(
          label: 'Continuer',
          enabled: _consentGiven,
          onPressed: () => _navigate(SabiScreen.levelIntro),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => _navigate(SabiScreen.privacy),
          child: const Text('En savoir plus sur la confidentialité'),
        ),
      ],
    ),
  );

  Widget _levelIntro() => _entryScaffold(
    title: 'Découvrons ton niveau',
    subtitle: 'Juste pour préparer ton parcours.',
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        const Center(child: OwlAvatar(size: 105)),
        const SizedBox(height: 17),
        _whiteCard(
          const Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(Icons.favorite_outline, color: terra, size: 29),
                SizedBox(height: 10),
                Text(
                  'Pas de panique, ce n’est pas une note.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 19,
                    color: forestDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '10 petites questions pour trouver les bonnes explications. '
                  'Tu peux dire « Je ne sais pas ».',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Démarrer',
          onPressed: () {
            _question = 1;
            _navigate(SabiScreen.test);
          },
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => _navigate(SabiScreen.home),
          child: const Text('Je le ferai plus tard'),
        ),
      ],
    ),
  );

  Widget _placementTest() {
    const questions = [
      ('Développe : 2(x + 3)', ['2x + 3', '2x + 6', 'x + 6', '5x']),
      ('Combien vaut 7 × 8 ?', ['54', '56', '64', '48']),
      ('Résous : x + 5 = 12', ['x = 17', 'x = 7', 'x = 5', 'x = 12']),
      ('Écris ¾ sous forme décimale.', ['0,25', '0,5', '0,75', '1,25']),
      (
        'Factorise : x² − 9',
        ['(x − 3)²', '(x + 3)²', '(x − 3)(x + 3)', 'x(x − 9)'],
      ),
      ('a² + 2ab + b² vaut…', ['(a + b)²', '(a − b)²', 'a² − b²', '2(a + b)']),
      (
        'Dans un triangle, une droite parallèle à un côté…',
        [
          'change les angles',
          'forme des triangles semblables',
          'supprime les côtés',
          'n’a aucun effet',
        ],
      ),
      ('Si 3x = 18, alors x vaut…', ['6', '15', '21', '3']),
      (
        'Développe : (x − 4)²',
        ['x² − 16', 'x² − 8x + 16', 'x² + 8x + 16', '2x − 8'],
      ),
      ('Si AB/AC = ½, alors AC/AB vaut…', ['½', '1', '2', '4']),
    ];
    final item = questions[(_question - 1).clamp(0, 9)];
    return _scaffold(
      title: 'Petit test',
      back: true,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Question $_question sur 10',
                  style: const TextStyle(
                    color: forest,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text('${_question * 10} %', style: const TextStyle(color: muted)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: _question / 10,
              minHeight: 9,
              backgroundColor: line,
              color: forest,
            ),
          ),
          const SizedBox(height: 22),
          const OwlTip(text: 'Prends ton temps. On apprend en essayant !'),
          const SizedBox(height: 23),
          _whiteCard(
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.$1,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_question == 0) const Text('Les maths de tous les jours'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(
            item.$2.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: ChoiceTile(
                label: item.$2[index],
                selected: _selectedAnswer == index,
                onTap: () => setState(() => _selectedAnswer = index),
              ),
            ),
          ),
          ChoiceTile(
            label: 'Je ne sais pas',
            selected: _selectedAnswer == 4,
            icon: Icons.favorite_border,
            onTap: () => setState(() => _selectedAnswer = 4),
          ),
          const SizedBox(height: 15),
          PrimaryButton(
            label: _question == 10 ? 'Voir mon parcours' : 'Question suivante',
            onPressed: () {
              if (_question == 10) {
                _navigate(SabiScreen.testResult);
              } else {
                setState(() {
                  _question++;
                  _selectedAnswer = -1;
                });
              }
            },
          ),
          const SizedBox(height: 5),
          TextButton(
            onPressed: () {
              if (_question == 10) {
                _navigate(SabiScreen.testResult);
              } else {
                setState(() {
                  _question++;
                  _selectedAnswer = -1;
                });
              }
            },
            child: const Text('Passer cette question'),
          ),
        ],
      ),
    );
  }

  Widget _testResult() => _scaffold(
    title: 'Ton point de départ',
    back: true,
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Center(child: OwlAvatar(size: 104)),
        const SizedBox(height: 14),
        const Text(
          'Bravo pour ta curiosité !',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: forest,
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Voici les notions qu’on va découvrir ensemble.',
          textAlign: TextAlign.center,
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 22),
        _skillSummary('Calcul et fractions', 'Maîtrisé', paleGreen, forest),
        _skillSummary(
          'Équations',
          'En progrès',
          const Color(0xFFFFF2D5),
          const Color(0xFF8A5D00),
        ),
        _skillSummary(
          'Identités remarquables',
          'À renforcer',
          const Color(0xFFFCE9DE),
          terra,
        ),
        _skillSummary(
          'Théorème de Thalès',
          'À renforcer',
          const Color(0xFFFCE9DE),
          terra,
        ),
        _skillSummary(
          'Factorisation',
          'À renforcer',
          const Color(0xFFFCE9DE),
          terra,
        ),
        const SizedBox(height: 14),
        const InfoBanner(
          icon: Icons.auto_awesome,
          text: '3 compétences à renforcer. On s’en occupe ensemble !',
          color: Color(0xFFFFF2D5),
        ),
        const SizedBox(height: 18),
        PrimaryButton(
          label: 'Voir mon parcours',
          onPressed: () => _navigate(SabiScreen.home),
        ),
      ],
    ),
  );

  Widget _home() => _studentScaffold(
    title: 'Accueil',
    root: true,
    trailing: IconButton(
      tooltip: 'Notifications',
      onPressed: () => _navigate(SabiScreen.notifications),
      icon: const Icon(Icons.notifications_none_rounded, color: forest),
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 25),
      children: [
        if (!_isOnline)
          InfoBanner(
            icon: TutorService.isConfigured
                ? Icons.cloud_queue_rounded
                : Icons.wifi_off_rounded,
            text: TutorService.isConfigured
                ? _tutorStatus == null
                      ? 'Gemma sera testée à ta première question.'
                      : 'Gemma n’est pas joignable. Tes leçons restent avec toi.'
                : 'Tu es hors ligne. Tes leçons restent avec toi.',
            color: const Color(0xFFFFF2D5),
            action: TextButton(
              onPressed: () => _navigate(SabiScreen.offline),
              child: const Text('Voir'),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bonjour,',
                    style: TextStyle(color: muted, fontSize: 15),
                  ),
                  Text(
                    _studentId,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 27,
                      color: forestDark,
                    ),
                  ),
                ],
              ),
            ),
            const OwlAvatar(size: 58),
          ],
        ),
        const SizedBox(height: 17),
        _homeSearch(),
        const SizedBox(height: 19),
        _continueCard(),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _whiteCard(
                const Padding(
                  padding: EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Icon(Icons.flag_rounded, color: forest, size: 25),
                      SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Objectif du jour',
                              style: TextStyle(
                                color: muted,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '1 sur 2 leçons',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _whiteCard(
                const Padding(
                  padding: EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        color: terra,
                        size: 26,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ta série',
                              style: TextStyle(
                                color: muted,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '3 jours 🔥',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        _sectionTitle('Ton parcours', 'Tout voir', () {
          _navigate(SabiScreen.progress);
        }),
        const SizedBox(height: 12),
        _chapterCard(
          title: 'Factorisation',
          subtitle: '4 compétences • 12 min',
          progress: .35,
          icon: Icons.grid_view_rounded,
          color: const Color(0xFFE7F3EC),
          offline: true,
        ),
        const SizedBox(height: 10),
        _chapterCard(
          title: 'Équations et inéquations',
          subtitle: '5 compétences • 15 min',
          progress: .12,
          icon: Icons.functions_rounded,
          color: const Color(0xFFFFF2D5),
          offline: true,
        ),
        const SizedBox(height: 10),
        _chapterCard(
          title: 'Théorème de Thalès',
          subtitle: '3 compétences • 10 min',
          progress: 0,
          icon: Icons.change_history_rounded,
          color: const Color(0xFFFCE9DE),
          offline: false,
        ),
        const SizedBox(height: 17),
        OutlinedButton.icon(
          onPressed: () => _navigate(SabiScreen.offline),
          icon: const Icon(Icons.cloud_download_outlined),
          label: const Text('Mes leçons hors ligne'),
          style: OutlinedButton.styleFrom(
            foregroundColor: forest,
            minimumSize: const Size.fromHeight(52),
            side: const BorderSide(color: forest),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _continueCard() => Material(
    color: forest,
    borderRadius: BorderRadius.circular(23),
    child: InkWell(
      onTap: () => _navigate(SabiScreen.lesson),
      borderRadius: BorderRadius.circular(23),
      child: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: KentePainter())),
          Padding(
            padding: const EdgeInsets.all(19),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'CONTINUER',
                        style: TextStyle(
                          color: Color(0xFFD7EEE1),
                          fontSize: 11,
                          letterSpacing: 1.3,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const OwlAvatar(size: 43),
                  ],
                ),
                const SizedBox(height: 7),
                const Text(
                  'Les identités remarquables',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Tu étais à l’étape 2 sur 3',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(9)),
                        child: LinearProgressIndicator(
                          value: .58,
                          minHeight: 6,
                          backgroundColor: Colors.white24,
                          color: yellow,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: yellow,
                      size: 22,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _chapterCard({
    required String title,
    required String subtitle,
    required double progress,
    required IconData icon,
    required Color color,
    required bool offline,
  }) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(19),
    child: InkWell(
      onTap: () {
        _selectedChapter = title;
        _navigate(SabiScreen.chapter);
      },
      borderRadius: BorderRadius.circular(19),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            SizedBox(
              width: 52,
              height: 52,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 4,
                    backgroundColor: line,
                    color: forest,
                  ),
                  CircleAvatar(
                    radius: 19,
                    backgroundColor: color,
                    child: Icon(icon, color: forest, size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: muted),
                  ),
                  if (offline) ...[
                    const SizedBox(height: 5),
                    const MiniPill(
                      label: 'Disponible hors ligne',
                      color: paleGreen,
                      textColor: forest,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: muted),
          ],
        ),
      ),
    ),
  );

  Widget _chapter() => _studentScaffold(
    title: 'Le chapitre',
    back: true,
    body: ListView(
      padding: const EdgeInsets.fromLTRB(19, 10, 19, 90),
      children: [
        _whiteCard(
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: .35,
                        color: forest,
                        strokeWidth: 5,
                      ),
                      Icon(Icons.grid_view_rounded, color: forest),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedChapter,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: forestDark,
                        ),
                      ),
                      const Text(
                        '4 compétences • 12 min',
                        style: TextStyle(color: muted),
                      ),
                      const SizedBox(height: 7),
                      const MiniPill(
                        label: 'Disponible hors ligne',
                        color: paleGreen,
                        textColor: forest,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 21),
        const Text(
          'Tes étapes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        _skillTile(
          'Reconnaître les facteurs communs',
          'Maîtrisé',
          'Tu sais repérer ce qui se répète.',
          1,
        ),
        _skillTile(
          'Utiliser a² − b²',
          'En cours',
          'On apprend les identités remarquables.',
          0,
        ),
        _skillTile(
          'Factoriser un trinôme',
          'Débloqué bientôt',
          'D’abord, finissons l’étape précédente.',
          -1,
        ),
        _skillTile(
          'Résoudre après factorisation',
          'Verrouillé',
          'Cette étape s’ouvrira au bon moment.',
          -1,
        ),
        const SizedBox(height: 14),
        SecondaryButton(
          label: 'Télécharger pour hors ligne',
          icon: Icons.download_rounded,
          onPressed: () => _navigate(SabiScreen.offline),
        ),
      ],
    ),
    floating: _askButton(),
  );

  Widget _skillTile(String title, String state, String note, int status) {
    final color = status == 1
        ? forest
        : status == 0
        ? const Color(0xFF8A5D00)
        : muted;
    final bg = status == 1
        ? paleGreen
        : status == 0
        ? const Color(0xFFFFF2D5)
        : const Color(0xFFF2EEE6);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          borderRadius: BorderRadius.circular(17),
          onTap: () => _navigate(SabiScreen.lesson),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor: bg,
                  child: Icon(
                    status == 1
                        ? Icons.check_rounded
                        : status == 0
                        ? Icons.play_arrow_rounded
                        : Icons.lock_outline,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        note,
                        style: const TextStyle(fontSize: 12, color: muted),
                      ),
                    ],
                  ),
                ),
                MiniPill(label: state, color: bg, textColor: color),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _lesson() => _studentScaffold(
    title: 'Les identités',
    back: true,
    body: ListView(
      padding: const EdgeInsets.fromLTRB(19, 8, 19, 92),
      children: [
        Row(
          children: [
            MiniPill(
              label: 'Étape ${_lessonCard + 1} sur 3',
              color: paleGreen,
              textColor: forest,
            ),
            const Spacer(),
            const Icon(Icons.swipe_rounded, color: muted, size: 18),
            const SizedBox(width: 5),
            const Text(
              'Fais glisser',
              style: TextStyle(color: muted, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 15),
        GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity == null) return;
            setState(() {
              _lessonCard = details.primaryVelocity! < 0
                  ? (_lessonCard + 1).clamp(0, 2)
                  : (_lessonCard - 1).clamp(0, 2);
            });
          },
          child: _whiteCard(
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _lessonCard == 0
                        ? 'Une identité bien utile !'
                        : _lessonCard == 1
                        ? 'Reconnaître les carrés'
                        : 'Vérifier ton résultat',
                    style: const TextStyle(
                      color: forest,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _lessonCard == 0
                        ? 'Imagine deux parcelles carrées de côtés a et b. '
                              'La différence de leurs surfaces se factorise facilement.'
                        : _lessonCard == 1
                        ? 'Dans x² − 25, les deux parties sont des carrés : x² et 5². '
                              'C’est une différence.'
                        : 'Développe les parenthèses. Si tu retrouves l’expression '
                              'de départ, c’est gagné !',
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Text(
                      _lessonCard == 0
                          ? 'a² − b² = (a − b)(a + b)'
                          : _lessonCard == 1
                          ? 'x² − 25 = x² − 5²'
                          : '(x − 5)(x + 5) = x² − 25',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                        color: forestDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _whiteCard(
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Un exemple ensemble',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: forestDark,
                  ),
                ),
                const SizedBox(height: 12),
                StepLine(
                  number: '1',
                  text: _lessonCard == 2
                      ? 'x × x donne x².'
                      : 'Repère les deux carrés :  x² − 25',
                ),
                StepLine(
                  number: '2',
                  text: _lessonCard == 2
                      ? 'Les termes −5x et +5x s’annulent.'
                      : 'Écris 25 sous forme de carré :  5²',
                ),
                StepLine(
                  number: '3',
                  text: _lessonCard == 2
                      ? 'Il reste bien x² − 25.'
                      : 'Utilise a² − b² :  (x − 5)(x + 5)',
                ),
                const SizedBox(height: 4),
                Text(
                  _lessonCard == 2
                      ? 'Tu as vérifié ton résultat !'
                      : 'Vérification : (x − 5)(x + 5) = x² − 25',
                  style: const TextStyle(
                    color: forest,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        SecondaryButton(
          label: 'Je ne comprends pas',
          icon: Icons.chat_bubble_outline,
          onPressed: () => _navigate(SabiScreen.tutor),
        ),
        const SizedBox(height: 10),
        PrimaryButton(
          label: 'S’entraîner',
          onPressed: () => _navigate(SabiScreen.exercise),
        ),
      ],
    ),
    floating: _askButton(),
  );

  Widget _exercise() => _studentScaffold(
    title: 'À toi de jouer',
    back: true,
    body: ListView(
      padding: const EdgeInsets.fromLTRB(19, 7, 19, 92),
      children: [
        Row(
          children: [
            MiniPill(
              label: _exerciseDifficulty.toUpperCase(),
              color: paleGreen,
              textColor: forest,
            ),
            const SizedBox(width: 8),
            const Icon(Icons.wifi_off_rounded, color: forest, size: 19),
            const SizedBox(width: 4),
            const Expanded(
              child: Text(
                'Disponible hors ligne',
                textAlign: TextAlign.right,
                style: TextStyle(color: muted, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _whiteCard(
          Padding(
            padding: const EdgeInsets.all(19),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Factorise cette expression :',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                Center(
                  child: Text(
                    'x² − $_exerciseSquare',
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: forestDark,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Écris ta réponse ci-dessous.',
                  style: TextStyle(color: muted),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _answerController,
          decoration: InputDecoration(
            hintText: _exerciseAnswer,
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.edit_outlined, color: forest),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: forest, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 7,
          children: ['a/b', 'x²', 'x', '(', ')', '−', '+', '=']
              .map(
                (key) => SizedBox(
                  width: 48,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () => _insertMathKey(key),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: forest,
                      side: const BorderSide(color: line),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      key,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
        _hintCard(),
        const SizedBox(height: 14),
        PrimaryButton(
          label: 'Vérifier ma réponse',
          onPressed: () {
            final answer = _answerController.text
                .replaceAll(RegExp(r'\s+'), '')
                .replaceAll('−', '-')
                .toLowerCase();
            final expected = _exerciseAnswer
                .replaceAll(RegExp(r'\s+'), '')
                .replaceAll('−', '-')
                .toLowerCase();
            final reversed = '(x+$_exerciseFactor)(x-$_exerciseFactor)';
            setState(() {
              _isCorrect = answer == expected || answer == reversed;
            });
            _navigate(SabiScreen.correction);
          },
        ),
        const SizedBox(height: 6),
        TextButton.icon(
          onPressed: () => _navigate(SabiScreen.tutor),
          icon: const Icon(Icons.chat_bubble_outline),
          label: const Text('Demander à Sabi'),
        ),
      ],
    ),
    floating: _askButton(),
  );

  void _insertMathKey(String key) {
    final insertion = switch (key) {
      'a/b' => '()/()',
      'x²' => 'x^2',
      '−' => '-',
      _ => key,
    };
    final selection = _answerController.selection;
    final text = _answerController.text;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    _answerController.value = TextEditingValue(
      text: text.replaceRange(start, end, insertion),
      selection: TextSelection.collapsed(offset: start + insertion.length),
    );
    setState(() {});
  }

  Widget _hintCard() => Container(
    decoration: BoxDecoration(
      color: const Color(0xFFFFF2D5),
      borderRadius: BorderRadius.circular(18),
    ),
    padding: const EdgeInsets.fromLTRB(15, 13, 15, 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.lightbulb_outline, color: Color(0xFF8A5D00)),
            SizedBox(width: 8),
            Text(
              'Un petit indice ?',
              style: TextStyle(
                color: Color(0xFF684700),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (!_showHint && !_showSolution)
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => setState(() => _showHint = true),
              child: const Text(
                'Indice 1  •  repère deux carrés',
                textAlign: TextAlign.left,
              ),
            ),
          )
        else ...[
          Text(_exerciseHint),
          if (!_showSolution)
            TextButton(
              onPressed: () => setState(() => _showSolution = true),
              child: const Text('Indice 2'),
            )
          else
            TextButton(
              onPressed: () => _navigate(SabiScreen.correction),
              child: const Text('Voir les étapes de la solution'),
            ),
        ],
      ],
    ),
  );

  Widget _correction() => _studentScaffold(
    title: 'On corrige ensemble',
    back: true,
    body: ListView(
      padding: const EdgeInsets.fromLTRB(19, 9, 19, 25),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _isCorrect ? paleGreen : const Color(0xFFFCE9DE),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                _isCorrect ? Icons.celebration_rounded : Icons.favorite_rounded,
                color: _isCorrect ? forest : terra,
                size: 34,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _isCorrect
                      ? 'Bravo ! Bien joué !'
                      : 'Presque, tu progresses !',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: _isCorrect ? forest : terra,
                  ),
                ),
              ),
              const OwlAvatar(size: 45),
            ],
          ),
        ),
        const SizedBox(height: 15),
        if (!_isCorrect)
          const InfoBanner(
            icon: Icons.search_rounded,
            text:
                'Tu as peut-être oublié l’identité remarquable a² − b². Regardons ensemble.',
            color: Color(0xFFFFF2D5),
          ),
        if (_isCorrect) ...[
          const SizedBox(height: 10),
          PrimaryButton(
            label: 'Compétence maîtrisée !',
            icon: Icons.celebration_rounded,
            onPressed: () => _navigate(SabiScreen.mastered),
          ),
        ],
        const SizedBox(height: 15),
        _whiteCard(
          Padding(
            padding: const EdgeInsets.all(19),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'La solution, pas à pas',
                  style: TextStyle(
                    color: forest,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                StepLine(
                  number: '1',
                  text: 'x² − $_exerciseSquare = x² − $_exerciseFactor²',
                ),
                const StepLine(number: '2', text: 'a² − b² = (a − b)(a + b)'),
                StepLine(
                  number: '3',
                  text: 'Donc x² − $_exerciseSquare = $_exerciseAnswer',
                ),
                const Divider(height: 24),
                const Text(
                  'Astuce : développe pour vérifier ta réponse.',
                  style: TextStyle(color: muted),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Exercice plus difficile',
          onPressed: () {
            setState(() {
              _exerciseDifficulty = 'moyen';
              _isCorrect = false;
              _showHint = false;
              _showSolution = false;
              _answerController.clear();
            });
            _navigate(SabiScreen.exercise);
          },
        ),
        const SizedBox(height: 9),
        SecondaryButton(
          label: 'Un exercice plus facile',
          icon: Icons.sentiment_satisfied_alt,
          onPressed: () {
            setState(() {
              _exerciseDifficulty = 'facile';
              _isCorrect = false;
              _showHint = false;
              _showSolution = false;
              _answerController.clear();
            });
            _navigate(SabiScreen.exercise);
          },
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => _navigate(SabiScreen.chapter),
          child: const Text('Retour au chapitre'),
        ),
      ],
    ),
  );

  Widget _mastered() => Dialog(
    backgroundColor: Colors.transparent,
    insetPadding: const EdgeInsets.all(22),
    child: _whiteCard(
      Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, color: yellow, size: 50),
            const SizedBox(height: 4),
            const OwlAvatar(size: 88),
            const SizedBox(height: 8),
            const Text(
              'Compétence maîtrisée !',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: forest,
                fontSize: 23,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tu as compris la différence de deux carrés. Continue comme ça !',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted),
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Continuer mon parcours',
              onPressed: () => _navigate(SabiScreen.chapter),
            ),
            TextButton(
              onPressed: () => _navigate(SabiScreen.home),
              child: const Text('Retour à l’accueil'),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _tutor() => _studentScaffold(
    title: 'Tuteur Sabi',
    root: true,
    body: ListView(
      padding: const EdgeInsets.fromLTRB(17, 7, 17, 18),
      children: [
        Row(
          children: [
            OwlAvatar(size: 55),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sabi',
                    style: TextStyle(
                      color: forestDark,
                      fontWeight: FontWeight.w900,
                      fontSize: 19,
                    ),
                  ),
                  const Text(
                    'Ton amie en maths',
                    style: TextStyle(color: muted, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(
              _isOnline ? Icons.circle : Icons.circle_outlined,
              color: _isOnline
                  ? forest
                  : TutorService.isConfigured
                  ? const Color(0xFFC17A14)
                  : muted,
              size: 11,
            ),
            const SizedBox(width: 5),
            Text(
              _isOnline
                  ? 'Gemma prête'
                  : TutorService.isConfigured
                  ? _isAskingTutor
                        ? 'Connexion…'
                        : _tutorStatus == null
                        ? 'À tester'
                        : 'Indisponible'
                  : 'Mode local',
              style: TextStyle(
                color: _isOnline
                    ? forest
                    : TutorService.isConfigured
                    ? const Color(0xFFC17A14)
                    : muted,
                fontSize: 12,
              ),
            ),
          ],
        ),
        if (!_isOnline) ...[
          const SizedBox(height: 12),
          InfoBanner(
            icon: TutorService.isConfigured
                ? Icons.info_outline_rounded
                : Icons.wifi_off_rounded,
            text:
                _tutorStatus ??
                (TutorService.isConfigured
                    ? 'Gemma sera testée à ta première question.'
                    : 'Gemma n’est pas configurée. Je peux proposer une explication préparée sur ce téléphone.'),
            color: const Color(0xFFFFF2D5),
          ),
        ],
        if (TutorService.isConfigured && _isOnline) ...[
          const SizedBox(height: 12),
          const InfoBanner(
            icon: Icons.cloud_outlined,
            text:
                'Gemma est activé. Ta question part au serveur Sabi puis à Google. Évite les informations personnelles.',
            color: paleGreen,
          ),
        ],
        if (_tutorStatus != null && _isOnline)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _tutorStatus!,
              style: const TextStyle(color: muted, fontSize: 12),
            ),
          ),
        const SizedBox(height: 15),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 270),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: forest,
              borderRadius: BorderRadius.circular(
                19,
              ).copyWith(bottomRight: const Radius.circular(5)),
            ),
            child: Text(
              _tutorQuestion,
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              19,
            ).copyWith(bottomLeft: const Radius.circular(5)),
            boxShadow: const [
              BoxShadow(color: Color(0x0C1F2937), blurRadius: 12),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _tutorAnswer.title,
                style: const TextStyle(
                  color: forest,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              if (_isAskingTutor)
                const Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: forest,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text('Sabi cherche une explication…'),
                  ],
                )
              else ...[
                SelectableText(_tutorAnswer.explanation),
                if (_tutorAnswer.example.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    _tutorAnswer.example,
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: forestDark,
                    ),
                  ),
                ],
                if (_tutorAnswer.reason.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _tutorAnswer.reason,
                    style: const TextStyle(color: muted),
                  ),
                ],
              ],
            ],
          ),
        ),
        const SizedBox(height: 13),
        _whiteCard(
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ma méthode en 3 étapes',
                  style: TextStyle(
                    color: forestDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 11),
                for (var index = 0; index < _tutorAnswer.steps.length; index++)
                  StepLine(
                    number: '${index + 1}',
                    text: _tutorAnswer.steps[index],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Tu peux aussi me demander…',
          style: TextStyle(
            color: muted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 7),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            _quickChip('Explique plus simplement', Icons.sentiment_satisfied),
            _quickChip('Exemple concret', Icons.lightbulb_outline),
            _quickChip('Écouter l’explication', Icons.volume_up_outlined),
            _quickChip('Niveau plus avancé', Icons.trending_up),
          ],
        ),
        const SizedBox(height: 10),
        Material(
          color: paleGreen,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _audioPlaying = !_audioPlaying),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              child: Row(
                children: [
                  Icon(
                    _audioPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_fill_rounded,
                    color: forest,
                    size: 29,
                  ),
                  const SizedBox(width: 9),
                  Text(
                    _audioPlaying ? 'Mettre en pause' : 'Écouter l’explication',
                    style: const TextStyle(
                      color: forest,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    '0:42',
                    style: TextStyle(color: muted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF2D5),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Essaie d’abord 💡',
                style: TextStyle(
                  color: Color(0xFF684700),
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 3),
              Text(_tutorAnswer.hint),
              TextButton(
                onPressed: () => _navigate(SabiScreen.exercise),
                child: const Text('Indice : regarde les deux nombres'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Source : programme officiel, validé par un enseignant.',
          style: TextStyle(fontSize: 11, color: muted),
        ),
        const Text(
          'Sabi peut se tromper. Demande à ton enseignant si besoin.',
          style: TextStyle(fontSize: 11, color: muted),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _reportTutorError,
            icon: const Icon(Icons.flag_outlined, size: 16),
            label: const Text('Signaler une erreur'),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => _navigate(SabiScreen.exercise),
          icon: const Icon(Icons.edit_note_rounded),
          label: const Text('Proposer un exercice'),
          style: OutlinedButton.styleFrom(
            foregroundColor: forest,
            minimumSize: const Size.fromHeight(48),
            side: const BorderSide(color: line),
          ),
        ),
      ],
    ),
  );

  Widget _quickChip(String label, IconData icon) => ActionChip(
    avatar: Icon(icon, size: 16, color: forest),
    label: Text(label, style: const TextStyle(fontSize: 12)),
    backgroundColor: Colors.white,
    side: const BorderSide(color: line),
    onPressed: () {
      if (label == 'Écouter l’explication') {
        setState(() => _audioPlaying = !_audioPlaying);
        return;
      }
      _askTutor('$label : $_tutorQuestion');
    },
  );

  Future<void> _reportTutorError() => showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, updateDialog) => AlertDialog(
        title: const Text('Que faut-il signaler ?'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Une erreur de calcul', 'Une explication confuse', 'Autre']
              .map(
                (label) => ChoiceChip(
                  label: Text(label),
                  selected: _reportReason == label,
                  onSelected: (_) => updateDialog(() => _reportReason = label),
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: _reportReason == null
                ? null
                : () {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(
                        content: Text('Merci ! Ton message est envoyé.'),
                      ),
                    );
                    setState(() => _reportReason = null);
                  },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    ),
  );

  Widget _progress() => _studentScaffold(
    title: 'Tes progrès',
    root: true,
    body: ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      children: [
        _whiteCard(
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tes compétences',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
                const Text(
                  'Tu avances à ton rythme.',
                  style: TextStyle(color: muted),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 215,
                  child: CustomPaint(
                    painter: RadarPainter(),
                    child: const Center(
                      child: Text(
                        'Maths',
                        style: TextStyle(
                          color: forest,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
                const Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: [
                    LegendDot(color: forest, label: 'Mon parcours'),
                    LegendDot(color: yellow, label: 'Objectif'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _whiteCard(
          Padding(
            padding: const EdgeInsets.all(17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Expanded(
                      child: Text(
                        'Cette semaine',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      '4 leçons',
                      style: TextStyle(
                        color: forest,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                const Text(
                  'Tu as travaillé 35 minutes. C’est super !',
                  style: TextStyle(color: muted),
                ),
                const SizedBox(height: 6),
                const SizedBox(height: 93, child: WeeklyChart()),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        _sectionTitle('Tes badges', 'Voir tout', () {
          _navigate(SabiScreen.badges);
        }),
        const SizedBox(height: 9),
        Row(
          children: const [
            Expanded(
              child: BadgeTile(
                icon: Icons.wb_sunny_rounded,
                label: 'Premier pas',
                color: yellow,
              ),
            ),
            SizedBox(width: 9),
            Expanded(
              child: BadgeTile(
                icon: Icons.local_fire_department_rounded,
                label: '3 jours',
                color: terra,
              ),
            ),
            SizedBox(width: 9),
            Expanded(
              child: BadgeTile(
                icon: Icons.lock_rounded,
                label: 'À venir',
                color: muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SecondaryButton(
          label: 'Mes points à renforcer',
          icon: Icons.track_changes_rounded,
          onPressed: () => _navigate(SabiScreen.lesson),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => _navigate(SabiScreen.history),
          icon: const Icon(Icons.history_rounded),
          label: const Text('Historique'),
          style: OutlinedButton.styleFrom(
            foregroundColor: forest,
            minimumSize: const Size.fromHeight(51),
            side: const BorderSide(color: line),
          ),
        ),
      ],
    ),
  );

  Widget _badges() => _studentScaffold(
    title: 'Mes badges',
    back: true,
    body: ListView(
      padding: const EdgeInsets.all(19),
      children: [
        const OwlTip(
          text: 'Chaque petit pas compte. Tes badges célèbrent tes efforts !',
        ),
        const SizedBox(height: 17),
        const Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            BadgeTile(
              icon: Icons.wb_sunny_rounded,
              label: 'Premier pas',
              color: yellow,
            ),
            BadgeTile(
              icon: Icons.local_fire_department_rounded,
              label: '3 jours',
              color: terra,
            ),
            BadgeTile(
              icon: Icons.calculate_rounded,
              label: 'Calcul malin',
              color: forest,
            ),
            BadgeTile(icon: Icons.lock_rounded, label: 'À venir', color: muted),
          ],
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: 'Continuer à apprendre',
          onPressed: () => _navigate(SabiScreen.chapter),
        ),
      ],
    ),
  );

  Widget _historyPage() => _studentScaffold(
    title: 'Historique',
    back: true,
    body: ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      children: [
        const Text(
          'Tes derniers exercices',
          style: TextStyle(color: forest, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 11),
        Wrap(
          spacing: 7,
          children: ['Tout', 'Factorisation', 'Réussi']
              .map(
                (filter) => FilterChip(
                  label: Text(filter),
                  selected: _historyFilter == filter,
                  onSelected: (_) => setState(() => _historyFilter = filter),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        if (_historyFilter == 'Tout' || _historyFilter == 'Factorisation') ...[
          _historyTile(
            'Différence de deux carrés',
            'Aujourd’hui • 08:42',
            true,
          ),
          const SizedBox(height: 9),
          _historyTile('Mettre en facteur', 'Hier • 17:20', false),
          const SizedBox(height: 9),
        ],
        if (_historyFilter == 'Tout' || _historyFilter == 'Réussi')
          _historyTile('Équation à une inconnue', 'Mardi • 10:15', true),
        if (_historyFilter == 'Réussi') const SizedBox(height: 9),
        const SizedBox(height: 18),
        const InfoBanner(
          icon: Icons.auto_awesome,
          text: 'Tes erreurs montrent ce que tu apprends. Continue !',
          color: Color(0xFFFFF2D5),
        ),
      ],
    ),
  );

  Widget _historyTile(String title, String date, bool correct) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(17),
    child: InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: () {
        _isCorrect = correct;
        _navigate(SabiScreen.correction);
      },
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              correct ? Icons.check_circle_outline : Icons.refresh_rounded,
              color: correct ? forest : terra,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    date,
                    style: const TextStyle(fontSize: 12, color: muted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: muted),
          ],
        ),
      ),
    ),
  );

  Widget _offline() => _studentScaffold(
    title: 'Hors ligne',
    back: true,
    body: ListView(
      padding: const EdgeInsets.fromLTRB(18, 7, 18, 24),
      children: [
        InfoBanner(
          icon: Icons.wifi_off_rounded,
          text: _isOnline
              ? 'Tu peux préparer tes leçons hors ligne.'
              : 'Mode hors ligne actif.',
          color: const Color(0xFFFFF2D5),
        ),
        const SizedBox(height: 15),
        if (!_isOnline)
          const SizedBox(
            height: 95,
            child: EmptyState(
              icon: Icons.wifi_off_rounded,
              title: 'Pas d’Internet ? Pas de problème.',
              body: 'Tes leçons téléchargées sont sur ton téléphone.',
            ),
          ),
        _sectionTitle('Tes chapitres', 'Parcours', () {
          _navigate(SabiScreen.chapter);
        }),
        const SizedBox(height: 9),
        if (_downloads.isEmpty)
          const EmptyState(
            icon: Icons.cloud_download_outlined,
            title: 'Pas encore de leçon téléchargée',
            body: 'Choisis un chapitre ci-dessous pour commencer.',
          )
        else
          ..._downloads.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _downloadTile(entry.key, entry.value),
            ),
          ),
        _downloadTile(
          'Théorème de Thalès',
          _downloads['Théorème de Thalès'] ?? 0,
        ),
        if (_lowStorage)
          const Padding(
            padding: EdgeInsets.only(top: 9),
            child: InfoBanner(
              icon: Icons.warning_amber_rounded,
              text:
                  'Il reste peu de place. Supprime un chapitre pour continuer.',
              color: Color(0xFFFCE9DE),
            ),
          ),
        const SizedBox(height: 16),
        _whiteCard(
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.sd_storage_outlined, color: forest),
                    SizedBox(width: 9),
                    Text(
                      'Stockage',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Spacer(),
                    Text(
                      '96 Mo / 256 Mo',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                LinearProgressIndicator(
                  value: _lowStorage ? .92 : .38,
                  color: _lowStorage ? terra : forest,
                  backgroundColor: line,
                ),
                const SizedBox(height: 8),
                Text(
                  _lowStorage
                      ? 'Attention, le stockage est presque plein.'
                      : 'Tu as encore de la place.',
                  style: TextStyle(
                    fontSize: 12,
                    color: _lowStorage ? terra : forest,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 13),
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          value: _dataSaver,
          activeThumbColor: forest,
          title: const Text(
            'Économiser mes données',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: const Text(
            'Télécharger seulement en Wi-Fi',
            style: TextStyle(fontSize: 12),
          ),
          onChanged: (value) => setState(() => _dataSaver = value),
        ),
        TextButton.icon(
          onPressed: () => setState(() => _lowStorage = !_lowStorage),
          icon: const Icon(Icons.sd_storage_outlined),
          label: Text(
            _lowStorage
                ? 'Le stockage est libéré'
                : 'Simuler un manque de place',
          ),
        ),
        const SizedBox(height: 11),
        _whiteCard(
          const Padding(
            padding: EdgeInsets.all(15),
            child: Row(
              children: [
                Icon(Icons.outbox_rounded, color: terra),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Questions traitées hors ligne',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'Les réponses viennent des leçons de l’application.',
                        style: TextStyle(fontSize: 12, color: muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 13),
        PrimaryButton(
          label: 'Vérifier le mode hors ligne',
          icon: Icons.wifi_off_rounded,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Mode hors ligne actif. Rien n’est envoyé.'),
                backgroundColor: forest,
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        const Text(
          'La synchronisation sera ajoutée dans une prochaine version.',
          textAlign: TextAlign.center,
          style: TextStyle(color: muted, fontSize: 12),
        ),
      ],
    ),
  );

  Widget _downloadTile(String title, double progress) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
    ),
    padding: const EdgeInsets.fromLTRB(14, 11, 6, 9),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 19,
          backgroundColor: paleGreen,
          child: Icon(Icons.menu_book_rounded, color: forest, size: 19),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              Text(
                progress == 0
                    ? '15 Mo • pas téléchargé'
                    : progress == 1
                    ? '18 Mo • téléchargé'
                    : '12 Mo • ${(_pausedDownloads[title] ?? false) ? 'en pause' : 'téléchargement'}',
                style: const TextStyle(fontSize: 11, color: muted),
              ),
              if (progress > 0 && progress < 1) ...[
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: (_pausedDownloads[title] ?? false)
                      ? progress
                      : math.min(1, progress + .1),
                  minHeight: 5,
                  backgroundColor: line,
                  color: forest,
                ),
              ],
            ],
          ),
        ),
        if (progress == 0)
          IconButton(
            tooltip: 'Télécharger $title',
            onPressed: () {
              if (_lowStorage) {
                _showToast('Libère de la place avant le téléchargement.');
                return;
              }
              setState(() => _downloads[title] = 1);
            },
            icon: const Icon(Icons.download_rounded, color: forest),
          )
        else
          PopupMenuButton<String>(
            tooltip: 'Gérer $title',
            onSelected: (action) {
              setState(() {
                if (action == 'pause') {
                  _pausedDownloads[title] = !(_pausedDownloads[title] ?? false);
                } else {
                  _downloads.remove(title);
                  _pausedDownloads.remove(title);
                }
              });
              _showToast(
                action == 'pause'
                    ? 'Téléchargement mis à jour.'
                    : 'Chapitre supprimé du téléphone.',
              );
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'pause',
                child: Text(
                  (_pausedDownloads[title] ?? false)
                      ? 'Reprendre'
                      : 'Mettre en pause',
                ),
              ),
              const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
            ],
            icon: const Icon(Icons.more_vert, color: muted),
          ),
      ],
    ),
  );

  Widget _profile() => _studentScaffold(
    title: 'Mon profil',
    root: true,
    body: ListView(
      padding: const EdgeInsets.fromLTRB(18, 9, 18, 26),
      children: [
        _whiteCard(
          Padding(
            padding: const EdgeInsets.all(19),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: paleGreen,
                  child: OwlAvatar(size: 51),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _studentId,
                        style: const TextStyle(
                          color: forestDark,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        'Élève de Troisième',
                        style: TextStyle(color: muted),
                      ),
                      const SizedBox(height: 5),
                      const MiniPill(
                        label: 'Niveau explorateur',
                        color: Color(0xFFFFF2D5),
                        textColor: Color(0xFF684700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _profileRow(Icons.download_outlined, 'Mes téléchargements', () {
          _navigate(SabiScreen.offline);
        }),
        _profileRow(Icons.tune_rounded, 'Paramètres', () {
          _navigate(SabiScreen.settings);
        }),
        _profileRow(Icons.lock_outline, 'Confidentialité', () {
          _navigate(SabiScreen.privacy);
        }),
        _profileRow(Icons.help_outline_rounded, 'Aide et signalement', () {
          _navigate(SabiScreen.help);
        }),
        _profileRow(Icons.route_outlined, 'Voir les parcours de Sabi', () {
          _navigate(SabiScreen.flowMap);
        }),
        _profileRow(Icons.school_outlined, 'Espace enseignant', () {
          _navigate(SabiScreen.teacherLogin);
        }),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _confirmSignOut,
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Se déconnecter'),
          style: OutlinedButton.styleFrom(
            foregroundColor: terra,
            side: const BorderSide(color: terra),
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _profileRow(IconData icon, String label, VoidCallback action) =>
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          child: ListTile(
            minTileHeight: 56,
            leading: Icon(icon, color: forest),
            title: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            trailing: const Icon(Icons.chevron_right, color: muted),
            onTap: action,
          ),
        ),
      );

  Future<void> _confirmSignOut() => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Tu veux te déconnecter ?'),
      content: const Text('Ton parcours sera gardé sur ce téléphone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Rester'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            _replace(SabiScreen.auth);
          },
          child: const Text('Me déconnecter'),
        ),
      ],
    ),
  );

  Widget _settings() => _studentScaffold(
    title: 'Paramètres',
    back: true,
    body: ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 25),
      children: [
        const Text(
          'À ta façon',
          style: TextStyle(color: forest, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        SwitchListTile(
          value: _audioEnabled,
          activeThumbColor: forest,
          secondary: const Icon(Icons.volume_up_outlined, color: forest),
          title: const Text('Explications audio'),
          subtitle: const Text(
            'Écoute les leçons à voix haute',
            style: TextStyle(fontSize: 12),
          ),
          onChanged: (value) => setState(() => _audioEnabled = value),
        ),
        SwitchListTile(
          value: _largeText,
          activeThumbColor: forest,
          secondary: const Icon(Icons.format_size_rounded, color: forest),
          title: const Text('Texte plus grand'),
          subtitle: const Text(
            'Plus facile à lire',
            style: TextStyle(fontSize: 12),
          ),
          onChanged: (value) => setState(() => _largeText = value),
        ),
        SwitchListTile(
          value: _dataSaver,
          activeThumbColor: forest,
          secondary: const Icon(Icons.data_saver_on_rounded, color: forest),
          title: const Text('Économiseur de données'),
          subtitle: const Text(
            'Télécharger seulement en Wi-Fi',
            style: TextStyle(fontSize: 12),
          ),
          onChanged: (value) => setState(() => _dataSaver = value),
        ),
        const SizedBox(height: 8),
        _whiteCard(
          ListTile(
            leading: const Icon(Icons.language_rounded, color: forest),
            title: const Text('Langue'),
            subtitle: const Text('Français facile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showChoice('Langue', [
              'Français facile',
              'Français',
              'English',
            ]),
          ),
        ),
        const SizedBox(height: 18),
        const InfoBanner(
          icon: Icons.accessibility_new_rounded,
          text: 'Tu peux changer ces réglages quand tu veux.',
          color: paleGreen,
        ),
      ],
    ),
  );

  Widget _privacy() => _studentScaffold(
    title: 'Ta confidentialité',
    back: true,
    body: ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      children: [
        const OwlTip(text: 'Tes informations restent à toi. Voici comment.'),
        const SizedBox(height: 14),
        _privacyCard(
          Icons.badge_outlined,
          'Ton petit identifiant',
          'Sabi utilise ton code, pas ton nom complet ni ton adresse.',
        ),
        _privacyCard(
          Icons.visibility_off_outlined,
          'Aucune note publique',
          'Tes réponses et tes progrès ne sont jamais publiés.',
        ),
        _privacyCard(
          Icons.school_outlined,
          'Ce que voit ton enseignant',
          'Les notions que tu travailles et tes besoins d’aide, jamais tes conversations privées.',
        ),
        _privacyCard(
          Icons.shield_outlined,
          'Ta famille sait',
          'Un parent ou tuteur a donné son accord avant ton inscription.',
        ),
        const SizedBox(height: 13),
        _whiteCard(
          const ListTile(
            leading: Icon(Icons.check_circle_outline, color: forest),
            title: Text(
              'Autorisation enregistrée',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text('Parent ou tuteur • à la création du compte'),
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () => _navigate(SabiScreen.help),
          icon: const Icon(Icons.help_outline),
          label: const Text('Une question ?'),
        ),
      ],
    ),
  );

  Widget _privacyCard(IconData icon, String title, String body) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: _whiteCard(
      Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: forest),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: const TextStyle(color: muted, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _help() => _studentScaffold(
    title: 'Aide',
    back: true,
    body: ListView(
      padding: const EdgeInsets.fromLTRB(18, 7, 18, 25),
      children: [
        const OwlTip(text: 'Une question ? On est là pour t’aider.'),
        const SizedBox(height: 13),
        _faq(
          'Puis-je apprendre sans Internet ?',
          'Oui ! Télécharge les chapitres à l’avance dans « Hors ligne ». '
              'Tes progrès seront synchronisés quand le réseau reviendra.',
        ),
        _faq(
          'Sabi remplace-t-il mon professeur ?',
          'Non. Sabi t’aide à t’entraîner et à comprendre. Ton enseignant '
              'reste là pour t’accompagner.',
        ),
        _faq(
          'Que faire si une réponse semble fausse ?',
          'Appuie sur « Signaler une erreur ». Un enseignant vérifiera le contenu.',
        ),
        _faq(
          'Mes conversations restent-elles privées ?',
          'Oui. Elles ne sont pas montrées à ton enseignant. Seuls tes progrès '
              'par compétence sont partagés pour mieux t’aider.',
        ),
        const SizedBox(height: 15),
        SecondaryButton(
          label: 'Signaler une erreur de contenu',
          icon: Icons.flag_outlined,
          onPressed: _reportTutorError,
        ),
        const SizedBox(height: 10),
        _whiteCard(
          ListTile(
            leading: const Icon(Icons.chat_bubble_outline, color: forest),
            title: const Text('Proposer une idée'),
            subtitle: const Text('Aide-nous à améliorer Sabi'),
            onTap: () => _showToast('Merci pour ton idée !'),
          ),
        ),
      ],
    ),
  );

  Widget _faq(String question, String answer) => Card(
    child: ExpansionTile(
      leading: const Icon(Icons.help_outline, color: forest),
      title: Text(
        question,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      ),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 15),
      children: [Text(answer, style: const TextStyle(color: muted))],
    ),
  );

  Widget _notifications() => _studentScaffold(
    title: 'Notifications',
    back: true,
    body: ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      children: [
        _notificationTile(
          Icons.wb_sunny_outlined,
          yellow,
          'Un petit rappel',
          'Il te reste un exercice pour ton objectif du jour.',
          'Aujourd’hui • 09:00',
        ),
        _notificationTile(
          Icons.auto_awesome,
          forest,
          'Un nouveau chapitre t’attend',
          'Découvre le théorème de Thalès à ton rythme.',
          'Hier',
        ),
        _notificationTile(
          Icons.chat_bubble_outline,
          terra,
          'Ton enseignant a un message',
          '« Bravo pour tes progrès cette semaine ! »',
          'Lundi',
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => _showToast('Tout est lu !'),
          icon: const Icon(Icons.done_all_rounded),
          label: const Text('Tout marquer comme lu'),
          style: OutlinedButton.styleFrom(
            foregroundColor: forest,
            minimumSize: const Size.fromHeight(51),
          ),
        ),
      ],
    ),
  );

  Widget _notificationTile(
    IconData icon,
    Color color,
    String title,
    String body,
    String date,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: () => _navigate(SabiScreen.home),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: const Color(0xFFF5F1EA),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 3),
                    Text(body, style: const TextStyle(color: muted)),
                    const SizedBox(height: 6),
                    Text(
                      date,
                      style: const TextStyle(fontSize: 11, color: muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _teacherLogin() => _entryScaffold(
    title: 'Espace enseignant',
    subtitle: 'Ensemble, chaque élève peut avancer.',
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(child: OwlAvatar(size: 83)),
        const SizedBox(height: 14),
        const FieldLabel(label: 'Identifiant ou e-mail'),
        const SizedBox(height: 7),
        TextField(
          decoration: _inputDecoration(
            'professeur@ecole.cm',
            Icons.person_outline,
          ),
        ),
        const SizedBox(height: 16),
        const FieldLabel(label: 'Mot de passe'),
        const SizedBox(height: 7),
        TextField(
          obscureText: true,
          decoration: _inputDecoration('Ton mot de passe', Icons.lock_outline),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => _showToast('Demande de réinitialisation envoyée.'),
          child: const Text('Mot de passe oublié ?'),
        ),
        const SizedBox(height: 4),
        PrimaryButton(
          label: 'Se connecter',
          onPressed: () => _navigate(
            _studentAdded ? SabiScreen.dashboard : SabiScreen.classSetup,
          ),
        ),
        const SizedBox(height: 9),
        TextButton(
          onPressed: () => _navigate(SabiScreen.classSetup),
          child: const Text('Créer ma première classe'),
        ),
        const SizedBox(height: 12),
        const InfoBanner(
          icon: Icons.visibility_outlined,
          text:
              'Les conversations privées des élèves ne sont jamais affichées.',
          color: paleGreen,
        ),
      ],
    ),
  );

  Widget _classSetup() => _teacherScaffold(
    title: 'Créer une classe',
    active: SabiScreen.dashboard,
    body: ListView(
      padding: const EdgeInsets.all(25),
      children: [
        const Text(
          'On commence ensemble',
          style: TextStyle(
            color: forest,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Quelques détails pour préparer ton espace.',
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 24),
        const FieldLabel(label: 'Nom de la classe'),
        const SizedBox(height: 7),
        TextField(
          decoration: _inputDecoration('Ex. Troisième A', Icons.class_outlined),
        ),
        const SizedBox(height: 18),
        const FieldLabel(label: 'Niveau'),
        const SizedBox(height: 7),
        _dropdown('Troisième', ['Troisième', 'Quatrième', 'Seconde'], (_) {}),
        const SizedBox(height: 18),
        const FieldLabel(label: 'Matière'),
        const SizedBox(height: 7),
        _dropdown('Mathématiques', ['Mathématiques', 'Sciences'], (_) {}),
        const SizedBox(height: 22),
        _whiteCard(
          Padding(
            padding: const EdgeInsets.all(17),
            child: Row(
              children: [
                const Icon(Icons.share_outlined, color: forest, size: 28),
                const SizedBox(width: 11),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Code à partager',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'SABI-3E24',
                        style: TextStyle(
                          color: forest,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Tes élèves l’entrent dans leur profil.',
                        style: TextStyle(color: muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Copier le code de classe',
                  onPressed: () =>
                      _showToast('Code de classe copié : SABI-3E24'),
                  icon: const Icon(Icons.copy_rounded, color: forest),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: 'Créer ma classe',
          onPressed: () {
            setState(() => _studentAdded = true);
            _navigate(SabiScreen.dashboard);
          },
        ),
      ],
    ),
  );

  Widget _dashboard() => _teacherScaffold(
    title: 'Vue d’ensemble',
    active: SabiScreen.dashboard,
    body: ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjour, enseignant·e !',
                    style: TextStyle(
                      fontSize: 25,
                      color: forestDark,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Voici comment progresse ta classe.',
                    style: TextStyle(color: muted, fontSize: 15),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _navigate(SabiScreen.remediation),
              icon: const Icon(Icons.add),
              label: const Text('Planifier une remédiation'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final count = constraints.maxWidth > 900 ? 4 : 2;
            final width = (constraints.maxWidth - ((count - 1) * 11)) / count;
            return Wrap(
              spacing: 11,
              runSpacing: 11,
              children: [
                SizedBox(
                  width: width,
                  child: _kpi(
                    'Élèves',
                    '32',
                    'dans ta classe',
                    Icons.groups_rounded,
                    forest,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _kpi(
                    'Niveau moyen',
                    '68 %',
                    '+ 6 % ce mois',
                    Icons.trending_up_rounded,
                    const Color(0xFF587D43),
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _kpi(
                    'Actifs cette semaine',
                    '24',
                    'sur 32 élèves',
                    Icons.calendar_today_rounded,
                    const Color(0xFF856411),
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _kpi(
                    'Usage hors ligne',
                    '41 %',
                    'cette semaine',
                    Icons.wifi_off_rounded,
                    terra,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 850;
            final notions = _whiteCard(
              Padding(
                padding: const EdgeInsets.all(19),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notions à reprendre ensemble',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'Les 3 points qui demandent le plus d’attention.',
                      style: TextStyle(color: muted),
                    ),
                    const SizedBox(height: 10),
                    _difficultyRow('Identités remarquables', 62, terra),
                    _difficultyRow(
                      'Équations du premier degré',
                      38,
                      const Color(0xFFBB8316),
                    ),
                    _difficultyRow('Théorème de Thalès', 24, forest),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => _navigate(SabiScreen.skills),
                      child: const Text('Voir toutes les compétences →'),
                    ),
                  ],
                ),
              ),
            );
            final activity = _whiteCard(
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cette semaine',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'Une classe qui persévère !',
                      style: TextStyle(color: muted),
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(height: 124, child: WeeklyChart()),
                    const Text(
                      'Les élèves travaillent aussi hors connexion.',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: notions),
                  const SizedBox(width: 13),
                  Expanded(flex: 4, child: activity),
                ],
              );
            }
            return Column(
              children: [notions, const SizedBox(height: 13), activity],
            );
          },
        ),
        const SizedBox(height: 18),
        _whiteCard(
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Tes élèves',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _navigate(SabiScreen.students),
                      child: const Text('Voir la classe →'),
                    ),
                  ],
                ),
                const StudentRow(
                  initials: 'AN',
                  name: 'Élève AN-24',
                  details: 'Factorisation • en progrès',
                  percent: .78,
                  color: forest,
                ),
                const Divider(height: 18),
                const StudentRow(
                  initials: 'KM',
                  name: 'Élève KM-18',
                  details: 'Équations • à renforcer',
                  percent: .44,
                  color: terra,
                ),
                const Divider(height: 18),
                const StudentRow(
                  initials: 'FD',
                  name: 'Élève FD-07',
                  details: 'Thalès • maîtrise',
                  percent: .91,
                  color: forest,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _kpi(
    String label,
    String value,
    String note,
    IconData icon,
    Color color,
  ) => _whiteCard(
    Padding(
      padding: const EdgeInsets.all(17),
      child: Row(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: const Color(0xFFF2EEE6),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: muted, fontSize: 12)),
                Text(
                  value,
                  style: const TextStyle(
                    color: forestDark,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(note, style: const TextStyle(color: muted, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _difficultyRow(String name, int percent, Color color) => InkWell(
    onTap: () {
      _selectedChapter = name;
      _navigate(SabiScreen.skills);
    },
    borderRadius: BorderRadius.circular(10),
    child: Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percent / 100,
                minHeight: 8,
                backgroundColor: line,
                color: color,
              ),
            ),
          ),
          SizedBox(
            width: 55,
            child: Text(
              '$percent %',
              textAlign: TextAlign.end,
              style: TextStyle(color: color, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _skills() => _teacherScaffold(
    title: 'Compétences',
    active: SabiScreen.skills,
    body: ListView(
      padding: const EdgeInsets.fromLTRB(24, 15, 24, 26),
      children: [
        const Text(
          'Carte de la classe',
          style: TextStyle(
            fontSize: 25,
            color: forestDark,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Chaque case montre un besoin de la classe, pas une note individuelle.',
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 14,
          runSpacing: 8,
          children: const [
            LegendDot(color: forest, label: 'Maîtrisé'),
            LegendDot(color: yellow, label: 'En progrès'),
            LegendDot(color: terra, label: 'À renforcer'),
          ],
        ),
        const SizedBox(height: 15),
        _whiteCard(
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 22,
              headingRowColor: WidgetStateProperty.all(paleGreen),
              columns: [
                const DataColumn(label: Text('Élève')),
                DataColumn(
                  label: _skillHeader('Factorisation', 'Factorisation'),
                ),
                DataColumn(label: _skillHeader('Équations', 'Équations')),
                DataColumn(label: _skillHeader('Thalès', 'Théorème de Thalès')),
              ],
              rows: [
                _heatRow('AN-24', [forest, yellow, terra]),
                _heatRow('KM-18', [terra, yellow, yellow]),
                _heatRow('FD-07', [forest, forest, forest]),
                _heatRow('LT-12', [yellow, terra, yellow]),
                _heatRow('EB-03', [forest, terra, terra]),
                _heatRow('NJ-19', [yellow, forest, forest]),
                _heatRow('... 26 élèves', [line, line, line]),
              ],
            ),
          ),
        ),
        const SizedBox(height: 11),
        const InfoBanner(
          icon: Icons.shield_outlined,
          text: 'Les conversations privées ne sont pas montrées ici.',
          color: paleGreen,
        ),
        const SizedBox(height: 10),
        PrimaryButton(
          label: 'Planifier une remédiation',
          onPressed: () => _navigate(SabiScreen.remediation),
        ),
      ],
    ),
  );

  DataRow _heatRow(String id, List<Color> colors) => DataRow(
    cells: [
      DataCell(
        TextButton(
          onPressed: () => _navigate(SabiScreen.studentDetail),
          child: Text(
            id,
            style: const TextStyle(color: forest, fontWeight: FontWeight.w800),
          ),
        ),
      ),
      ...List.generate(
        colors.length,
        (index) => DataCell(
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              if (colors[index] == terra) {
                setState(() => _studentFilter = 'À soutenir');
                _navigate(SabiScreen.students);
              } else {
                _navigate(SabiScreen.studentDetail);
              }
            },
            child: Container(
              width: 31,
              height: 29,
              decoration: BoxDecoration(
                color: colors[index].withValues(alpha: .22),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors[index].withValues(alpha: .6)),
              ),
              child: Center(
                child: Icon(Icons.circle, size: 10, color: colors[index]),
              ),
            ),
          ),
        ),
      ),
    ],
  );

  Widget _skillHeader(String title, String chapter) => InkWell(
    onTap: () {
      _selectedChapter = chapter;
      _navigate(SabiScreen.remediation);
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(color: forestDark, fontWeight: FontWeight.w900),
      ),
    ),
  );

  Widget _students() {
    const students = [
      (
        id: 'AN-24',
        detail: 'Factorisation • en progrès',
        progress: .78,
        needsHelp: false,
        offline: false,
      ),
      (
        id: 'KM-18',
        detail: 'Équations • à renforcer',
        progress: .44,
        needsHelp: true,
        offline: false,
      ),
      (
        id: 'FD-07',
        detail: 'Thalès • maîtrisé',
        progress: .91,
        needsHelp: false,
        offline: false,
      ),
      (
        id: 'LT-12',
        detail: 'Identités remarquables • à soutenir',
        progress: .52,
        needsHelp: true,
        offline: true,
      ),
      (
        id: 'EB-03',
        detail: 'Équations • en progrès',
        progress: .62,
        needsHelp: false,
        offline: true,
      ),
      (
        id: 'NJ-19',
        detail: 'Factorisation • maîtrise',
        progress: .86,
        needsHelp: false,
        offline: true,
      ),
    ];
    final visible = students.where((student) {
      final matchesFilter =
          _studentFilter == 'Toute la classe' ||
          (_studentFilter == 'À soutenir' && student.needsHelp) ||
          (_studentFilter == 'Hors ligne' && student.offline);
      return matchesFilter &&
          ('${student.id} ${student.detail}').toLowerCase().contains(
            _studentSearch.toLowerCase(),
          );
    }).toList();
    return _teacherScaffold(
      title: 'Élèves',
      active: SabiScreen.students,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 15, 24, 24),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Ta classe, à l’écoute',
                  style: TextStyle(
                    fontSize: 24,
                    color: forestDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(
                width: 230,
                child: TextField(
                  decoration: _inputDecoration(
                    'Chercher un élève',
                    Icons.search,
                  ).copyWith(isDense: true),
                  onChanged: (value) => setState(() => _studentSearch = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 7,
            children: ['Toute la classe', 'À soutenir', 'Hors ligne']
                .map(
                  (filter) => FilterChip(
                    label: Text(filter),
                    selected: _studentFilter == filter,
                    onSelected: (_) => setState(() => _studentFilter = filter),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 13),
          _whiteCard(
            Column(
              children: List.generate(
                visible.length,
                (index) => Column(
                  children: [
                    if (index > 0) const Divider(height: 1),
                    _teacherStudentRow(
                      visible[index].id,
                      visible[index].detail,
                      visible[index].progress,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 11),
          const InfoBanner(
            icon: Icons.visibility_outlined,
            text:
                'Tu vois les notions travaillées, jamais les conversations privées.',
            color: paleGreen,
          ),
        ],
      ),
    );
  }

  Widget _teacherStudentRow(String id, String detail, double progress) =>
      ListTile(
        onTap: () => _navigate(SabiScreen.studentDetail),
        leading: CircleAvatar(
          backgroundColor: progress < .55 ? const Color(0xFFFCE9DE) : paleGreen,
          child: Text(
            id.substring(0, 1),
            style: const TextStyle(color: forest, fontWeight: FontWeight.w900),
          ),
        ),
        title: Text(
          'Élève $id',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(detail),
        trailing: const Icon(Icons.chevron_right, color: muted),
      );

  Widget _studentDetail() => _teacherScaffold(
    title: 'Profil de progression',
    active: SabiScreen.students,
    body: ListView(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 26),
      children: [
        _whiteCard(
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: paleGreen,
                  child: Text(
                    'AN',
                    style: TextStyle(
                      color: forest,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Élève AN-24',
                        style: TextStyle(
                          fontSize: 19,
                          color: forestDark,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Troisième A • Active cette semaine',
                        style: TextStyle(color: muted),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _navigate(SabiScreen.remediation),
                  icon: const Icon(Icons.group_add_outlined),
                  label: const Text('Ajouter à une séance'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        const InfoBanner(
          icon: Icons.lock_outline,
          text: 'Conversations privées non affichées.',
          color: paleGreen,
        ),
        const SizedBox(height: 17),
        const Text(
          'Ses points à soutenir',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 9),
        _whiteCard(
          Column(
            children: const [
              SkillProgressRow(
                name: 'Identités remarquables',
                status: 'À renforcer',
                percent: .38,
                color: terra,
              ),
              Divider(height: 1),
              SkillProgressRow(
                name: 'Factorisation',
                status: 'En progrès',
                percent: .62,
                color: Color(0xFFBB8316),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'Ses progrès cette semaine',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        _whiteCard(
          const Padding(
            padding: EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MiniStat(label: 'Leçons', value: '4'),
                MiniStat(label: 'Temps', value: '35 min'),
                MiniStat(label: 'Hors ligne', value: '2 jours'),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _remediation() => _teacherScaffold(
    title: 'Préparer une séance',
    active: SabiScreen.remediation,
    body: ListView(
      padding: const EdgeInsets.fromLTRB(24, 15, 24, 27),
      children: [
        const Text(
          'Un petit coup de pouce ciblé',
          style: TextStyle(
            color: forestDark,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Sabi t’aide à rassembler les élèves qui en ont besoin.',
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 15),
        _whiteCard(
          Padding(
            padding: const EdgeInsets.all(17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FieldLabel(label: 'Notion à retravailler'),
                const SizedBox(height: 7),
                _dropdown(
                  _selectedChapter,
                  [
                    'Factorisation',
                    'Identités remarquables',
                    'Équations du premier degré',
                    'Théorème de Thalès',
                  ],
                  (value) => setState(() => _selectedChapter = value),
                ),
                const SizedBox(height: 15),
                InfoBanner(
                  icon: Icons.groups_rounded,
                  text: '8 élèves à aider sur $_selectedChapter.',
                  color: const Color(0xFFFFF2D5),
                ),
                const SizedBox(height: 13),
                const FieldLabel(label: 'Date et heure'),
                const SizedBox(height: 6),
                TextField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: 'Jeudi 14 novembre • 10 h 00',
                  ),
                  decoration: _inputDecoration(
                    'Choisir un moment',
                    Icons.calendar_today_outlined,
                  ),
                  onTap: () => _pickDate(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 13),
        const Text(
          'Des exercices pour démarrer',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        _exerciseSuggestion('Repérer le facteur commun', 'Facile • 5 min'),
        const SizedBox(height: 8),
        _exerciseSuggestion('Identité remarquable a² − b²', 'Moyen • 8 min'),
        const SizedBox(height: 8),
        _exerciseSuggestion('Factoriser puis résoudre', 'Pour aller plus loin'),
        const SizedBox(height: 19),
        PrimaryButton(label: 'Créer la séance', onPressed: _createSession),
      ],
    ),
  );

  Widget _exerciseSuggestion(String title, String detail) => CheckboxListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 11),
    tileColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    activeColor: forest,
    value: _selectedExercises.contains(title),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
    subtitle: Text(detail),
    onChanged: (selected) {
      setState(() {
        if (selected == true) {
          _selectedExercises.add(title);
        } else {
          _selectedExercises.remove(title);
        }
      });
    },
  );

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2026, 11, 14),
      firstDate: DateTime(2026),
      lastDate: DateTime(2027, 12),
      locale: const Locale('fr'),
    );
    if (date != null) {
      _showToast('Séance prévue le ${date.day}/${date.month}/${date.year}.');
    }
  }

  Future<void> _createSession() => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.check_circle_rounded, color: forest, size: 40),
      title: const Text('Séance créée !'),
      content: Text(
        'Les ${_selectedExercises.length} exercices sont prêts pour tes élèves. '
        'Tu peux modifier la séance quand tu veux.',
      ),
      actions: [
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            _navigate(SabiScreen.dashboard);
          },
          child: const Text('Terminé'),
        ),
      ],
    ),
  );

  Widget _reports() => _teacherScaffold(
    title: 'Rapports',
    active: SabiScreen.reports,
    body: ListView(
      padding: const EdgeInsets.fromLTRB(24, 15, 24, 25),
      children: [
        const Text(
          'Un regard sur la classe',
          style: TextStyle(
            color: forestDark,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Des repères utiles pour mieux accompagner les élèves.',
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 9,
          runSpacing: 8,
          children: [
            SizedBox(
              width: 190,
              child: _dropdown(_reportRange, [
                'Cette semaine',
                'Ce mois',
                'Ce trimestre',
              ], (value) => setState(() => _reportRange = value)),
            ),
            SizedBox(
              width: 190,
              child: _dropdown(_reportGroup, [
                'Toute la classe',
                'Élèves actifs',
              ], (value) => setState(() => _reportGroup = value)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _whiteCard(
          Padding(
            padding: const EdgeInsets.all(19),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Résumé de classe',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 19,
                    color: forestDark,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Troisième A • 32 élèves • $_reportRange',
                  style: const TextStyle(color: muted),
                ),
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MiniStat(label: 'Actifs', value: '24 / 32'),
                    MiniStat(label: 'Leçons', value: '86'),
                    MiniStat(label: 'En progrès', value: '+ 6 %'),
                  ],
                ),
                const SizedBox(height: 17),
                const Divider(),
                const SizedBox(height: 5),
                const Text(
                  'À retenir',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Les élèves ont le plus travaillé la factorisation. '
                  'Huit élèves gagneraient à revoir la différence de deux carrés.',
                ),
                const SizedBox(height: 12),
                const Text(
                  'Prochaine étape conseillée',
                  style: TextStyle(color: forest, fontWeight: FontWeight.w800),
                ),
                const Text('Une séance courte sur les identités remarquables.'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 10,
          runSpacing: 9,
          children: [
            FilledButton.icon(
              onPressed: () => _export('PDF'),
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('Exporter PDF'),
            ),
            OutlinedButton.icon(
              onPressed: () => _export('CSV'),
              icon: const Icon(Icons.table_chart_outlined),
              label: const Text('Exporter CSV'),
            ),
          ],
        ),
      ],
    ),
  );

  void _export(String type) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Rapport $type prêt à être téléchargé.'),
      backgroundColor: forest,
    ),
  );

  Widget _content() => _teacherScaffold(
    title: 'Contenus',
    active: SabiScreen.content,
    body: ListView(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
      children: [
        const Text(
          'Des leçons vérifiées',
          style: TextStyle(
            color: forestDark,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Chaque contenu est relu avant d’être proposé aux élèves.',
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 13),
        Wrap(
          spacing: 8,
          children: ['Tous', 'Leçons', 'Exercices']
              .map(
                (filter) => FilterChip(
                  label: Text(filter),
                  selected: _contentFilter == filter,
                  onSelected: (_) => setState(() => _contentFilter = filter),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        if (_contentFilter != 'Exercices')
          _contentRow('Factoriser avec a² − b²', 'Leçon • Facile', 'Troisième'),
        if (_contentFilter == 'Tous') const SizedBox(height: 8),
        if (_contentFilter != 'Leçons')
          _contentRow(
            'Résoudre une équation-produit',
            'Exercice • Moyen',
            'Troisième',
          ),
        if (_contentFilter == 'Tous') const SizedBox(height: 8),
        if (_contentFilter != 'Exercices')
          _contentRow(
            'Le théorème de Thalès',
            'Leçon • Intermédiaire',
            'Troisième',
          ),
        if (_contentFilter == 'Tous') const SizedBox(height: 8),
        if (_contentFilter != 'Leçons')
          _contentRow('Développer (a + b)²', 'Exercice • Facile', 'Troisième'),
        const SizedBox(height: 12),
        const InfoBanner(
          icon: Icons.offline_pin_outlined,
          text:
              'Ces leçons peuvent être téléchargées pour un usage hors ligne.',
          color: paleGreen,
        ),
      ],
    ),
  );

  Widget _contentRow(String title, String detail, String level) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    child: ListTile(
      onTap: () => _navigate(SabiScreen.contentDetail),
      leading: const CircleAvatar(
        backgroundColor: paleGreen,
        child: Icon(Icons.menu_book_outlined, color: forest),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text('$detail • $level'),
      trailing: const Icon(Icons.chevron_right, color: muted),
    ),
  );

  Widget _contentDetail() => _teacherScaffold(
    title: 'Détail du contenu',
    active: SabiScreen.content,
    body: ListView(
      padding: const EdgeInsets.fromLTRB(25, 18, 25, 26),
      children: [
        const MiniPill(
          label: 'LEÇON • FACILE',
          color: paleGreen,
          textColor: forest,
        ),
        const SizedBox(height: 11),
        const Text(
          'Factoriser avec a² − b²',
          style: TextStyle(
            color: forestDark,
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Compétence : reconnaître une différence de deux carrés',
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 17),
        _whiteCard(
          const Padding(
            padding: EdgeInsets.all(19),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explication',
                  style: TextStyle(
                    color: forest,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Pour tous nombres a et b, la différence de leurs carrés se '
                  'factorise ainsi : a² − b² = (a − b)(a + b).',
                ),
                SizedBox(height: 13),
                Text('Exemple', style: TextStyle(fontWeight: FontWeight.w900)),
                Text('x² − 16 = x² − 4² = (x − 4)(x + 4)'),
                SizedBox(height: 13),
                Text(
                  'Source : Programme officiel de mathématiques • Troisième',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
                Text(
                  'Vérifié par : Mme Ngo • Enseignante',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        SecondaryButton(
          label: 'Signaler une erreur',
          icon: Icons.flag_outlined,
          onPressed: _reportContentError,
        ),
      ],
    ),
  );

  Future<void> _reportContentError() => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Signaler une erreur'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Qu’est-ce qui devrait être vérifié ?'),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: 'Une formule',
            items: const [
              DropdownMenuItem(
                value: 'Une formule',
                child: Text('Une formule'),
              ),
              DropdownMenuItem(value: 'Une étape', child: Text('Une étape')),
              DropdownMenuItem(
                value: 'Une explication',
                child: Text('Une explication'),
              ),
            ],
            onChanged: (value) => setState(() => _reportReason = value),
          ),
          const SizedBox(height: 8),
          const TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Un détail utile (facultatif)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            _showToast('Merci ! Le contenu sera vérifié.');
          },
          child: const Text('Envoyer'),
        ),
      ],
    ),
  );

  Widget _flowMap() => _scaffold(
    title: 'Les parcours de Sabi',
    back: true,
    body: ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 26),
      children: [
        const OwlTip(text: 'Chaque chemin est une nouvelle façon d’avancer.'),
        const SizedBox(height: 14),
        const Text(
          'Parcours élève',
          style: TextStyle(
            color: forest,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 7),
        _flowCard(
          'Début',
          'Bienvenue → Découvrir → Créer mon code',
          SabiScreen.onboarding,
        ),
        _flowCard(
          'Découverte',
          'Autorisation → Petit test → Mon parcours',
          SabiScreen.consent,
        ),
        _flowCard(
          'Apprendre',
          'Accueil → Chapitre → Leçon → Exercice',
          SabiScreen.chapter,
        ),
        _flowCard(
          'Progresser',
          'Correction → Nouvel exercice → Badge',
          SabiScreen.progress,
        ),
        _flowCard(
          'Mon espace',
          'Progrès → Historique → Profil → Réglages',
          SabiScreen.profile,
        ),
        _flowCard(
          'Sans réseau',
          'Télécharger → Apprendre → Synchroniser',
          SabiScreen.offline,
        ),
        _flowCard(
          'Demander de l’aide',
          'Tuteur → Indice → Exercice',
          SabiScreen.tutor,
        ),
        const SizedBox(height: 12),
        const Text(
          'Parcours enseignant',
          style: TextStyle(
            color: forest,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 7),
        _flowCard(
          'Connexion',
          'Espace enseignant → Créer une classe',
          SabiScreen.teacherLogin,
        ),
        _flowCard(
          'Observer',
          'Vue d’ensemble → Compétences → Élève',
          SabiScreen.dashboard,
        ),
        _flowCard(
          'Accompagner',
          'Notion à soutenir → Planifier → Confirmer',
          SabiScreen.remediation,
        ),
        _flowCard(
          'Partager',
          'Rapports → Exporter • Contenus → Signaler',
          SabiScreen.reports,
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Continuer comme élève',
          onPressed: () => _navigate(SabiScreen.home),
        ),
        const SizedBox(height: 8),
        SecondaryButton(
          label: 'Ouvrir l’espace enseignant',
          icon: Icons.school_outlined,
          onPressed: () => _navigate(SabiScreen.teacherLogin),
        ),
      ],
    ),
  );

  Widget _flowCard(String title, String path, SabiScreen destination) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _navigate(destination),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: forest,
                    size: 19,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          path,
                          style: const TextStyle(color: muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: muted),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _entryScaffold({
    required String title,
    required String subtitle,
    required Widget body,
  }) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          _header(title, back: true),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(23, 16, 23, 25),
              children: [
                Text(
                  subtitle,
                  style: const TextStyle(color: muted, fontSize: 15),
                ),
                body,
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _scaffold({
    required String title,
    required Widget body,
    bool back = false,
  }) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          _header(title, back: back),
          Expanded(child: body),
        ],
      ),
    ),
  );

  Widget _studentScaffold({
    required String title,
    required Widget body,
    bool root = false,
    bool back = false,
    Widget? trailing,
    Widget? floating,
  }) => Scaffold(
    floatingActionButton: floating,
    body: SafeArea(
      child: Column(
        children: [
          _header(
            title,
            back: back || (!root && _history.isNotEmpty),
            trailing: trailing,
          ),
          if (!_isOnline && _screen != SabiScreen.offline)
            Material(
              color: const Color(0xFFFFF2D5),
              child: InkWell(
                onTap: () => _navigate(SabiScreen.offline),
                child: SizedBox(
                  height: 37,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          TutorService.isConfigured
                              ? _isAskingTutor || _tutorStatus == null
                                    ? Icons.cloud_queue_rounded
                                    : Icons.wifi_off_rounded
                              : Icons.wifi_off_rounded,
                          size: 16,
                          color: Color(0xFF684700),
                        ),
                        SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            TutorService.isConfigured
                                ? _isAskingTutor
                                      ? 'Connexion à Gemma…'
                                      : _tutorStatus == null
                                      ? 'Gemma à tester • tes leçons restent disponibles'
                                      : 'Gemma indisponible • tes leçons restent disponibles'
                                : 'Hors ligne • tes leçons restent disponibles',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF684700),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Expanded(child: body),
          if (_screen == SabiScreen.tutor) _tutorComposer(),
          if (_isStudentTab) _bottomNav(),
        ],
      ),
    ),
  );

  Widget _tutorComposer() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: _tutorInputController,
            textInputAction: TextInputAction.send,
            onSubmitted: _askTutor,
            decoration: InputDecoration(
              hintText: 'Écris ta question…',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: line),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          tooltip: 'Envoyer la question',
          onPressed: () => _askTutor(_tutorInputController.text),
          icon: const Icon(Icons.send_rounded),
          style: IconButton.styleFrom(
            backgroundColor: forest,
            foregroundColor: Colors.white,
            minimumSize: const Size(54, 54),
          ),
        ),
      ],
    ),
  );

  Widget _teacherScaffold({
    required String title,
    required Widget body,
    required SabiScreen active,
  }) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    if (!wide) {
      return Scaffold(
        drawer: Drawer(
          backgroundColor: paper,
          child: SafeArea(child: _sidebar(active)),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _header(
                title,
                back: active != SabiScreen.dashboard,
                trailing: Builder(
                  builder: (drawerContext) => IconButton(
                    tooltip: 'Menu',
                    onPressed: () => Scaffold.of(drawerContext).openDrawer(),
                    icon: const Icon(Icons.menu),
                  ),
                ),
              ),
              _classSelector(),
              Expanded(child: body),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            SizedBox(width: 232, child: _sidebar(active)),
            Expanded(
              child: Column(
                children: [
                  Container(
                    height: 65,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(bottom: BorderSide(color: line)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: forestDark,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        _classSelector(),
                        const SizedBox(width: 12),
                        _connectionChip(),
                        const SizedBox(width: 5),
                        IconButton(
                          tooltip: 'Voir l’espace élève',
                          onPressed: () => _navigate(SabiScreen.home),
                          icon: const Icon(
                            Icons.phone_android_rounded,
                            color: forest,
                          ),
                        ),
                        PopupMenuButton<String>(
                          tooltip: 'Mon profil',
                          onSelected: (value) {
                            if (value == 'student') {
                              _navigate(SabiScreen.home);
                            } else if (value == 'flow') {
                              _navigate(SabiScreen.flowMap);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'student',
                              child: Text('Voir l’espace élève'),
                            ),
                            PopupMenuItem(
                              value: 'flow',
                              child: Text('Carte des parcours'),
                            ),
                          ],
                          child: const CircleAvatar(
                            radius: 18,
                            backgroundColor: paleGreen,
                            child: Icon(Icons.person, color: forest),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sidebar(SabiScreen active) => Container(
    color: Colors.white,
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(17, 19, 17, 16),
          child: Row(
            children: const [
              OwlAvatar(size: 42),
              SizedBox(width: 10),
              Text(
                'sabi',
                style: TextStyle(
                  color: forest,
                  fontWeight: FontWeight.w900,
                  fontSize: 25,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 7),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'ESPACE ENSEIGNANT',
              style: TextStyle(
                color: muted.withValues(alpha: .8),
                fontSize: 10,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        _sideItem(
          'Vue d’ensemble',
          Icons.space_dashboard_outlined,
          SabiScreen.dashboard,
          active,
        ),
        _sideItem(
          'Compétences',
          Icons.grid_view_rounded,
          SabiScreen.skills,
          active,
        ),
        _sideItem('Élèves', Icons.groups_outlined, SabiScreen.students, active),
        _sideItem(
          'Remédiation',
          Icons.group_add_outlined,
          SabiScreen.remediation,
          active,
        ),
        _sideItem(
          'Rapports',
          Icons.bar_chart_rounded,
          SabiScreen.reports,
          active,
        ),
        _sideItem(
          'Contenus',
          Icons.menu_book_outlined,
          SabiScreen.content,
          active,
        ),
        const Spacer(),
        Container(
          margin: const EdgeInsets.all(13),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: paleGreen,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.favorite_border, color: forest, size: 19),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sabi soutient ton travail, il ne remplace jamais l’enseignant.',
                  style: TextStyle(
                    color: forestDark,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        Material(
          color: Colors.white,
          child: ListTile(
            minTileHeight: 51,
            leading: const Icon(Icons.person_outline, color: forest),
            title: const Text('Mon espace'),
            onTap: () => _navigate(SabiScreen.home),
          ),
        ),
        const SizedBox(height: 8),
      ],
    ),
  );

  Widget _sideItem(
    String label,
    IconData icon,
    SabiScreen destination,
    SabiScreen active,
  ) {
    final selected = destination == active;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: selected ? paleGreen : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          dense: true,
          minTileHeight: 46,
          leading: Icon(icon, color: selected ? forest : muted, size: 20),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
              color: selected ? forest : ink,
            ),
          ),
          onTap: () => _navigate(destination),
        ),
      ),
    );
  }

  Widget _classSelector() => PopupMenuButton<String>(
    tooltip: 'Choisir une classe',
    initialValue: _selectedClass,
    onSelected: (value) => setState(() => _selectedClass = value),
    itemBuilder: (context) => const [
      PopupMenuItem(
        value: '3e A • Lycée de Bonabéri',
        child: Text('3e A • Lycée de Bonabéri'),
      ),
      PopupMenuItem(
        value: '3e B • Lycée de Bonabéri',
        child: Text('3e B • Lycée de Bonabéri'),
      ),
    ],
    child: Container(
      constraints: const BoxConstraints(minHeight: 42),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F1EA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.class_outlined, color: forest, size: 18),
          const SizedBox(width: 7),
          Text(
            _selectedClass,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, size: 18),
        ],
      ),
    ),
  );

  Widget _header(String title, {bool back = false, Widget? trailing}) =>
      Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: const BoxDecoration(
          color: paper,
          border: Border(bottom: BorderSide(color: line, width: .8)),
        ),
        child: Row(
          children: [
            if (back)
              IconButton(
                tooltip: 'Retour',
                onPressed: _back,
                icon: const Icon(Icons.arrow_back_rounded, color: forest),
              )
            else
              const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: forestDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
            ?trailing,
            _connectionChip(),
          ],
        ),
      );

  Widget _connectionChip() {
    final isConfigured = TutorService.isConfigured;
    final color = _isOnline
        ? forest
        : isConfigured
        ? const Color(0xFFC17A14)
        : muted;
    return Padding(
      padding: const EdgeInsets.only(right: 3, left: 8),
      child: Tooltip(
        message: _isOnline
            ? 'Gemma disponible'
            : isConfigured
            ? _isAskingTutor
                  ? 'Connexion à Gemma…'
                  : _tutorStatus == null
                  ? 'Gemma sera testée à la première question'
                  : 'Gemma indisponible'
            : 'Mode local',
        child: Row(
          children: [
            Icon(
              _isOnline
                  ? Icons.circle
                  : isConfigured
                  ? _isAskingTutor
                        ? Icons.cloud_sync_rounded
                        : _tutorStatus == null
                        ? Icons.cloud_queue_rounded
                        : Icons.wifi_off_rounded
                  : Icons.wifi_off_rounded,
              color: color,
              size: 11,
            ),
            const SizedBox(width: 5),
            Text(
              _isOnline
                  ? 'En ligne'
                  : isConfigured
                  ? _isAskingTutor
                        ? 'Connexion…'
                        : _tutorStatus == null
                        ? 'À tester'
                        : 'Erreur'
                  : 'Hors ligne',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomNav() => Container(
    padding: const EdgeInsets.only(top: 6, bottom: 4),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: line)),
    ),
    child: Row(
      children: [
        _navItem('Accueil', Icons.home_rounded, SabiScreen.home),
        _navItem('Tuteur', Icons.chat_bubble_outline, SabiScreen.tutor),
        _navItem('Progrès', Icons.insights_rounded, SabiScreen.progress),
        _navItem('Profil', Icons.person_outline, SabiScreen.profile),
      ],
    ),
  );

  Widget _navItem(String label, IconData icon, SabiScreen destination) {
    final selected = destination == _screen;
    return Expanded(
      child: InkWell(
        onTap: () {
          if (destination == _screen) return;
          setState(() {
            _history.clear();
            _screen = destination;
          });
        },
        child: SizedBox(
          height: 53,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, color: selected ? forest : muted, size: 22),
                  if (selected)
                    Positioned(
                      bottom: -6,
                      left: 8,
                      child: Container(
                        height: 5,
                        width: 5,
                        decoration: const BoxDecoration(
                          color: yellow,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: selected ? forest : muted,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _askButton() => FloatingActionButton.extended(
    heroTag: 'ask-sabi',
    backgroundColor: forest,
    foregroundColor: Colors.white,
    onPressed: () => _navigate(SabiScreen.tutor),
    icon: const OwlAvatar(size: 31),
    label: const Text(
      'Demander à Sabi',
      style: TextStyle(fontWeight: FontWeight.w800),
    ),
  );

  Widget _sectionTitle(String title, String action, VoidCallback onTap) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ),
      TextButton(onPressed: onTap, child: Text(action)),
    ],
  );

  Widget _skillSummary(String title, String state, Color bg, Color color) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _whiteCard(
          ListTile(
            leading: Icon(
              state == 'Maîtrisé'
                  ? Icons.check_circle_rounded
                  : state == 'En progrès'
                  ? Icons.trending_up_rounded
                  : Icons.flag_rounded,
              color: color,
            ),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            trailing: MiniPill(label: state, color: bg, textColor: color),
          ),
        ),
      );

  Widget _dropdown(
    String value,
    List<String> options,
    ValueChanged<String> onChanged,
  ) => DropdownButtonFormField<String>(
    initialValue: options.contains(value) ? value : options.first,
    isExpanded: true,
    decoration: const InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide.none,
      ),
    ),
    items: options
        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
        .toList(),
    onChanged: (value) {
      if (value != null) onChanged(value);
    },
  );

  InputDecoration _inputDecoration(String hint, IconData icon) =>
      InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: forest),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: forest, width: 2),
        ),
      );

  Future<void> _showExitTest() => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Quitter le test ?'),
      content: const Text(
        'Tu pourras reprendre plus tard. Rien n’est une note.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Rester'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            _navigate(SabiScreen.home);
          },
          child: const Text('Quitter'),
        ),
      ],
    ),
  );

  Future<void> _showChoice(String title, List<String> options) =>
      showModalBottomSheet<void>(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              ...options.map(
                (value) => ListTile(
                  title: Text(value),
                  onTap: () {
                    Navigator.pop(context);
                    _showToast('$value choisi.');
                  },
                ),
              ),
            ],
          ),
        ),
      );

  void _showToast(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

class OwlAvatar extends StatelessWidget {
  const OwlAvatar({super.key, this.size = 50});
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          bottom: size * .02,
          child: Container(
            width: size * .8,
            height: size * .73,
            decoration: BoxDecoration(
              color: forest,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(size * .42),
                bottom: Radius.circular(size * .3),
              ),
            ),
          ),
        ),
        Positioned(top: size * .19, left: size * .14, child: _eye(size)),
        Positioned(top: size * .19, right: size * .14, child: _eye(size)),
        Positioned(
          top: size * .42,
          child: Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: size * .12,
              height: size * .12,
              decoration: BoxDecoration(
                color: yellow,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          child: SizedBox(
            width: size * .52,
            height: size * .22,
            child: CustomPaint(painter: CapPainter()),
          ),
        ),
      ],
    ),
  );

  Widget _eye(double size) => Container(
    width: size * .3,
    height: size * .3,
    decoration: const BoxDecoration(color: paper, shape: BoxShape.circle),
    child: Center(
      child: Container(
        width: size * .12,
        height: size * .12,
        decoration: const BoxDecoration(color: ink, shape: BoxShape.circle),
      ),
    ),
  );
}

class CapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final green = Paint()..color = forestDark;
    final gold = Paint()
      ..color = yellow
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height * .45)
      ..lineTo(size.width / 2, size.height * .85)
      ..lineTo(0, size.height * .45)
      ..close();
    canvas.drawPath(path, green);
    canvas.drawPath(path, gold);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class KentePainter extends CustomPainter {
  const KentePainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var index = -3; index < 14; index++) {
      final x = size.width - 115 + index * 19;
      final y = (index.isEven ? 0 : 13).toDouble();
      final color = index % 3 == 0
          ? yellow.withValues(alpha: .15)
          : Colors.white.withValues(alpha: .055);
      paint.color = color;
      final path = Path()
        ..moveTo(x, y)
        ..lineTo(x + 9, y + 9)
        ..lineTo(x, y + 18)
        ..lineTo(x - 9, y + 9)
        ..close();
      canvas.drawPath(path, paint);
      canvas.drawRect(
        Rect.fromLTWH(x - 2, y + 23, 4, 4),
        paint..color = yellow.withValues(alpha: .15),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RadarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * .35;
    final labels = ['Algèbre', 'Calcul', 'Équations', 'Géométrie', 'Thalès'];
    const count = 5;
    for (var ring = 1; ring <= 4; ring++) {
      final path = Path();
      for (var i = 0; i < count; i++) {
        final angle = -math.pi / 2 + i * (2 * math.pi / count);
        final point = Offset(
          center.dx + radius * ring / 4 * math.cos(angle),
          center.dy + radius * ring / 4 * math.sin(angle),
        );
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(
        path,
        Paint()
          ..color = line
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
    final points = <Offset>[];
    const scores = [.77, .7, .45, .68, .38];
    for (var i = 0; i < count; i++) {
      final angle = -math.pi / 2 + i * (2 * math.pi / count);
      final point = Offset(
        center.dx + radius * scores[i] * math.cos(angle),
        center.dy + radius * scores[i] * math.sin(angle),
      );
      points.add(point);
      final outer = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(
        center,
        outer,
        Paint()
          ..color = line
          ..strokeWidth = 1,
      );
    }
    final shape = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      shape.lineTo(point.dx, point.dy);
    }
    shape.close();
    canvas.drawPath(
      shape,
      Paint()
        ..color = forest.withValues(alpha: .2)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      shape,
      Paint()
        ..color = forest
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.3,
    );
    for (final point in points) {
      canvas.drawCircle(point, 4, Paint()..color = forest);
    }
    for (var i = 0; i < count; i++) {
      final angle = -math.pi / 2 + i * (2 * math.pi / count);
      final point = Offset(
        center.dx + (radius + 18) * math.cos(angle),
        center.dy + (radius + 18) * math.sin(angle),
      );
      final text = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            color: muted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, Offset(point.dx - text.width / 2, point.dy - 6));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WeeklyChart extends StatelessWidget {
  const WeeklyChart({super.key});

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: WeeklyChartPainter(),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: const [
        ChartDay(label: 'Lun', value: 0),
        ChartDay(label: 'Mar', value: 0),
        ChartDay(label: 'Mer', value: 0),
        ChartDay(label: 'Jeu', value: 0),
        ChartDay(label: 'Ven', value: 0),
        ChartDay(label: 'Sam', value: 0),
        ChartDay(label: 'Dim', value: 0),
      ],
    ),
  );
}

class ChartDay extends StatelessWidget {
  const ChartDay({super.key, required this.label, required this.value});
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(label, style: const TextStyle(color: muted, fontSize: 10)),
  );
}

class WeeklyChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const values = [.34, .68, .49, .85, .57, .78, .43];
    const labels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final left = 25.0;
    final top = 14.0;
    final width = size.width - 50;
    final height = size.height - 42;
    for (var i = 0; i < 3; i++) {
      final y = top + height * i / 2;
      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - 10, y),
        Paint()
          ..color = line
          ..strokeWidth = 1,
      );
    }
    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final point = Offset(
        left + width * i / (values.length - 1),
        top + height * (1 - values[i]),
      );
      points.add(point);
      final text = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(color: muted, fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, Offset(point.dx - 3, size.height - 15));
    }
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = forest
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    for (final point in points) {
      canvas.drawCircle(point, 4, Paint()..color = yellow);
      canvas.drawCircle(point, 2.5, Paint()..color = forest);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.icon,
  });
  final String label;
  final VoidCallback onPressed;
  final bool enabled;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 54,
    child: FilledButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: icon == null ? const SizedBox.shrink() : Icon(icon),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: forest,
        disabledBackgroundColor: forest.withValues(alpha: .35),
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    ),
  );
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 52,
    child: OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: forest,
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
        side: const BorderSide(color: forest),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    ),
  );
}

class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? paleGreen : Colors.white,
    borderRadius: BorderRadius.circular(15),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        constraints: const BoxConstraints(minHeight: 53),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: selected ? forest : line),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: selected ? forest : muted, size: 20),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: selected ? forest : ink,
                ),
              ),
            ),
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: selected ? forest : line,
              size: 19,
            ),
          ],
        ),
      ),
    ),
  );
}

class FieldLabel extends StatelessWidget {
  const FieldLabel({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: const TextStyle(
      color: forestDark,
      fontSize: 14,
      fontWeight: FontWeight.w800,
    ),
  );
}

class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
    this.action,
  });
  final IconData icon;
  final String text;
  final Color color;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Icon(icon, color: forestDark, size: 19),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: forestDark,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ?action,
      ],
    ),
  );
}

class OwlTip extends StatelessWidget {
  const OwlTip({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: paleGreen,
      borderRadius: BorderRadius.circular(17),
    ),
    padding: const EdgeInsets.all(12),
    child: Row(
      children: [
        const OwlAvatar(size: 46),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: forestDark,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    ),
  );
}

class MiniPill extends StatelessWidget {
  const MiniPill({
    super.key,
    required this.label,
    required this.color,
    required this.textColor,
  });
  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(9),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: textColor,
        fontSize: 10,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

class LegendDot extends StatelessWidget {
  const LegendDot({super.key, required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.circle, color: color, size: 10),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(color: muted, fontSize: 11)),
    ],
  );
}

class BadgeTile extends StatelessWidget {
  const BadgeTile({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 103,
    padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 7),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        Icon(icon, color: color, size: 25),
        const SizedBox(height: 6),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: forest, size: 28),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        Text(body, style: const TextStyle(color: muted)),
      ],
    ),
  );
}

class StepLine extends StatelessWidget {
  const StepLine({super.key, required this.number, required this.text});
  final String number;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 11,
          backgroundColor: paleGreen,
          child: Text(
            number,
            style: const TextStyle(
              color: forest,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(text, style: const TextStyle(height: 1.45, fontSize: 14)),
        ),
      ],
    ),
  );
}

class StudentRow extends StatelessWidget {
  const StudentRow({
    super.key,
    required this.initials,
    required this.name,
    required this.details,
    required this.percent,
    required this.color,
  });
  final String initials;
  final String name;
  final String details;
  final double percent;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      CircleAvatar(
        radius: 18,
        backgroundColor: paleGreen,
        child: Text(
          initials,
          style: const TextStyle(
            color: forest,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
            Text(details, style: const TextStyle(color: muted, fontSize: 12)),
          ],
        ),
      ),
      SizedBox(
        width: 100,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 7,
            color: color,
            backgroundColor: line,
          ),
        ),
      ),
    ],
  );
}

class SkillProgressRow extends StatelessWidget {
  const SkillProgressRow({
    super.key,
    required this.name,
    required this.status,
    required this.percent,
    required this.color,
  });
  final String name;
  final String status;
  final double percent;
  final Color color;

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
    subtitle: Padding(
      padding: const EdgeInsets.only(top: 5),
      child: LinearProgressIndicator(
        value: percent,
        color: color,
        backgroundColor: line,
      ),
    ),
    trailing: Text(
      status,
      style: TextStyle(color: color, fontWeight: FontWeight.w800),
    ),
  );
}

class MiniStat extends StatelessWidget {
  const MiniStat({super.key, required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          color: forest,
          fontSize: 19,
          fontWeight: FontWeight.w900,
        ),
      ),
      Text(label, style: const TextStyle(color: muted, fontSize: 11)),
    ],
  );
}

Widget _whiteCard(Widget child) => Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(19),
    boxShadow: const [
      BoxShadow(color: Color(0x081F2937), blurRadius: 13, offset: Offset(0, 3)),
    ],
  ),
  child: child,
);
