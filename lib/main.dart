import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const PasswordGeneratorApp());

const Color kBackground = Color(0xFF071A14);
const Color kBackgroundTop = Color(0xFF0B2B21);
const Color kCard = Color(0xFF102E24);
const Color kMint = Color(0xFF34D399);
const Color kMintSoft = Color(0xFFA7F3D0);
const Color kMuted = Color(0xFF87A99C);

const String kUppercase = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
const String kLowercase = 'abcdefghijkmnopqrstuvwxyz';
const String kNumbers = '23456789';
const String kSymbols = '!@#\$%^&*()-_=+[]{};:,.<>?/';

class PasswordGeneratorApp extends StatelessWidget {
  const PasswordGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ColorScheme.fromSeed(
      seedColor: kMint,
      brightness: Brightness.dark,
    );
    return MaterialApp(
      title: 'Password Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: base.copyWith(
          primary: kMint,
          surface: kBackground,
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: kBackground,
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? kBackground
                : const Color(0xFF5C7C70),
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? kMint
                : const Color(0xFF1B3E32),
          ),
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: kMint,
          inactiveTrackColor: Color(0xFF1B3E32),
          thumbColor: kMint,
          overlayColor: Color(0x3334D399),
          valueIndicatorColor: kMint,
          valueIndicatorTextStyle: TextStyle(
            color: kBackground,
            fontWeight: FontWeight.w700,
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF1B3E32),
          contentTextStyle: TextStyle(color: Colors.white),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const GeneratorScreen(),
    );
  }
}

class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({super.key});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  final Random _random = Random.secure();

  double _length = 16;
  bool _uppercase = true;
  bool _lowercase = true;
  bool _numbers = true;
  bool _symbols = false;
  String _password = '';

  @override
  void initState() {
    super.initState();
    _generate();
  }

  String get _pool {
    final parts = <String>[
      if (_uppercase) kUppercase,
      if (_lowercase) kLowercase,
      if (_numbers) kNumbers,
      if (_symbols) kSymbols,
    ];
    return parts.join();
  }

  int get _poolSize => _pool.length;

  double get _entropy =>
      _poolSize == 0 ? 0 : _length * (log(_poolSize) / ln2);

  void _generate() {
    final groups = <String>[
      if (_uppercase) kUppercase,
      if (_lowercase) kLowercase,
      if (_numbers) kNumbers,
      if (_symbols) kSymbols,
    ];
    if (groups.isEmpty) return;

    final chars = <String>[];
    for (final group in groups) {
      chars.add(group[_random.nextInt(group.length)]);
    }
    final all = groups.join();
    final target = _length.round();
    while (chars.length < target) {
      chars.add(all[_random.nextInt(all.length)]);
    }
    for (var i = chars.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final tmp = chars[i];
      chars[i] = chars[j];
      chars[j] = tmp;
    }
    setState(() => _password = chars.join());
  }

  void _toggle(String label, bool value, void Function(bool) assign) {
    final enabledCount = [
      _uppercase,
      _lowercase,
      _numbers,
      _symbols,
    ].where((e) => e).length;
    if (!value && enabledCount == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Keep at least one character type')),
      );
      return;
    }
    setState(() => assign(value));
    _generate();
  }

  Future<void> _copy() async {
    if (_password.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _password));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password copied')),
    );
  }

  ({String label, Color color}) get _strength {
    final bits = _entropy;
    if (bits < 45) return (label: 'Weak', color: const Color(0xFFFF6B81));
    if (bits < 65) return (label: 'Fair', color: const Color(0xFFFFC15E));
    if (bits < 85) return (label: 'Strong', color: kMint);
    return (label: 'Very strong', color: const Color(0xFF22C55E));
  }

  @override
  Widget build(BuildContext context) {
    final strength = _strength;
    final progress = (_entropy / 110).clamp(0.0, 1.0);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kBackgroundTop, kBackground],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: kMint,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: kMint.withValues(alpha: 0.3),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      color: kBackground,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Password Generator',
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Random, offline, on your device',
                          style: TextStyle(fontSize: 12.5, color: kMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: kMint.withValues(alpha: 0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'YOUR PASSWORD',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        color: kMuted,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SelectableText(
                      _password,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                        letterSpacing: 1.2,
                        color: kMintSoft,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: FilledButton.icon(
                              onPressed: _copy,
                              style: FilledButton.styleFrom(
                                backgroundColor: kMint,
                                foregroundColor: kBackground,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: const Icon(Icons.copy_rounded, size: 19),
                              label: const Text(
                                'Copy',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B3E32),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: IconButton(
                            onPressed: _generate,
                            tooltip: 'Regenerate',
                            icon: const Icon(Icons.refresh_rounded),
                            color: kMintSoft,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Strength',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: kMuted,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          strength.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: strength.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: const Color(0xFF1B3E32),
                        valueColor: AlwaysStoppedAnimation(strength.color),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_entropy.round()} bits of entropy',
                      style: const TextStyle(fontSize: 11.5, color: kMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Length',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B3E32),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_length.round()}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: kMint,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _length,
                      min: 6,
                      max: 40,
                      divisions: 34,
                      label: '${_length.round()}',
                      onChanged: (value) {
                        setState(() => _length = value);
                        _generate();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _OptionTile(
                      title: 'Uppercase letters',
                      sample: 'A–Z',
                      value: _uppercase,
                      onChanged: (v) => _toggle('Uppercase', v, (x) => _uppercase = x),
                    ),
                    const Divider(color: Color(0xFF1B3E32), height: 1),
                    _OptionTile(
                      title: 'Lowercase letters',
                      sample: 'a–z',
                      value: _lowercase,
                      onChanged: (v) => _toggle('Lowercase', v, (x) => _lowercase = x),
                    ),
                    const Divider(color: Color(0xFF1B3E32), height: 1),
                    _OptionTile(
                      title: 'Numbers',
                      sample: '0–9',
                      value: _numbers,
                      onChanged: (v) => _toggle('Numbers', v, (x) => _numbers = x),
                    ),
                    const Divider(color: Color(0xFF1B3E32), height: 1),
                    _OptionTile(
                      title: 'Symbols',
                      sample: '!@#\$%',
                      value: _symbols,
                      onChanged: (v) => _toggle('Symbols', v, (x) => _symbols = x),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: _generate,
                  style: FilledButton.styleFrom(
                    backgroundColor: kMint,
                    foregroundColor: kBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.bolt_rounded, size: 21),
                  label: const Text(
                    'Generate password',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
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
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.title,
    required this.sample,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String sample;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  sample,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11.5,
                    color: kMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
