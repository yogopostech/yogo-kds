import 'package:flutter/material.dart';


// ====================================================================
// CUSTOM KEYBOARD PACKAGE - COMPLETE VERSION (DIALOG-BASED)
// Supports: Alphanumeric, Numeric, Alphabets, Decimal, Card Number
// ====================================================================

// ====================================================================
// 1. Keyboard Type Enum
// ====================================================================
enum KeyboardType {
  alphaNumeric, // Full keyboard with letters and numbers
  numeric, // Numbers only (0-9)
  alphabets, // Letters only
  symbols, // Symbols (not implemented)
  numericWithDot, // Numbers with decimal point
  decimalFormatted, // Auto-formatted decimal (0.00 style)
  cardNumberFormatted, // Auto-formatted card number (2222-2222-2222)
}

// ====================================================================
// 2. Global Keyboard Manager
// ====================================================================

// class AppKeyboard {
//   static TextEditingController? _activeController;
//   static FocusNode? _activeFocusNode;
//   static RegExp? _allowRegex;

//   // Card formatting options
//   static int _cardMaxDigits = 19;
//   static int _cardGroupSize = 4;
//   static String _cardSeparator = '-';

//   static bool _isShowing = false;

//   static bool get isShowing => _isShowing;

//   /// Open custom keyboard
//   static void open(
//     BuildContext context, {
//     required KeyboardType keyboardType,
//     TextEditingController? controller,
//     FocusNode? focusNode,
//     Function(String)? onChange,
//     RegExp? allowRegex,
//     // Card number formatting options
//     int cardMaxDigits = 19,
//     int cardGroupSize = 4,
//     String cardSeparator = '-',
//   }) async {
//     // Restore previous focus after a delay
//     FocusNode? previousFocusNode;
//     await Future.delayed(const Duration(milliseconds: 30), () {
//       previousFocusNode = FocusManager.instance.primaryFocus;
//     });
//     if (previousFocusNode != null) {
//       Future.delayed(const Duration(milliseconds: 50), () {
//         FocusScope.of(Get.context!).requestFocus(previousFocusNode);
//       });
//     }

//     close();

//     _activeController = controller ?? TextEditingController();
//     _activeFocusNode = focusNode ?? FocusNode();
//     _allowRegex = allowRegex;
//     _cardMaxDigits = cardMaxDigits;
//     _cardGroupSize = cardGroupSize;
//     _cardSeparator = cardSeparator;
//     _activeFocusNode!.requestFocus();

//     if (onChange != null) {
//       _activeController!.addListener(() {
//         onChange(_activeController?.text ?? "");
//       });
//     }

//     // Determine keyboard width based on type
//     final keyboardWidth =
//         keyboardType == KeyboardType.numeric ||
//             keyboardType == KeyboardType.numericWithDot ||
//             keyboardType == KeyboardType.decimalFormatted ||
//             keyboardType == KeyboardType.cardNumberFormatted
//         ? 400.0
//         : keyboardType == KeyboardType.alphabets
//         ? 975.0
//         : 1255.0;

//     _isShowing = true;

//     Get.dialog(
//       Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Padding(
//               padding: EdgeInsets.only(bottom: 50),
//               child: Material(
//                 type: MaterialType.transparency,
//                 child: SizedBox(
//                   width: keyboardWidth,
//                   child: CustomKeyboardWidget(
//                     controller: _activeController!,
//                     focusNode: _activeFocusNode!,
//                     keyboardType: keyboardType,
//                     onClose: close,
//                     allowRegex: _allowRegex,
//                     cardMaxDigits: _cardMaxDigits,
//                     cardGroupSize: _cardGroupSize,
//                     cardSeparator: _cardSeparator,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       barrierDismissible: true,
//       barrierColor: Colors.transparent,
//     ).then((_) {
//       // Dialog dismissed
//       _isShowing = false;
//       _activeController = null;
//       _activeFocusNode = null;
//       _allowRegex = null;
//     });
//   }

//   /// Close keyboard
//   static void close() {
//     if (_isShowing) {
//       _isShowing = false;
//       _activeController = null;
//       _activeFocusNode = null;
//       _allowRegex = null;

//       // Close the dialog
//       if (Get.isDialogOpen ?? false) {
//         Get.back();
//       }
//     }
//   }
// }

// class AppKeyboard {
//   static TextEditingController? _activeController;
//   static FocusNode? _activeFocusNode;
//   static RegExp? _allowRegex;
//   static VoidCallback? _onChangeListener; // ✅ নতুন

//   static int _cardMaxDigits = 19;
//   static int _cardGroupSize = 4;
//   static String _cardSeparator = '-';
//   static bool _isShowing = false;

//   static bool get isShowing => _isShowing;

//   static void open(
//     BuildContext context, {
//     required KeyboardType keyboardType,
//     TextEditingController? controller,
//     FocusNode? focusNode,
//     Function(String)? onChange,
//     RegExp? allowRegex,
//     int cardMaxDigits = 19,
//     int cardGroupSize = 4,
//     String cardSeparator = '-',
//   }) async {
//     FocusNode? previousFocusNode;
//     await Future.delayed(const Duration(milliseconds: 30), () {
//       previousFocusNode = FocusManager.instance.primaryFocus;
//     });
//     if (previousFocusNode != null) {
//       Future.delayed(const Duration(milliseconds: 50), () {
//         FocusScope.of(Get.context!).requestFocus(previousFocusNode);
//       });
//     }

//     close();

//     _activeController = controller ?? TextEditingController();
//     _activeFocusNode = focusNode ?? FocusNode();
//     _allowRegex = allowRegex;
//     _cardMaxDigits = cardMaxDigits;
//     _cardGroupSize = cardGroupSize;
//     _cardSeparator = cardSeparator;
//     _activeFocusNode!.requestFocus();

//     // ✅ listener reference সেভ করো এবং null-safe করো
//     if (onChange != null) {
//       _onChangeListener = () {
//         final ctrl = _activeController;
//         if (ctrl != null) {
//           onChange(ctrl.text);
//         }
//       };
//       _activeController!.addListener(_onChangeListener!);
//     }

//     final keyboardWidth =
//         keyboardType == KeyboardType.numeric ||
//             keyboardType == KeyboardType.numericWithDot ||
//             keyboardType == KeyboardType.decimalFormatted ||
//             keyboardType == KeyboardType.cardNumberFormatted
//         ? 400.0
//         : keyboardType == KeyboardType.alphabets
//         ? 975.0
//         : 1255.0;

//     _isShowing = true;

//     Get.dialog(
//       Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Padding(
//               padding: const EdgeInsets.only(bottom: 50),
//               child: Material(
//                 type: MaterialType.transparency,
//                 child: SizedBox(
//                   width: keyboardWidth,
//                   child: CustomKeyboardWidget(
//                     controller: _activeController!,
//                     focusNode: _activeFocusNode!,
//                     keyboardType: keyboardType,
//                     onClose: close,
//                     allowRegex: _allowRegex,
//                     cardMaxDigits: _cardMaxDigits,
//                     cardGroupSize: _cardGroupSize,
//                     cardSeparator: _cardSeparator,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       barrierDismissible: true,
//       barrierColor: Colors.transparent,
//     ).then((_) {
//       // ✅ dialog বন্ধে listener remove করো
//       _removeOnChangeListener();
//       _isShowing = false;
//       _activeController = null;
//       _activeFocusNode = null;
//       _allowRegex = null;
//       _onChangeListener = null;
//     });
//   }

//   // ✅ helper method
//   static void _removeOnChangeListener() {
//     if (_onChangeListener != null && _activeController != null) {
//       _activeController!.removeListener(_onChangeListener!);
//     }
//   }

//   static void close() {
//     if (_isShowing) {
//       // ✅ close-এও listener remove করো
//       _removeOnChangeListener();
//       _onChangeListener = null;
//       _isShowing = false;
//       _activeController = null;
//       _activeFocusNode = null;
//       _allowRegex = null;

//       if (Get.isDialogOpen ?? false) {
//         Get.back();
//       }
//     }
//   }
// }


class AppKeyboard {
  static TextEditingController? _activeController;
  static FocusNode? _activeFocusNode;
  static RegExp? _allowRegex;
  static VoidCallback? _onChangeListener;
  static BuildContext? _dialogContext; // dialog বন্ধ করতে

  static int _cardMaxDigits = 19;
  static int _cardGroupSize = 4;
  static String _cardSeparator = '-';
  static bool _isShowing = false;

  static bool get isShowing => _isShowing;

  static void open(
    BuildContext context, {
    required KeyboardType keyboardType,
    TextEditingController? controller,
    FocusNode? focusNode,
    Function(String)? onChange,
    RegExp? allowRegex,
    int cardMaxDigits = 19,
    int cardGroupSize = 4,
    String cardSeparator = '-',
  }) {
    close();

    _activeController = controller ?? TextEditingController();
    _activeFocusNode = focusNode ?? FocusNode();
    _allowRegex = allowRegex;
    _cardMaxDigits = cardMaxDigits;
    _cardGroupSize = cardGroupSize;
    _cardSeparator = cardSeparator;
    _activeFocusNode!.requestFocus();

    if (onChange != null) {
      _onChangeListener = () {
        final ctrl = _activeController;
        if (ctrl != null) onChange(ctrl.text);
      };
      _activeController!.addListener(_onChangeListener!);
    }

    final keyboardWidth = keyboardType == KeyboardType.numeric ||
            keyboardType == KeyboardType.numericWithDot ||
            keyboardType == KeyboardType.decimalFormatted ||
            keyboardType == KeyboardType.cardNumberFormatted
        ? 400.0
        : keyboardType == KeyboardType.alphabets
            ? 975.0
            : 1255.0;

    _isShowing = true;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (dialogContext) {
        _dialogContext = dialogContext;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: Material(
                  type: MaterialType.transparency,
                  child: SizedBox(
                    width: keyboardWidth,
                    child: CustomKeyboardWidget(
                      controller: _activeController!,
                      focusNode: _activeFocusNode!,
                      keyboardType: keyboardType,
                      onClose: close,
                      allowRegex: _allowRegex,
                      cardMaxDigits: _cardMaxDigits,
                      cardGroupSize: _cardGroupSize,
                      cardSeparator: _cardSeparator,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ).then((_) {
      _removeOnChangeListener();
      _isShowing = false;
      _activeController = null;
      _activeFocusNode = null;
      _allowRegex = null;
      _onChangeListener = null;
      _dialogContext = null;
    });
  }

  static void _removeOnChangeListener() {
    if (_onChangeListener != null && _activeController != null) {
      _activeController!.removeListener(_onChangeListener!);
    }
  }

  static void close() {
    if (_isShowing) {
      _removeOnChangeListener();
      _onChangeListener = null;
      _isShowing = false;

      // dialog বন্ধ করো
      if (_dialogContext != null && Navigator.canPop(_dialogContext!)) {
        Navigator.pop(_dialogContext!);
      }
      _dialogContext = null;
      _activeController = null;
      _activeFocusNode = null;
      _allowRegex = null;
    }
  }
}

// ====================================================================
// 3. Custom Keyboard Widget (Internal - UI)
// ====================================================================
class CustomKeyboardWidget extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final KeyboardType keyboardType;
  final VoidCallback onClose;
  final RegExp? allowRegex;
  final int cardMaxDigits;
  final int cardGroupSize;
  final String cardSeparator;

  const CustomKeyboardWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.keyboardType,
    required this.onClose,
    this.allowRegex,
    required this.cardMaxDigits,
    this.cardGroupSize = 4,
    this.cardSeparator = '-',
  });

  @override
  State<CustomKeyboardWidget> createState() => _CustomKeyboardWidgetState();
}

class _CustomKeyboardWidgetState extends State<CustomKeyboardWidget> {
  bool _isCaps = true;
  late List<List<String>> _keyboardLayout;
  bool _isDeleting = false;
  final int _maxDigits = 6; // Maximum digits for decimalFormatted

  // ================================================================
  // Cursor Stability Listener
  // ================================================================
  void _cursorStabilityListener() {
    final text = widget.controller.text;
    final currentSelection = widget.controller.selection;

    if (currentSelection.extentOffset > text.length ||
        currentSelection.baseOffset > text.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.controller.selection = TextSelection.collapsed(
            offset: text.length,
          );
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    widget.focusNode.requestFocus();
    _setKeyboardLayout(widget.keyboardType);

    // Only add listener for non-formatted keyboards
    if (widget.keyboardType != KeyboardType.decimalFormatted &&
        widget.keyboardType != KeyboardType.cardNumberFormatted) {
      widget.controller.addListener(_cursorStabilityListener);
    }

    // Initialize decimal formatted keyboard with 0.00
    if (widget.keyboardType == KeyboardType.decimalFormatted &&
        widget.controller.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.controller.text = '0.00';
          widget.controller.selection = TextSelection.collapsed(
            offset: widget.controller.text.length,
          );
        }
      });
    }
    // Card number formatted keyboard starts empty
  }

  @override
  void dispose() {
    if (widget.keyboardType != KeyboardType.decimalFormatted &&
        widget.keyboardType != KeyboardType.cardNumberFormatted) {
      widget.controller.removeListener(_cursorStabilityListener);
    }
    _isDeleting = false;
    super.dispose();
  }

  // ================================================================
  // Set Keyboard Layout Based on Type
  // ================================================================
  void _setKeyboardLayout(KeyboardType type) {
    if (type == KeyboardType.numeric) {
      _keyboardLayout = [
        ['1', '2', '3'],
        ['4', '5', '6'],
        ['7', '8', '9'],
        ['0', 'BACKSPACE_ICON'],
      ];
    } else if (type == KeyboardType.numericWithDot) {
      _keyboardLayout = [
        ['1', '2', '3'],
        ['4', '5', '6'],
        ['7', '8', '9'],
        ['.', '0', 'BACKSPACE_ICON'],
      ];
    } else if (type == KeyboardType.decimalFormatted ||
        type == KeyboardType.cardNumberFormatted) {
      _keyboardLayout = [
        ['1', '2', '3'],
        ['4', '5', '6'],
        ['7', '8', '9'],
        ['0', 'BACKSPACE_ICON'],
      ];
    } else if (type == KeyboardType.alphabets) {
      _keyboardLayout = [
        ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
        ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
        ['SHIFT_ICON', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', 'BACKSPACE_ICON'],
        ['@', '-', ',', 'SPACE', '.', 'ENTER'],
      ];
    } else {
      // AlphaNumeric
      _keyboardLayout = [
        ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
        ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
        ['SHIFT_ICON', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', 'BACKSPACE_ICON'],
        ['@', '-', ',', 'SPACE', '.', 'ENTER'],
      ];
    }
  }

  // ================================================================
  // Continuous Backspace (Hold to Delete)
  // ================================================================
  Future<void> _startContinuousBackspace() async {
    if (_isDeleting) return;
    _isDeleting = true;

    _handleKeyPress('BACKSPACE_ICON', isContinuous: true);
    await Future.delayed(const Duration(milliseconds: 300));

    while (_isDeleting && mounted) {
      _handleKeyPress('BACKSPACE_ICON', isContinuous: true);
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  void _stopContinuousBackspace() {
    _isDeleting = false;
  }

  // ================================================================
  // Format Decimal (0.00 style)
  // ================================================================
  String _formatDecimal(String digits) {
    if (digits.isEmpty) {
      return '0.00';
    }

    if (digits.length > _maxDigits) {
      return widget.controller.text;
    }

    digits = digits.replaceFirst(RegExp(r'^0+'), '');
    if (digits.isEmpty) digits = '0';

    double value = double.parse(digits) / 100;
    return value.toStringAsFixed(2);
  }

  // ================================================================
  // Format Card Number (2222-2222-2222 style)
  // ================================================================
  String _formatCardNumber(String digits) {
    if (digits.isEmpty) {
      return '';
    }

    // Limit to max digits
    if (digits.length > widget.cardMaxDigits) {
      digits = digits.substring(0, widget.cardMaxDigits);
    }

    // Group digits with separator
    String formattedText = '';
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % widget.cardGroupSize == 0) {
        formattedText += widget.cardSeparator;
      }
      formattedText += digits[i];
    }

    return formattedText;
  }

  // ================================================================
  // Handle Key Press (Main Logic)
  // ================================================================
  void _handleKeyPress(String key, {bool isContinuous = false}) {
    debugPrint('Key pressed: $key');

    if (key == 'SHIFT_ICON') {
      setState(() {
        _isCaps = !_isCaps;
      });
      return;
    }

    // Special handling for formatted keyboards
    if (widget.keyboardType == KeyboardType.decimalFormatted) {
      _handleDecimalFormattedKeyPress(key);
      return;
    }

    if (widget.keyboardType == KeyboardType.cardNumberFormatted) {
      _handleCardNumberFormattedKeyPress(key);
      return;
    }

    // Standard key handling
    final text = widget.controller.text;
    TextSelection selection = widget.controller.selection;
    String newText = text;
    int newCursorPos = selection.baseOffset;
    String charToInsert = key;

    if (selection.baseOffset != selection.extentOffset &&
        !selection.isCollapsed) {
      newCursorPos = selection.start;
    } else {
      newCursorPos = selection.extentOffset;
    }

    if (key.length == 1 && RegExp(r'[A-Z]').hasMatch(key)) {
      charToInsert = _isCaps ? key : key.toLowerCase();
    }

    final rangeStart = selection.start;
    final rangeEnd = selection.end;

    if (key == 'BACKSPACE_ICON') {
      if (rangeStart != rangeEnd) {
        newText = text.replaceRange(rangeStart, rangeEnd, '');
        newCursorPos = rangeStart;
      } else if (newCursorPos > 0) {
        newText = text.replaceRange(newCursorPos - 1, newCursorPos, '');
        newCursorPos = newCursorPos - 1;
      } else {
        _stopContinuousBackspace();
        return;
      }
    } else if (key == 'ENTER') {
      debugPrint('Enter pressed!');
      widget.focusNode.unfocus();
      // Close the dialog using Navigator.pop()
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      return;
    } else if (key == 'SPACE') {
      charToInsert = ' ';
      newText = text.replaceRange(rangeStart, rangeEnd, charToInsert);
      newCursorPos = rangeStart + 1;
    } else {
      newText = text.replaceRange(rangeStart, rangeEnd, charToInsert);
      newCursorPos = rangeStart + charToInsert.length;
    }

    // Regex validation
    if (widget.allowRegex != null && key != 'BACKSPACE_ICON') {
      if (!widget.allowRegex!.hasMatch(newText)) {
        debugPrint('Regex validation failed for: $newText');
        return;
      }
    }

    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
  }

  // ================================================================
  // Handle Decimal Formatted Key Press
  // ================================================================
  void _handleDecimalFormattedKeyPress(String key) {
    final currentText = widget.controller.text;
    String digits = currentText.replaceAll(RegExp(r'[^0-9]'), '');

    if (key == 'BACKSPACE_ICON') {
      if (digits.isNotEmpty) {
        digits = digits.substring(0, digits.length - 1);
      }
      String formatted = _formatDecimal(digits);

      widget.controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    } else if (RegExp(r'[0-9]').hasMatch(key)) {
      String newDigits = digits + key;

      if (newDigits.length > _maxDigits) {
        _stopContinuousBackspace();
        return;
      }

      String formatted = _formatDecimal(newDigits);

      widget.controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  // ================================================================
  // Handle Card Number Formatted Key Press
  // ================================================================
  void _handleCardNumberFormattedKeyPress(String key) {
    final currentText = widget.controller.text;
    String digits = currentText.replaceAll(RegExp(r'[^0-9]'), '');

    if (key == 'BACKSPACE_ICON') {
      if (digits.isNotEmpty) {
        digits = digits.substring(0, digits.length - 1);
      }
      String formatted = _formatCardNumber(digits);

      widget.controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    } else if (RegExp(r'[0-9]').hasMatch(key)) {
      String newDigits = digits + key;

      if (newDigits.length > widget.cardMaxDigits) {
        _stopContinuousBackspace();
        return;
      }

      String formatted = _formatCardNumber(newDigits);

      widget.controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  // ================================================================
  // Build Widget
  // ================================================================
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const double keyHeight = 70;
    const double keyGap = 10;
    const double horizontalPadding = 20;
    const double verticalPadding = 20;

    return Material(
      elevation: 10,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white),
          color: isDark ? Color(0xff202020) : const Color(0xffBABABA),
        ),
        padding: EdgeInsets.only(
          left: horizontalPadding,
          right: horizontalPadding,
          top: verticalPadding,
          bottom: verticalPadding,
        ),
        child: Center(
          child:
              widget.keyboardType == KeyboardType.numeric ||
                  widget.keyboardType == KeyboardType.numericWithDot ||
                  widget.keyboardType == KeyboardType.decimalFormatted ||
                  widget.keyboardType == KeyboardType.cardNumberFormatted
              ? _buildNumericLayout(keyHeight, keyGap)
              : widget.keyboardType == KeyboardType.alphabets
              ? _buildAlphabetsLayout(keyHeight, keyGap)
              : _buildAlphaNumericLayoutWithDivider(keyHeight, keyGap),
        ),
      ),
    );
  }

  // ================================================================
  // Build Alphabets Layout
  // ================================================================
  Widget _buildAlphabetsLayout(double keyHeight, double gap) {
    const double keyWidth = 84;
    const double wideKeyFactor = 1.3;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row 1: Q-P
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildLetterRow(
            _keyboardLayout[0],
            keyWidth: keyWidth,
            keyHeight: keyHeight,
            gap: gap,
          ),
        ),
        SizedBox(height: gap),

        // Row 2: A-L
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildLetterRow(
            _keyboardLayout[1],
            keyWidth: keyWidth,
            keyHeight: keyHeight,
            gap: gap,
          ),
        ),
        SizedBox(height: gap),

        // Row 3: Shift, Z-M, Backspace
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIconKey(
              _isCaps ? Icons.arrow_circle_up : Icons.arrow_circle_down,
              'SHIFT_ICON',
              width: keyWidth * wideKeyFactor,
              height: keyHeight,
              color: isDark ? const Color(0xff363636) : const Color(0xFFFFFFFF),
            ),
            SizedBox(width: gap),
            ..._buildLetterRow(
              _keyboardLayout[2].sublist(1, 8),
              keyWidth: keyWidth,
              keyHeight: keyHeight,
              gap: gap,
            ),
            _buildBackspaceKey(
              width: keyWidth * wideKeyFactor,
              height: keyHeight,
              color: isDark ? const Color(0xff363636) : const Color(0xFFFFFFFF),
            ),
          ],
        ),
        SizedBox(height: gap),

        // Row 4: @, -, comma, space, dot, enter
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildKey(
              _keyboardLayout[3][0],
              width: keyWidth,
              height: keyHeight,
              color: isDark ? const Color(0xff363636) : const Color(0xFFFFFFFF),
            ),
            SizedBox(width: gap),
            _buildKey(
              _keyboardLayout[3][1],
              width: keyWidth,
              height: keyHeight,
              color: isDark ? const Color(0xff363636) : const Color(0xFFFFFFFF),
            ),
            SizedBox(width: gap),
            _buildKey(
              _keyboardLayout[3][2],
              width: keyWidth,
              height: keyHeight,
              color: isDark ? const Color(0xff363636) : const Color(0xFFFFFFFF),
            ),
            SizedBox(width: gap),
            SizedBox(
              width: keyWidth * 4.4 + 3 * gap,
              child: _buildKey(
                _keyboardLayout[3][3],
                height: keyHeight,
                color: isDark
                    ? const Color(0xff363636)
                    : const Color(0xFFFFFFFF),
              ),
            ),
            SizedBox(width: gap),
            _buildKey(
              _keyboardLayout[3][4],
              width: keyWidth,
              height: keyHeight,
              color: isDark ? const Color(0xff363636) : const Color(0xFFFFFFFF),
            ),
            SizedBox(width: gap),
            _buildKey(
              _keyboardLayout[3][5],
              width: keyWidth * 1.8,
              height: keyHeight,
              color: isDark ? const Color(0xff363636) : const Color(0xFFFFFFFF),
            ),
          ],
        ),
      ],
    );
  }

  // ================================================================
  // Build AlphaNumeric Layout with Divider
  // ================================================================
  Widget _buildAlphaNumericLayoutWithDivider(double keyHeight, double gap) {
    const double keyWidth = 76;
    const double numKeyWidth = 100;
    const double wideKeyFactor = 1.3;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IntrinsicHeight(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - Alphabets
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row 1: Q-P
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildLetterRow(
                  _keyboardLayout[0],
                  keyWidth: keyWidth,
                  keyHeight: keyHeight,
                  gap: gap,
                ),
              ),
              SizedBox(height: gap),

              // Row 2: A-L
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildLetterRow(
                  _keyboardLayout[1],
                  keyWidth: keyWidth,
                  keyHeight: keyHeight,
                  gap: gap,
                ),
              ),
              SizedBox(height: gap),

              // Row 3: Shift, Z-M, Backspace
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIconKey(
                    _isCaps ? Icons.arrow_circle_up : Icons.arrow_circle_down,
                    'SHIFT_ICON',
                    width: keyWidth * wideKeyFactor,
                    height: keyHeight,
                    color: isDark
                        ? const Color(0xff363636)
                        : const Color(0xFFFFFFFF),
                  ),
                  SizedBox(width: gap),
                  ..._buildLetterRow(
                    _keyboardLayout[2].sublist(1, 8),
                    keyWidth: keyWidth,
                    keyHeight: keyHeight,
                    gap: gap,
                  ),
                  _buildBackspaceKey(
                    width: keyWidth * wideKeyFactor,
                    height: keyHeight,
                    color: isDark
                        ? const Color(0xff363636)
                        : const Color(0xFFFFFFFF),
                  ),
                ],
              ),
              SizedBox(height: gap),

              // Row 4: @, -, comma, space, dot, enter
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildKey(
                    _keyboardLayout[3][0],
                    width: keyWidth,
                    height: keyHeight,
                    color: isDark
                        ? const Color(0xff363636)
                        : const Color(0xFFFFFFFF),
                  ),
                  SizedBox(width: gap),
                  _buildKey(
                    _keyboardLayout[3][1],
                    width: keyWidth,
                    height: keyHeight,
                    color: isDark
                        ? const Color(0xff363636)
                        : const Color(0xFFFFFFFF),
                  ),
                  SizedBox(width: gap),
                  _buildKey(
                    _keyboardLayout[3][2],
                    width: keyWidth,
                    height: keyHeight,
                    color: isDark
                        ? const Color(0xff363636)
                        : const Color(0xFFFFFFFF),
                  ),
                  SizedBox(width: gap),
                  SizedBox(
                    width: keyWidth * 4.4 + 3 * gap,
                    child: _buildKey(
                      _keyboardLayout[3][3],
                      height: keyHeight,
                      color: isDark
                          ? const Color(0xff363636)
                          : const Color(0xFFFFFFFF),
                    ),
                  ),
                  SizedBox(width: gap),
                  _buildKey(
                    _keyboardLayout[3][4],
                    width: keyWidth,
                    height: keyHeight,
                    color: isDark
                        ? const Color(0xff363636)
                        : const Color(0xFFFFFFFF),
                  ),
                  SizedBox(width: gap),
                  _buildKey(
                    _keyboardLayout[3][5],
                    width: keyWidth * 1.8,
                    height: keyHeight,
                    color: isDark
                        ? const Color(0xff363636)
                        : const Color(0xFFFFFFFF),
                  ),
                ],
              ),
            ],
          ),

          // Vertical Divider
          Container(
            width: 2,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Right side - Numbers with backspace
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row 1: 1, 2, 3
              Row(
                children: [
                  _buildKey(
                    '1',
                    width: numKeyWidth,
                    height: keyHeight,
                    color: isDark
                        ? const Color(0xff363636)
                        : const Color(0xFFFFFFFF),
                  ),
                  SizedBox(width: gap),
                  _buildKey(
                    '2',
                    width: numKeyWidth,
                    height: keyHeight,
                    color: isDark
                        ? const Color(0xff363636)
                        : const Color(0xFFFFFFFF),
                  ),
                  SizedBox(width: gap),
                  _buildKey(
                    '3',
                    width: numKeyWidth,
                    height: keyHeight,
                    color: isDark
                        ? const Color(0xff363636)
                        : const Color(0xFFFFFFFF),
                  ),
                ],
              ),
              SizedBox(height: gap),

              // Row 2: 4, 5, 6
              Row(
                children: [
                  _buildKey(
                    '4',
                    width: numKeyWidth,
                    height: keyHeight,
                    color: isDark
                        ? const Color(0xff363636)
                        : const Color(0xFFFFFFFF),
                  ),
                  SizedBox(width: gap),
                  _buildKey(
                    '5',
                    width: numKeyWidth,
                    height: keyHeight,
                    color: isDark
                        ? const Color(0xff363636)
                        : const Color(0xFFFFFFFF),
                  ),
                  SizedBox(width: gap),
                  _buildKey(
                    '6',
                    width: numKeyWidth,
                    height: keyHeight,
                    color: isDark
                        ? const Color(0xff363636)
                        : const Color(0xFFFFFFFF),
                  ),
                ],
              ),
              SizedBox(height: gap),

              // Row 3: 7, 8, 9
              Row(
                children: [
                  _buildKey(
                    '7',
                    width: numKeyWidth,
                    height: keyHeight,
                    color: isDark
                        ? const Color(0xff363636)
                        : const Color(0xFFFFFFFF),
                  ),
                  SizedBox(width: gap),
                  _buildKey(
                    '8',
                    width: numKeyWidth,
                    height: keyHeight,
                    color: isDark
                        ? const Color(0xff363636)
                        : const Color(0xFFFFFFFF),
                  ),
                  SizedBox(width: gap),
                  _buildKey(
                    '9',
                    width: numKeyWidth,
                    height: keyHeight,
                    color: isDark
                        ? const Color(0xff363636)
                        : const Color(0xFFFFFFFF),
                  ),
                ],
              ),
              SizedBox(height: gap),

              // Row 4: 0 and Backspace
              Row(
                children: [
                  _buildKey(
                    '0',
                    width: numKeyWidth * 2 + gap,
                    height: keyHeight,
                    color: isDark
                        ? const Color(0xff363636)
                        : const Color(0xFFFFFFFF),
                  ),
                  SizedBox(width: gap),
                  _buildBackspaceKey(
                    width: numKeyWidth,
                    height: keyHeight,
                    color: isDark
                        ? const Color(0xff363636)
                        : const Color(0xFFFFFFFF),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // Build Numeric Layout
  // ================================================================
  Widget _buildNumericLayout(double keyHeight, double gap) {
    const double numKeyWidth = 110;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // For formatted keyboards (decimal and card)
    if (widget.keyboardType == KeyboardType.decimalFormatted ||
        widget.keyboardType == KeyboardType.cardNumberFormatted) {
      return SizedBox(
        // width: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var row in _keyboardLayout.sublist(0, 3))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildKey(
                      row[0],
                      width: numKeyWidth,
                      height: keyHeight,
                      color: isDark
                          ? const Color(0xff363636)
                          : const Color(0xFFFFFFFF),
                    ),
                    SizedBox(width: gap),
                    _buildKey(
                      row[1],
                      width: numKeyWidth,
                      height: keyHeight,
                      color: isDark
                          ? const Color(0xff363636)
                          : const Color(0xFFFFFFFF),
                    ),
                    SizedBox(width: gap),
                    _buildKey(
                      row[2],
                      width: numKeyWidth,
                      height: keyHeight,
                      color: isDark
                          ? const Color(0xff363636)
                          : const Color(0xFFFFFFFF),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildKey(
                    _keyboardLayout[3][0],
                    width: numKeyWidth * 2 + gap,
                    height: keyHeight,
                    color: isDark
                        ? const Color(0xff363636)
                        : const Color(0xFFFFFFFF),
                  ),
                  SizedBox(width: gap),
                  _buildBackspaceKey(
                    width: numKeyWidth,
                    height: keyHeight,
                    color: isDark
                        ? const Color(0xff363636)
                        : const Color(0xFFFFFFFF),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Standard numeric layout
    return SizedBox(
      width: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var row in _keyboardLayout.sublist(0, 3))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildKey(
                    row[0],
                    width: numKeyWidth,
                    height: keyHeight,
                    color: isDark
                        ? const Color(0xff363636)
                        : const Color(0xFFFFFFFF),
                  ),
                  SizedBox(width: gap),
                  _buildKey(
                    row[1],
                    width: numKeyWidth,
                    height: keyHeight,
                    color: isDark
                        ? const Color(0xff363636)
                        : const Color(0xFFFFFFFF),
                  ),
                  SizedBox(width: gap),
                  _buildKey(
                    row[2],
                    width: numKeyWidth,
                    height: keyHeight,
                    color: isDark
                        ? const Color(0xff363636)
                        : const Color(0xFFFFFFFF),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildKey(
                  _keyboardLayout[3][0],
                  width: numKeyWidth * 2 + gap,
                  height: keyHeight,
                  color: isDark
                      ? const Color(0xff363636)
                      : const Color(0xFFFFFFFF),
                ),
                SizedBox(width: gap),
                _buildBackspaceKey(
                  width: numKeyWidth,
                  height: keyHeight,
                  color: isDark
                      ? const Color(0xff363636)
                      : const Color(0xFFFFFFFF),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // Build Backspace Key
  // ================================================================
  Widget _buildBackspaceKey({double? width, double height = 50, Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _AnimatedKeyButton(
      width: width,
      height: height,
      isBackspace: true,
      onTapDown: (_) => _startContinuousBackspace(),
      onTapUp: (_) => _stopContinuousBackspace(),
      onTapCancel: _stopContinuousBackspace,
      onTap: () {},
      child: Icon(
        Icons.backspace_outlined,
        size: 48,
        color: isDark
            ? Color(0xffb8b8b8)
            : const Color.fromARGB(255, 34, 34, 34),
      ),
    );
  }

  // ================================================================
  // Build Letter Row
  // ================================================================
  List<Widget> _buildLetterRow(
    List<String> keys, {
    required double keyWidth,
    required double keyHeight,
    required double gap,
  }) {
    return keys.map((key) {
      String displayLabel = key;

      if (RegExp(r'[A-Z]').hasMatch(key)) {
        displayLabel = _isCaps ? key : key.toLowerCase();
      }

      return Padding(
        padding: EdgeInsets.only(right: gap),
        child: _buildKey(
          key,
          displayLabel: displayLabel,
          width: keyWidth,
          height: keyHeight,
        ),
      );
    }).toList();
  }

  // ================================================================
  // Build Standard Key
  // ================================================================
  Widget _buildKey(
    String actionKey, {
    String? displayLabel,
    double? width,
    double height = 50,
    Color? color,
    double? size,
  }) {
    if (RegExp(r'[0-9@.,\-]').hasMatch(actionKey) ||
        actionKey == 'SPACE' ||
        actionKey == 'ENTER') {
      displayLabel = actionKey;
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _AnimatedKeyButton(
      width: width,
      height: height,
      onTap: () => _handleKeyPress(actionKey),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          displayLabel ?? actionKey,
          style: TextStyle(
            color: isDark
                ? Color(0xffb8b8b8)
                : const Color.fromARGB(255, 34, 34, 34),
            fontSize: size ?? 38,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  // ================================================================
  // Build Icon Key
  // ================================================================
  Widget _buildIconKey(
    IconData icon,
    String action, {
    double? width,
    double height = 50,
    Color? color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _AnimatedKeyButton(
      width: width,
      height: height,
      onTap: () => _handleKeyPress(action),
      child: Icon(
        icon,
        size: 42,
        color: isDark
            ? Color(0xffb8b8b8)
            : const Color.fromARGB(255, 34, 34, 34),
      ),
    );
  }
}

// ====================================================================
// 4. Animated Key Button Widget (Press Animation)
// ====================================================================
class _AnimatedKeyButton extends StatefulWidget {
  final double? width;
  final double height;
  final VoidCallback onTap;
  final Function(TapDownDetails)? onTapDown;
  final Function(TapUpDetails)? onTapUp;
  final VoidCallback? onTapCancel;
  final Widget child;
  final bool isBackspace;

  const _AnimatedKeyButton({
    this.width,
    required this.height,
    required this.onTap,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    required this.child,
    this.isBackspace = false,
  });

  @override
  State<_AnimatedKeyButton> createState() => _AnimatedKeyButtonState();
}

class _AnimatedKeyButtonState extends State<_AnimatedKeyButton> {
  double _scale = 1.0;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _scale = 0.9);
    widget.onTapDown?.call(details);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0);
    widget.onTapUp?.call(details);
  }

  void _handleTapCancel() {
    setState(() => _scale = 1.0);
    widget.onTapCancel?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Material(
          color: isDark ? Color(0xff3b3b3b) : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(6),
          elevation: 1,
          child: InkWell(
            onTap: widget.isBackspace ? null : widget.onTap,
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            borderRadius: BorderRadius.circular(6),
            child: Center(child: widget.child),
          ),
        ),
      ),
    );
  }
}
