import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_provider.dart';

class PairingScreen extends ConsumerStatefulWidget {
  const PairingScreen({super.key});

  @override
  ConsumerState<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends ConsumerState<PairingScreen> {
  static const _codeLength = 8;
  String _code = '';
  bool _loading = false;
  String? _error;

  void _onDigit(String d) {
    if (_code.length >= _codeLength || _loading) return;
    setState(() {
      _code += d;
      _error = null;
    });
    if (_code.length == _codeLength) {
      _submit();
    }
  }

  void _onBackspace() {
    if (_code.isEmpty || _loading) return;
    setState(() {
      _code = _code.substring(0, _code.length - 1);
      _error = null;
    });
  }

  Future<void> _submit() async {
    setState(() => _loading = true);

    final result = await ref.read(authProvider.notifier).pairDevice(_code);

    if (!mounted) return;

    if (result.success) {
      context.go('/');
    } else {
      setState(() {
        _loading = false;
        _error = result.error ?? 'Invalid code. Please try again.';
        _code = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF6200EE);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Center(
        child: Container(
          width: 900,
          height: 560,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              // ══ Left side — instructions ═══════════════════
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.lock_outline,
                            color: primary, size: 30),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Enter Activation Code',
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Enter your code to activate the KDS screen.',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Device: YOGO KDS',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // vertical divider
              Container(width: 1, color: const Color(0xFFE0E0E0)),

              // ══ Right side — code + number pad ═════════════
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // code dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_codeLength, (i) {
                          final filled = i < _code.length;
                          return Container(
                            width: 22,
                            height: 22,
                            margin:
                                const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: filled ? primary : Colors.transparent,
                              border: Border.all(
                                color: filled ? primary : Colors.black26,
                                width: 2,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),

                      // error / loading
                      // SizedBox(
                      //   height: 24,
                      //   child: _loading
                      //       ? const SizedBox(
                      //           width: 20,
                      //           height: 20,
                      //           child: CircularProgressIndicator(
                      //             strokeWidth: 2.5,
                      //             color: primary,
                      //           ),
                      //         )
                      //       : _error != null
                      //           ? Text(
                      //               _error!,
                      //               style: const TextStyle(
                      //                 color: Colors.redAccent,
                      //                 fontSize: 28,
                      //               ),
                      //             )
                      //           : null,
                      // ),
                                            // error / loading
                      SizedBox(
                        height: 60,
                        child: Center(
                          child: _loading
                              ? const SizedBox(
                                  width: 25,
                                  height: 25,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: primary,
                                  ),
                                )
                              : _error != null
                                  ? Text(
                                      _error!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  : null,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // number pad
                      _NumberPad(
                        onDigit: _onDigit,
                        onBackspace: _onBackspace,
                        primary: primary,
                      ),
                    ],
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

// ── Number pad ────────────────────────────────────────────────────────────────
class _NumberPad extends StatelessWidget {
  const _NumberPad({
    required this.onDigit,
    required this.onBackspace,
    required this.primary,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    Widget key(String label, {VoidCallback? onTap, Widget? child}) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          width: 80,
          height: 70,
          child: Material(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap ?? () => onDigit(label),
              child: Center(
                child: child ??
                    Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [key('1'), key('2'), key('3')],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [key('4'), key('5'), key('6')],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [key('7'), key('8'), key('9')],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // empty slot
            const SizedBox(width: 96),
            key('0'),
            // backspace
            key('',
                onTap: onBackspace,
                child: const Icon(Icons.backspace_outlined,
                    color: Color(0xFF1A1A1A), size: 26)),
          ],
        ),
      ],
    );
  }
}