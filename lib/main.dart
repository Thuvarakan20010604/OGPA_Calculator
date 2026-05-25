import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
    final lightScheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.light,
      surface: const Color(0xFFF8F9FC),
    );

    final darkScheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.dark,
      surface: const Color(0xFF121212),
    );

    InputDecorationTheme inputDeco(ColorScheme cs) => InputDecorationTheme(
          filled: true,
          fillColor: cs.surfaceContainerHighest.withOpacity(0.35),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: cs.outline.withOpacity(0.16)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: cs.primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          labelStyle: TextStyle(color: cs.onSurfaceVariant),
        );

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
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: lightScheme.outline.withOpacity(0.08)),
          ),
          clipBehavior: Clip.antiAlias,
        ),
        inputDecorationTheme: inputDeco(lightScheme),
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
          color: const Color(0xFF1B1C22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: darkScheme.outline.withOpacity(0.08)),
          ),
        ),
        inputDecorationTheme: inputDeco(darkScheme),
      ),
      home: !_prefsLoaded
          ? Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: lightScheme.primary),
              ),
            )
          : savedUser != null
              ? OGPAHome(name: savedUser!)
              : const NamePage(),
    );
  }
}

/* ---------------- NAME PAGE ---------------- */

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
      duration: const Duration(milliseconds: 850),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );

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
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.92, end: 1.0),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) {
                        return Transform.scale(scale: value, child: child);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.school_rounded,
                          size: 52,
                          color: cs.primary,
                        ),
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
                      'Track your semester GPA, weighted level OGPA, and export your results professionally.',
                      style: tt.bodyLarge?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
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
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
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

/* ---------------- HOME ---------------- */

class OGPAHome extends StatefulWidget {
  final String name;

  const OGPAHome({super.key, required this.name});

  @override
  State<OGPAHome> createState() => _OGPAHomeState();
}

class _OGPAHomeState extends State<OGPAHome>
    with SingleTickerProviderStateMixin {
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

  final List<List<Map<String, dynamic>>> levels = List.generate(4, (_) => []);

  final List<Color> levelColors = const [
    Color(0xFF6366F1),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
  ];

  List<bool> includeLevelsInOgpa = [true, true, true, true];
  bool useLevelWeights = true;
  List<double> levelWeights = [1.0, 1.0, 1.0, 1.0];
  late List<TextEditingController> weightControllers;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    weightControllers = List.generate(
      4,
      (_) => TextEditingController(text: '1.00'),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

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
    for (final controller in weightControllers) {
      controller.dispose();
    }
    _pulseController.dispose();
    super.dispose();
  }

  String get _subjectsKey => 'subjects_${widget.name}';
  String get _includeLevelsKey => 'include_levels_in_ogpa_${widget.name}';
  String get _useWeightsKey => 'use_level_weights_${widget.name}';
  String get _weightsKey => 'level_weights_${widget.name}';

  Future<void> _loadSubjectsFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_subjectsKey);
      final storedInclude = prefs.getStringList(_includeLevelsKey);
      final storedWeights = prefs.getStringList(_weightsKey);
      final storedUseWeights = prefs.getBool(_useWeightsKey);

      if (storedInclude != null && storedInclude.length == 4) {
        includeLevelsInOgpa =
            storedInclude.map((e) => e.toLowerCase() == 'true').toList();
      }

      if (storedWeights != null && storedWeights.length == 4) {
        levelWeights = storedWeights
            .map((e) => double.tryParse(e) ?? 1.0)
            .map((e) => e <= 0 ? 1.0 : e)
            .toList(growable: false);
      }

      if (storedUseWeights != null) {
        useLevelWeights = storedUseWeights;
      }

      for (int i = 0; i < 4; i++) {
        weightControllers[i].text = _formatWeight(levelWeights[i]);
      }

      for (var level in levels) {
        for (var subject in level) {
          (subject['nameController'] as TextEditingController).dispose();
          (subject['creditsController'] as TextEditingController).dispose();
        }
        level.clear();
      }

      if (jsonString != null) {
        final List<dynamic> decoded = jsonDecode(jsonString);

        for (var row in decoded) {
          final int storedLevel = (row['level'] ?? 1);
          final int levelIndex = (storedLevel - 1).clamp(0, 3);

          levels[levelIndex].add({
            'id': row['id'],
            'name': row['name'],
            'credits': (row['credits'] as num).toDouble(),
            'grade': row['grade'],
            'isEditing': false,
            'nameController': TextEditingController(text: row['name']),
            'creditsController':
                TextEditingController(text: row['credits'].toString()),
            'level': storedLevel,
          });
        }
      }

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Load subjects error: $e');
    }
  }

  String _formatWeight(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(1);
    }
    return value.toStringAsFixed(2);
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

  Future<void> _saveOgpaPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _includeLevelsKey,
      includeLevelsInOgpa.map((e) => e.toString()).toList(),
    );
    await prefs.setBool(_useWeightsKey, useLevelWeights);
    await prefs.setStringList(
      _weightsKey,
      levelWeights.map((e) => e.toString()).toList(),
    );
  }

  Future<void> _saveOrUpdateSubject(
    int levelIndex,
    Map<String, dynamic> subject,
  ) async {
    if ((subject['name'] ?? '').toString().trim().isEmpty) return;

    int actualLevel = subject['level'] ?? (levelIndex + 1);
    subject['level'] = actualLevel;
    subject['credits'] = (subject['credits'] as num?)?.toDouble() ?? 0.0;
    subject['id'] ??= DateTime.now().millisecondsSinceEpoch.toString();

    await _saveAllSubjectsToLocal();
    if (mounted) setState(() {});
  }

  Future<void> _deleteSubject(int level, int index) async {
    final subject = levels[level][index];
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete subject?'),
            content:
                Text('Remove "${subject['name']}" from Level ${level + 1}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    (subject['nameController'] as TextEditingController).dispose();
    (subject['creditsController'] as TextEditingController).dispose();

    setState(() {
      levels[level].removeAt(index);
    });
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

  Future<void> _handleWeightChanged(int levelIndex, String rawValue) async {
    final cleaned = rawValue.trim();

    if (cleaned.isEmpty || cleaned == '.') {
      setState(() {
        levelWeights[levelIndex] = 1.0;
      });
      await _saveOgpaPrefs();
      return;
    }

    final parsed = double.tryParse(cleaned);
    if (parsed == null || parsed <= 0) {
      return;
    }

    setState(() {
      levelWeights[levelIndex] = parsed;
    });

    await _saveOgpaPrefs();
  }

  Future<void> _normalizeWeightField(int levelIndex) async {
    final current = double.tryParse(weightControllers[levelIndex].text.trim());
    final safeValue = (current == null || current <= 0) ? 1.0 : current;

    setState(() {
      levelWeights[levelIndex] = safeValue;
      weightControllers[levelIndex].text = _formatWeight(safeValue);
      weightControllers[levelIndex].selection = TextSelection.fromPosition(
        TextPosition(offset: weightControllers[levelIndex].text.length),
      );
    });

    await _saveOgpaPrefs();
  }

  double _levelGPA(int level) {
    double totalCredits = 0;
    double totalPoints = 0;

    for (var s in levels[level]) {
      final double credits = (s['credits'] as num?)?.toDouble() ?? 0.0;
      totalCredits += credits;
      totalPoints += credits * (gradePoints[s['grade']] ?? 0.0);
    }

    return totalCredits == 0 ? 0 : totalPoints / totalCredits;
  }

  double _overallOGPA() {
    if (useLevelWeights) {
      double weightedTotal = 0;
      double totalWeights = 0;

      for (int level = 0; level < levels.length; level++) {
        if (!includeLevelsInOgpa[level]) continue;
        if (levels[level].isEmpty) continue;

        final double gpa = _levelGPA(level);
        final double weight =
            levelWeights[level] <= 0 ? 1.0 : levelWeights[level];

        weightedTotal += gpa * weight;
        totalWeights += weight;
      }

      return totalWeights == 0 ? 0 : weightedTotal / totalWeights;
    }

    double totalCredits = 0;
    double totalPoints = 0;

    for (int level = 0; level < levels.length; level++) {
      if (!includeLevelsInOgpa[level]) continue;

      for (var subject in levels[level]) {
        final double credits = (subject['credits'] as num?)?.toDouble() ?? 0.0;
        final double gradePoint = gradePoints[subject['grade']] ?? 0.0;
        totalCredits += credits;
        totalPoints += credits * gradePoint;
      }
    }

    return totalCredits == 0 ? 0 : totalPoints / totalCredits;
  }

  double _totalCreditsEarned() {
    double credits = 0;
    for (int level = 0; level < levels.length; level++) {
      if (!includeLevelsInOgpa[level]) continue;
      for (var s in levels[level]) {
        credits += (s['credits'] as num?)?.toDouble() ?? 0.0;
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

  String _funStatus(double ogpa) {
    if (ogpa >= 3.7) return '🔥 Superstar Mode';
    if (ogpa >= 3.3) return '🚀 Flying High';
    if (ogpa >= 3.0) return '✨ Good Momentum';
    if (ogpa > 0) return '💪 Keep Pushing';
    return '📚 Start Adding Subjects';
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

  String _modeLabel() {
    return useLevelWeights ? 'Weighted Level GPA' : 'Credit Weighted';
  }

  Map<String, dynamic> _buildBackupMap() {
    final ogpa = _overallOGPA();

    return {
      'app': 'OGPA Calculator',
      'user': widget.name,
      'generatedAt': DateTime.now().toIso8601String(),
      'calculationMode':
          useLevelWeights ? 'weighted_level_gpa' : 'credit_weighted',
      'includeLevelsInOgpa': includeLevelsInOgpa,
      'levelWeights': levelWeights,
      'overallOgpa': ogpa,
      'classLabel': _classLabel(ogpa),
      'levels': List.generate(4, (levelIndex) {
        return {
          'level': levelIndex + 1,
          'includedInOgpa': includeLevelsInOgpa[levelIndex],
          'weight': levelWeights[levelIndex],
          'gpa': _levelGPA(levelIndex),
          'subjects': levels[levelIndex].map((subject) {
            return {
              'id': subject['id'],
              'name': subject['name'],
              'credits': subject['credits'],
              'grade': subject['grade'],
            };
          }).toList(),
        };
      }),
    };
  }

  Future<String> _saveBackupJsonLocally() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/ogpa_backup_${widget.name}_${DateTime.now().millisecondsSinceEpoch}.json',
    );
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(_buildBackupMap()),
    );
    return file.path;
  }

  Future<Uint8List> _generatePdfBytes() async {
    final pdf = pw.Document();
    final ogpa = _overallOGPA();
    final totalCredits = _totalCreditsEarned();
    final generated = DateTime.now();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Text(
            'OGPA Result Summary',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Student: ${widget.name}'),
          pw.Text('Generated: ${generated.toLocal()}'),
          pw.SizedBox(height: 12),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Overall OGPA: ${ogpa.toStringAsFixed(2)}'),
                pw.Text('Academic Standing: ${_classLabel(ogpa)}'),
                pw.Text(
                    'Total Credits Counted: ${totalCredits.toStringAsFixed(1)}'),
                pw.Text('Calculation Mode: ${_modeLabel()}'),
              ],
            ),
          ),
          pw.SizedBox(height: 18),
          ...List.generate(4, (levelIndex) {
            final gpa = _levelGPA(levelIndex);
            final subjects = levels[levelIndex];

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  color: PdfColors.grey200,
                  child: pw.Text(
                    'Level ${levelIndex + 1} | GPA: ${gpa.toStringAsFixed(2)} | Included: ${includeLevelsInOgpa[levelIndex] ? "Yes" : "No"} | Weight: ${levelWeights[levelIndex].toStringAsFixed(2)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: 6),
                if (subjects.isEmpty)
                  pw.Text('No subjects')
                else
                  pw.TableHelper.fromTextArray(
                    headers: const ['Subject', 'Credits', 'Grade', 'Points'],
                    data: subjects.map((s) {
                      final grade = s['grade'] as String;
                      final credits = (s['credits'] as num?)?.toDouble() ?? 0.0;
                      final points = (gradePoints[grade] ?? 0.0);
                      return [
                        (s['name'] ?? '').toString(),
                        credits.toStringAsFixed(1),
                        grade,
                        points.toStringAsFixed(1),
                      ];
                    }).toList(),
                    border: pw.TableBorder.all(color: PdfColors.grey400),
                    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    headerDecoration:
                        const pw.BoxDecoration(color: PdfColors.grey300),
                    cellAlignment: pw.Alignment.centerLeft,
                    cellHeight: 28,
                  ),
                pw.SizedBox(height: 16),
              ],
            );
          }),
        ],
      ),
    );

    return pdf.save();
  }

  Future<String> _savePdfLocally() async {
    final bytes = await _generatePdfBytes();
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/ogpa_result_${widget.name}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(bytes);
    return file.path;
  }

  Future<void> _printPdf() async {
    final bytes = await _generatePdfBytes();
    await Printing.layoutPdf(onLayout: (format) async => bytes);
  }

  void _showSavedPathSnack(String title, String path) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title\n$path'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _openToolsSheet() async {
    final cs = Theme.of(context).colorScheme;

    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: cs.surface,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calculate_outlined),
                  title: const Text('Use weighted level GPA mode'),
                  subtitle: const Text(
                    'Off = normal credit-weighted OGPA\nOn = level GPA × level weight',
                  ),
                  trailing: Switch(
                    value: useLevelWeights,
                    onChanged: (value) async {
                      setState(() => useLevelWeights = value);
                      await _saveOgpaPrefs();
                    },
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      final path = await _saveBackupJsonLocally();
                      _showSavedPathSnack('Backup JSON saved', path);
                    },
                    icon: const Icon(Icons.backup_outlined),
                    label: const Text('Backup Local JSON File'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      final path = await _savePdfLocally();
                      _showSavedPathSnack('PDF saved locally', path);
                    },
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('Save Result as PDF'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _printPdf();
                    },
                    icon: const Icon(Icons.print_outlined),
                    label: const Text('Print PDF'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ogpa = _overallOGPA();
    final totalCredits = _totalCreditsEarned();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
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
                onPressed: _openToolsSheet,
                icon: const Icon(Icons.tune_rounded),
                tooltip: 'Tools & Export',
              ),
              IconButton(
                onPressed: _signOut,
                icon: const Icon(Icons.logout_rounded),
                tooltip: 'Sign out',
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 22),
              child: Column(
                children: [
                  _buildMainScoreCard(ogpa, totalCredits, cs),
                  const SizedBox(height: 12),
                  _buildInsightCard(ogpa, totalCredits, cs),
                  const SizedBox(height: 12),
                  _buildModeCard(cs),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildLevelCard(index),
                childCount: 4,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 42)),
        ],
      ),
    );
  }

  Widget _buildMainScoreCard(double ogpa, double credits, ColorScheme cs) {
    final statusColor = _classColor(ogpa);
    final trackColor = cs.onPrimaryContainer.withOpacity(0.16);
    final progressColor = cs.onPrimaryContainer;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final glow = 8 + (_pulseController.value * 10);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cs.primaryContainer,
                cs.primaryContainer.withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: statusColor.withOpacity(0.12),
                blurRadius: glow,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Academic Standing',
                  style: TextStyle(
                    color: cs.onPrimaryContainer.withOpacity(0.72),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  direction: Axis.vertical,
                  spacing: 12,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.workspace_premium_rounded,
                            size: 18,
                            color: statusColor,
                          ),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surface.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _funStatus(ogpa),
                        style: TextStyle(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surface.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bar_chart_rounded,
                            size: 18,
                            color: cs.onSurface.withOpacity(0.72),
                          ),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surface.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _modeLabel(),
                        style: TextStyle(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: (ogpa / 4).clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return SizedBox(
                height: 116,
                width: 116,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 1.0,
                      color: trackColor,
                      strokeWidth: 10,
                    ),
                    CircularProgressIndicator(
                      value: value,
                      color: progressColor,
                      strokeCap: StrokeCap.round,
                      strokeWidth: 10,
                    ),
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
                              height: 1,
                            ),
                          ),
                          Text(
                            'OGPA',
                            style: TextStyle(
                              color: cs.onPrimaryContainer.withOpacity(0.65),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(double ogpa, double credits, ColorScheme cs) {
    if (ogpa == 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withOpacity(0.32),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outline.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(Icons.menu_book_rounded, size: 20, color: cs.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Add your subjects level by level. Your OGPA summary will appear here.',
                style: TextStyle(
                  fontSize: 13,
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    double pointsNeeded = 0;
    String nextText;
    IconData icon = Icons.trending_up;

    if (ogpa >= 3.7) {
      nextText =
          'Excellent work. Maintain this performance and protect your class standing.';
      icon = Icons.star_rounded;
    } else if (ogpa >= 3.3) {
      pointsNeeded = ((3.7 - ogpa) * credits).clamp(0, double.infinity);
      nextText =
          'You need about ${pointsNeeded.toStringAsFixed(2)} more GPA points to reach First Class.';
    } else if (ogpa >= 3.0) {
      pointsNeeded = ((3.3 - ogpa) * credits).clamp(0, double.infinity);
      nextText =
          'You need about ${pointsNeeded.toStringAsFixed(2)} more GPA points to reach Second Upper.';
    } else {
      pointsNeeded = ((3.0 - ogpa) * credits).clamp(0, double.infinity);
      nextText =
          'You need about ${pointsNeeded.toStringAsFixed(2)} more GPA points to reach Second Lower.';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.32),
        borderRadius: BorderRadius.circular(18),
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
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard(ColorScheme cs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.32),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outline.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(
            useLevelWeights ? Icons.balance_rounded : Icons.calculate_rounded,
            color: cs.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              useLevelWeights
                  ? 'Weighted level mode is ON. Included levels use their own saved weights in real time.'
                  : 'Normal credit-weighted mode is ON. Level weights stay saved, but are ignored in this mode.',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: useLevelWeights,
            onChanged: (value) async {
              setState(() => useLevelWeights = value);
              await _saveOgpaPrefs();
            },
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
            initiallyExpanded: levelIndex == 0,
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            leading: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'L${levelIndex + 1}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
            title: Text(
              'Level ${levelIndex + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              includeLevelsInOgpa[levelIndex]
                  ? '${subjects.length} Subject(s) • Weight ${_formatWeight(levelWeights[levelIndex])}'
                  : 'Excluded from final OGPA • Weight ${_formatWeight(levelWeights[levelIndex])}',
              style: TextStyle(
                color: includeLevelsInOgpa[levelIndex]
                    ? cs.onSurfaceVariant
                    : cs.outline,
                fontSize: 13,
              ),
            ),
            trailing: _buildLevelGpaIndicator(gpa, cs, color),
            childrenPadding:
                const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            children: [
              _buildLevelOptions(levelIndex),
              const SizedBox(height: 8),
              if (subjects.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Center(
                    child: Text(
                      'No subjects yet',
                      style: TextStyle(color: cs.outline),
                    ),
                  ),
                )
              else
                ...subjects.asMap().entries.map((entry) {
                  return _buildSubjectRow(levelIndex, entry.key, entry.value);
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
                    side: BorderSide(color: cs.outline.withOpacity(0.28)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelOptions(int levelIndex) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Include Level ${levelIndex + 1} in final OGPA',
                  style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Switch(
                value: includeLevelsInOgpa[levelIndex],
                onChanged: (value) async {
                  setState(() {
                    includeLevelsInOgpa[levelIndex] = value;
                  });
                  await _saveOgpaPrefs();
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Level weight',
                  style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(
                width: 132,
                child: TextField(
                  controller: weightControllers[levelIndex],
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Weight',
                    hintText: '1.00',
                    isDense: true,
                  ),
                  onChanged: (value) async {
                    await _handleWeightChanged(levelIndex, value);
                  },
                  onTap: () {
                    weightControllers[levelIndex].selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: weightControllers[levelIndex].text.length,
                    );
                  },
                  onSubmitted: (_) async {
                    await _normalizeWeightField(levelIndex);
                    if (!mounted) return;
                    FocusScope.of(context).unfocus();
                  },
                  onEditingComplete: () async {
                    await _normalizeWeightField(levelIndex);
                    if (!mounted) return;
                    FocusScope.of(context).unfocus();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              useLevelWeights
                  ? 'This weight is active right now and updates OGPA immediately.'
                  : 'This weight is saved and will be used when weighted mode is turned on.',
              style: TextStyle(
                fontSize: 11,
                color: cs.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelGpaIndicator(double gpa, ColorScheme cs, Color accent) {
    final double value = (gpa / 4.0).clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 850),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        return SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: 1,
                strokeWidth: 4,
                backgroundColor: cs.surfaceContainerHighest,
                color: cs.surfaceContainerHighest,
              ),
              CircularProgressIndicator(
                value: animatedValue,
                strokeWidth: 4,
                color: accent,
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
      },
    );
  }

  Widget _buildSubjectRow(
    int levelIndex,
    int index,
    Map<String, dynamic> subject,
  ) {
    final isEditing = subject['isEditing'] == true;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        final offset = Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offset, child: child),
        );
      },
      child: isEditing
          ? _buildEditSubjectMode(levelIndex, index, subject)
          : _buildViewSubjectMode(levelIndex, index, subject),
    );
  }

  Widget _buildViewSubjectMode(
    int level,
    int index,
    Map<String, dynamic> subject,
  ) {
    final cs = Theme.of(context).colorScheme;
    final grade = subject['grade'] as String;

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
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.28),
        borderRadius: BorderRadius.circular(14),
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
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${(subject['credits'] as num?)?.toDouble().toStringAsFixed(1) ?? '0.0'} Credits',
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            decoration: BoxDecoration(
              color: gradeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: gradeColor.withOpacity(0.18)),
            ),
            child: Text(
              grade,
              style: TextStyle(
                color: gradeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
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
                icon: Icon(Icons.more_vert, size: 20, color: cs.outline),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              );
            },
            menuChildren: [
              MenuItemButton(
                onPressed: () => setState(() => subject['isEditing'] = true),
                leadingIcon: const Icon(Icons.edit_outlined, size: 18),
                child: const Text('Edit'),
              ),
              MenuItemButton(
                onPressed: () => _deleteSubject(level, index),
                leadingIcon: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Colors.red,
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditSubjectMode(
    int level,
    int index,
    Map<String, dynamic> subject,
  ) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      key: ValueKey('edit_${subject['id'] ?? 'new_$level$index'}'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withOpacity(0.28), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
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
                  onChanged: (val) {
                    subject['credits'] = double.tryParse(val) ?? 0.0;
                  },
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
                  items: gradePoints.keys
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (val) => setState(() => subject['grade'] = val),
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
                  if (subject['id'] == null &&
                      ((subject['name'] ?? '').toString().trim().isEmpty)) {
                    _deleteSubject(level, index);
                  } else {
                    setState(() => subject['isEditing'] = false);
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
          ),
        ],
      ),
    );
  }
}