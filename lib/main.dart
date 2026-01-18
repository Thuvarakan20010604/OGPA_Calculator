import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Set transparent status bar for a cleaner look
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const OGPAApp());
}

/* ---------------- APP ROOT ---------------- */

class OGPAApp extends StatefulWidget {
  const OGPAApp({super.key});

  @override
  State<OGPAApp> createState() => _OGPAAppState();
}

class _OGPAAppState extends State<OGPAApp> {
  String? savedUser;
  bool _prefsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedUser = prefs.getString('username');
      _prefsLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Modern Indigo Seed Scheme
    final lightScheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.light,
      surface: const Color(0xFFF8F9FC), // Slightly off-white background
    );
    final darkScheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.dark,
      surface: const Color(0xFF121212),
    );

    // Common Input Decoration helper
    InputDecorationTheme inputDeco(ColorScheme cs) => InputDecorationTheme(
          filled: true,
          fillColor: cs.surfaceContainerHighest.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.outline.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          labelStyle: TextStyle(color: cs.onSurfaceVariant),
        );

    if (!_prefsLoaded) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: lightScheme.surface,
          body: Center(
              child: CircularProgressIndicator(color: lightScheme.primary)),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OGPA Calc',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightScheme,
        scaffoldBackgroundColor: lightScheme.surface,
        appBarTheme: AppBarTheme(
          backgroundColor: lightScheme.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: lightScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: lightScheme.onSurface),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: lightScheme.outline.withOpacity(0.1)),
          ),
          clipBehavior: Clip.antiAlias,
        ),
        inputDecorationTheme: inputDeco(lightScheme),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkScheme,
        scaffoldBackgroundColor: const Color(0xFF0F1014),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF0F1014),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: darkScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: const Color(0xFF1E1F25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: darkScheme.outline.withOpacity(0.1)),
          ),
        ),
        inputDecorationTheme: inputDeco(darkScheme),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
      home: savedUser != null ? OGPAHome(name: savedUser!) : const NamePage(),
    );
  }
}

/* ---------------- NAME PAGE (ONBOARDING) ---------------- */

class NamePage extends StatefulWidget {
  const NamePage({super.key});

  @override
  State<NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<NamePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController nameCtrl = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutQuart,
    ));

    _animController.forward();
  }

  Future<void> saveUser(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Hero Icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.school_rounded,
                        size: 48,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome to OGPA',
                      style: tt.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Track your semester grades and visualize your academic progress.',
                      style: tt.bodyLarge?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    // Input Card
                    Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: nameCtrl,
                            textInputAction: TextInputAction.done,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'What should we call you?',
                              hintText: 'Enter your name',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: () async {
                              final name = nameCtrl.text.trim();
                              if (name.isEmpty) return;
                              await saveUser(name);
                              if (!mounted) return;
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OGPAHome(name: name),
                                ),
                              );
                            },
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: const Text('Get Started'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ---------------- DASHBOARD HOME ---------------- */

class OGPAHome extends StatefulWidget {
  final String name;

  const OGPAHome({super.key, required this.name});

  @override
  State<OGPAHome> createState() => _OGPAHomeState();
}

class _OGPAHomeState extends State<OGPAHome> {
  // Logic constants
  final Map<String, double> gradePoints = const {
    'A+': 4.0,
    'A': 4.0,
    'A-': 3.7,
    'B+': 3.3,
    'B': 3.0,
    'B-': 2.7,
    'C+': 2.3,
    'C': 2.0,
    'C-': 1.7,
    'D+': 1.3,
    'D': 1.0,
    'E': 0.0,
  };

  // Levels[0] = Level 1 ... Levels[3] = Level 4
  final List<List<Map<String, dynamic>>> levels = List.generate(4, (_) => []);

  final List<Color> levelColors = const [
    Color(0xFF6366F1), // Indigo
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFEC4899), // Pink
  ];

  /// Whether Level 1 is included in OGPA and total credits (default: false).
  bool includeLevel1InOGPA = false;

  @override
  void initState() {
    super.initState();
    _loadSubjectsFromLocal();
  }

  @override
  void dispose() {
    for (var level in levels) {
      for (var subject in level) {
        (subject['nameController'] as TextEditingController).dispose();
        (subject['creditsController'] as TextEditingController).dispose();
      }
    }
    super.dispose();
  }

  String get _subjectsKey => 'subjects_${widget.name}';
  String get _includeL1Key => 'include_level1_in_ogpa_${widget.name}';

  /* --- DATA LOGIC --- */

  Future<void> _loadSubjectsFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_subjectsKey);
      final bool storedInclude = prefs.getBool(_includeL1Key) ?? false;

      // clear old controllers
      for (var level in levels) {
        for (var subject in level) {
          (subject['nameController'] as TextEditingController).dispose();
          (subject['creditsController'] as TextEditingController).dispose();
        }
        level.clear();
      }

      includeLevel1InOGPA = storedInclude;

      if (jsonString == null) {
        setState(() {});
        return;
      }

      final List<dynamic> decoded = jsonDecode(jsonString);

      for (var row in decoded) {
        final int mongoLevel = (row['level'] ?? 1);
        final int levelIndex = ((mongoLevel - 1).clamp(0, 3)) as int;

        levels[levelIndex].add({
          'id': row['id'],
          'name': row['name'],
          'credits': (row['credits'] as num).toDouble(),
          'grade': row['grade'],
          'isEditing': false,
          'nameController': TextEditingController(text: row['name']),
          'creditsController':
              TextEditingController(text: row['credits'].toString()),
          'level': mongoLevel,
        });
      }
      setState(() {});
    } catch (e) {
      debugPrint('Load subjects error: $e');
    }
  }

  Future<void> _saveAllSubjectsToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> allSubjects = [];
    for (int levelIndex = 0; levelIndex < levels.length; levelIndex++) {
      for (var subject in levels[levelIndex]) {
        allSubjects.add({
          'id': subject['id'],
          'name': subject['name'],
          'credits': subject['credits'],
          'grade': subject['grade'],
          'level': subject['level'] ?? (levelIndex + 1),
        });
      }
    }
    await prefs.setString(_subjectsKey, jsonEncode(allSubjects));
  }

  Future<void> _saveIncludeLevel1Pref() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_includeL1Key, includeLevel1InOGPA);
  }

  Future<void> _saveOrUpdateSubject(
      int levelIndex, Map<String, dynamic> subject) async {
    if ((subject['name'] ?? '').toString().trim().isEmpty) return;

    int actualLevel = subject['level'] ?? (levelIndex + 1);
    subject['level'] = actualLevel;
    subject['credits'] = (subject['credits'] as num?)?.toDouble() ?? 0.0;
    subject['id'] ??= DateTime.now().millisecondsSinceEpoch.toString();

    await _saveAllSubjectsToLocal();
    setState(() {});
  }

  Future<void> _deleteSubject(int level, int index) async {
    final subject = levels[level][index];
    bool confirmed = await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete subject?'),
            content:
                Text('Remove "${subject['name']}" from Level ${level + 1}?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Delete')),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    (subject['nameController'] as TextEditingController).dispose();
    (subject['creditsController'] as TextEditingController).dispose();

    setState(() => levels[level].removeAt(index));
    await _saveAllSubjectsToLocal();
  }

  void _addSubject(int levelIndex) {
    setState(() {
      levels[levelIndex].add({
        'id': null,
        'name': '',
        'credits': 0.0,
        'grade': 'A',
        'isEditing': true,
        'nameController': TextEditingController(),
        'creditsController': TextEditingController(),
        'level': levelIndex + 1,
      });
    });
  }

  /* --- GPA CALCULATION LOGIC --- */

  double _levelGPA(int level) {
    double totalCredits = 0;
    double totalPoints = 0;
    for (var s in levels[level]) {
      totalCredits += s['credits'];
      totalPoints += s['credits'] * (gradePoints[s['grade']] ?? 0.0);
    }
    return totalCredits == 0 ? 0 : totalPoints / totalCredits;
  }

  // Uses includeLevel1InOGPA flag
  double _overallOGPA() {
    double totalCredits = 0;
    double totalPoints = 0;

    final int startLevel = includeLevel1InOGPA ? 0 : 1;

    for (int level = startLevel; level < levels.length; level++) {
      for (var subject in levels[level]) {
        final double credits = subject['credits'];
        final double gradePoint = gradePoints[subject['grade']] ?? 0;
        totalCredits += credits;
        totalPoints += credits * gradePoint;
      }
    }
    return totalCredits == 0 ? 0 : totalPoints / totalCredits;
  }

  // Uses includeLevel1InOGPA flag
  double _totalCreditsEarned() {
    double credits = 0;

    final int startLevel = includeLevel1InOGPA ? 0 : 1;

    for (int level = startLevel; level < levels.length; level++) {
      for (var s in levels[level]) {
        credits += s['credits'];
      }
    }
    return credits;
  }

  String _classLabel(double ogpa) {
    if (ogpa >= 3.7) return 'First Class';
    if (ogpa >= 3.3) return 'Second Upper';
    if (ogpa >= 3.0) return 'Second Lower';
    if (ogpa == 0) return 'No Data';
    return 'General Pass';
  }

  Color _classColor(double ogpa) {
    if (ogpa >= 3.7) return const Color(0xFF10B981);
    if (ogpa >= 3.3) return const Color(0xFFF59E0B);
    if (ogpa >= 3.0) return const Color(0xFFF97316);
    if (ogpa == 0) return Colors.grey;
    return const Color(0xFFEF4444);
  }

  Future<void> _signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const NamePage()),
    );
  }

  /* ---------------- UI BUILD ---------------- */

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ogpa = _overallOGPA();
    final totalCredits = _totalCreditsEarned();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. Modern AppBar
          SliverAppBar.large(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: cs.surface,
            surfaceTintColor: cs.surface,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'Hi, ${widget.name}',
                style: TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: _signOut,
                icon: const Icon(Icons.logout_rounded),
                tooltip: 'Sign out',
              ),
              const SizedBox(width: 8),
            ],
          ),

          // 2. Scorecard Area
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                children: [
                  _buildMainScoreCard(ogpa, totalCredits, cs),
                  const SizedBox(height: 12),
                  _buildInsightCard(ogpa, totalCredits, cs),
                ],
              ),
            ),
          ),

          // 3. Level Lists
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildLevelCard(index),
                childCount: 4,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  // --- Widgets ---

  Widget _buildMainScoreCard(double ogpa, double credits, ColorScheme cs) {
    final statusColor = _classColor(ogpa);
    // Use a translucent shade for the track behind the progress
    final trackColor = cs.onPrimaryContainer.withOpacity(0.2);
    final progressColor = cs.onPrimaryContainer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Side: Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Academic Standing',
                  style: TextStyle(
                    color: cs.onPrimaryContainer.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // Content Column for badges
                Wrap(
                  direction: Axis.vertical,
                  spacing: 12,
                  children: [
                    // Class Status Badge
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.workspace_premium_rounded,
                              size: 18, color: statusColor),
                          const SizedBox(width: 8),
                          Text(
                            _classLabel(ogpa),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Credits Badge
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: cs.surface.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bar_chart_rounded,
                              size: 18, color: cs.onSurface.withOpacity(0.7)),
                          const SizedBox(width: 8),
                          Text(
                            '${credits.toStringAsFixed(1)} Credits',
                            style: TextStyle(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Right Side: Circular Indicator with OGPA inside
          SizedBox(
            height: 110,
            width: 110,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Track
                CircularProgressIndicator(
                  value: 1.0,
                  color: trackColor,
                  strokeWidth: 10,
                ),
                // Progress
                CircularProgressIndicator(
                  value: (ogpa / 4).clamp(0.0, 1.0),
                  color: progressColor,
                  strokeCap: StrokeCap.round,
                  strokeWidth: 10,
                ),
                // Text Inside
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ogpa.toStringAsFixed(2),
                        style: TextStyle(
                          color: cs.onPrimaryContainer,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        'OGPA',
                        style: TextStyle(
                          color: cs.onPrimaryContainer.withOpacity(0.6),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(double ogpa, double credits, ColorScheme cs) {
    if (ogpa == 0) return const SizedBox.shrink();

    double pointsNeeded = 0;
    String nextText;
    IconData icon = Icons.trending_up;

    if (ogpa >= 3.7) {
      nextText = 'Excellent work. Maintain your current performance.';
      icon = Icons.star_rounded;
    } else if (ogpa >= 3.3) {
      pointsNeeded = ((3.7 - ogpa) * credits).clamp(0, double.infinity);
      nextText =
          'You need approx. ${pointsNeeded.toStringAsFixed(2)} more GPA points for First Class.';
    } else if (ogpa >= 3.0) {
      pointsNeeded = ((3.3 - ogpa) * credits).clamp(0, double.infinity);
      nextText =
          'You need approx. ${pointsNeeded.toStringAsFixed(2)} more GPA points for Second Upper.';
    } else {
      pointsNeeded = ((3.0 - ogpa) * credits).clamp(0, double.infinity);
      nextText =
          'You need approx. ${pointsNeeded.toStringAsFixed(2)} more GPA points for Second Lower.';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: cs.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              nextText,
              style: TextStyle(
                  fontSize: 13,
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(int levelIndex) {
    final cs = Theme.of(context).colorScheme;
    final subjects = levels[levelIndex];
    final gpa = _levelGPA(levelIndex);
    final color = levelColors[levelIndex];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: levelIndex == 0 && subjects.isEmpty,
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            // Leading: Level Label (e.g., L1)
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'L${levelIndex + 1}',
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
            title: Text(
              'Level ${levelIndex + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            // Subtitle logic: Level 1 shows message only when excluded
            subtitle: Text(
              levelIndex == 0
                  ? (includeLevel1InOGPA
                      ? '${subjects.length} Subject(s)'
                      : 'Not counted in final OGPA')
                  : '${subjects.length} Subject(s)',
              style: TextStyle(
                color: levelIndex == 0 && !includeLevel1InOGPA
                    ? cs.outline
                    : cs.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
            // Trailing: Circular GPA indicator for this level
            trailing: _buildLevelGpaIndicator(gpa, cs),
            childrenPadding:
                const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            children: [
              // Toggle row only for Level 1
              if (levelIndex == 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Include Level 1 GPA in final OGPA',
                          style: TextStyle(
                            fontSize: 13,
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Switch(
                        value: includeLevel1InOGPA,
                        onChanged: (value) async {
                          setState(() {
                            includeLevel1InOGPA = value;
                          });
                          await _saveIncludeLevel1Pref();
                        },
                      ),
                    ],
                  ),
                ),

              if (subjects.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No subjects yet',
                      style: TextStyle(color: cs.outline),
                    ),
                  ),
                )
              else
                ...subjects.asMap().entries.map((entry) {
                  return _buildSubjectRow(
                      levelIndex, entry.key, entry.value);
                }),

              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _addSubject(levelIndex),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Subject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.primary,
                    side: BorderSide(color: cs.outline.withOpacity(0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Circular Indicator for individual levels
  Widget _buildLevelGpaIndicator(double gpa, ColorScheme cs) {
    // Determine color based on standard GPA cutoffs
    Color color;
    if (gpa >= 3.7) {
      color = const Color(0xFF10B981); // Green
    } else if (gpa >= 3.0) {
      color = const Color(0xFFF59E0B); // Amber
    } else if (gpa >= 2.0) {
      color = const Color(0xFFF97316); // Orange
    } else {
      color = const Color(0xFFEF4444); // Red
    }

    // Value between 0.0 and 1.0 (assuming max GPA is 4.0)
    final double value = (gpa / 4.0).clamp(0.0, 1.0);

    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: 4,
            backgroundColor: cs.surfaceContainerHighest,
            color: color,
            strokeCap: StrokeCap.round,
          ),
          Text(
            gpa.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectRow(
      int levelIndex, int index, Map<String, dynamic> subject) {
    final bool isEditing = subject['isEditing'] == true;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isEditing
          ? _buildEditSubjectMode(levelIndex, index, subject)
          : _buildViewSubjectMode(levelIndex, index, subject),
    );
  }

  // --- View Mode Widget (Clean List Tile) ---
  Widget _buildViewSubjectMode(
      int level, int index, Map<String, dynamic> subject) {
    final cs = Theme.of(context).colorScheme;
    final grade = subject['grade'] as String;

    // Determine grade color
    Color gradeColor = cs.primary;
    if (grade.startsWith('A')) {
      gradeColor = const Color(0xFF10B981);
    } else if (grade.startsWith('B')) {
      gradeColor = const Color(0xFF3B82F6);
    } else if (grade.startsWith('C')) {
      gradeColor = const Color(0xFFF59E0B);
    } else {
      gradeColor = const Color(0xFFEF4444);
    }

    return Container(
      key: ValueKey('view_${subject['id']}'),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject['name'],
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
                Text(
                  '${subject['credits']} Credits',
                  style: TextStyle(
                      fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: gradeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: gradeColor.withOpacity(0.2)),
            ),
            child: Text(
              grade,
              style: TextStyle(
                color: gradeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Actions
          MenuAnchor(
            builder: (context, controller, child) {
              return IconButton(
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                icon: Icon(Icons.more_vert,
                    size: 20, color: cs.outline),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              );
            },
            menuChildren: [
              MenuItemButton(
                onPressed: () =>
                    setState(() => subject['isEditing'] = true),
                leadingIcon:
                    const Icon(Icons.edit_outlined, size: 18),
                child: const Text('Edit'),
              ),
              MenuItemButton(
                onPressed: () => _deleteSubject(level, index),
                leadingIcon: const Icon(Icons.delete_outline,
                    size: 18, color: Colors.red),
                child: const Text('Delete',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Edit Mode Widget (Form) ---
  Widget _buildEditSubjectMode(
      int level, int index, Map<String, dynamic> subject) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      key: ValueKey('edit_${subject['id']}'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: cs.primary.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            controller: subject['nameController'],
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Subject Name',
              prefixIcon: Icon(Icons.book_outlined, size: 20),
              isDense: true,
            ),
            onChanged: (val) => subject['name'] = val,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: subject['creditsController'],
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Credits',
                    prefixIcon: Icon(Icons.numbers, size: 20),
                    isDense: true,
                  ),
                  onChanged: (val) =>
                      subject['credits'] = double.tryParse(val) ?? 0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: subject['grade'],
                  isDense: true,
                  decoration: const InputDecoration(
                    labelText: 'Grade',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    isDense: true,
                  ),
                  items: gradePoints.keys.map((g) {
                    return DropdownMenuItem(value: g, child: Text(g));
                  }).toList(),
                  onChanged: (val) =>
                      setState(() => subject['grade'] = val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  // If it's a new empty subject (no name), delete it on cancel
                  if (subject['id'] == null &&
                      (subject['name'] == '' ||
                          subject['name'] == null)) {
                    _deleteSubject(level, index);
                  } else {
                    setState(
                        () => subject['isEditing'] = false);
                  }
                },
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () async {
                  setState(() => subject['isEditing'] = false);
                  await _saveOrUpdateSubject(level, subject);
                },
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Save'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
