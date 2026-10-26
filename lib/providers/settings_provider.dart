import 'package:flutter/material.dart' show Color, debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yogo_kds/core/storage/preferences.dart';
import 'package:yogo_kds/data/repositories/order_repo.dart';
import '../shared/enums/order_enums.dart';

// ── কোন settings menu selected ───────────────────────────────
// 0=General, 1=Display Modes, 2=Transition Times, 3=Appearance,
// 4=Fonts & Colors, 5=Screen Communication, 6=Printers
final settingsMenuProvider = StateProvider<int>((ref) => 0);

// ═══════════════════════════════════════════════════════════
// TRANSITION TIMES
// ═══════════════════════════════════════════════════════════

class TransitionTime {
  final int cautionMinutes;
  final int lateMinutes;

  const TransitionTime({this.cautionMinutes = 3, this.lateMinutes = 7});

  TransitionTime copyWith({int? cautionMinutes, int? lateMinutes}) =>
      TransitionTime(
        cautionMinutes: cautionMinutes ?? this.cautionMinutes,
        lateMinutes: lateMinutes ?? this.lateMinutes,
      );
}

class TransitionTimesNotifier
    extends StateNotifier<Map<OrderType, TransitionTime>> {
  TransitionTimesNotifier()
    : super({for (final t in OrderType.values) t: const TransitionTime()});

  void setCaution(OrderType type, int minutes) {
    state = {...state, type: state[type]!.copyWith(cautionMinutes: minutes)};
  }

  void setLate(OrderType type, int minutes) {
    state = {...state, type: state[type]!.copyWith(lateMinutes: minutes)};
  }
}

final transitionTimesProvider =
    StateNotifierProvider<
      TransitionTimesNotifier,
      Map<OrderType, TransitionTime>
    >((ref) {
      return TransitionTimesNotifier();
    });

// // ═══════════════════════════════════════════════════════════
// // FONTS & COLORS
// // ═══════════════════════════════════════════════════════════

// // ── Font size ────────────────────────────────────────────────
// enum KdsFontSize { small, medium, large, extraLarge }

// extension KdsFontSizeX on KdsFontSize {
//   String get label {
//     switch (this) {
//       case KdsFontSize.small:
//         return 'Small';
//       case KdsFontSize.medium:
//         return 'Medium';
//       case KdsFontSize.large:
//         return 'Large';
//       case KdsFontSize.extraLarge:
//         return 'Extra Large';
//     }
//   }

//   double get scale {
//     switch (this) {
//       case KdsFontSize.small:
//         return 0.85;
//       case KdsFontSize.medium:
//         return 1.0;
//       case KdsFontSize.large:
//         return 1.15;
//       case KdsFontSize.extraLarge:
//         return 1.3;
//     }
//   }
// }

// final fontSizeProvider = StateProvider<KdsFontSize>(
//   (ref) => KdsFontSize.medium,
// );

// // ── Status colors (urgency) ──────────────────────────────────
// class StatusColors {
//   final Color onTime;
//   final Color caution;
//   final Color late;

//   const StatusColors({
//     required this.onTime,
//     required this.caution,
//     required this.late,
//   });

//   StatusColors copyWith({Color? onTime, Color? caution, Color? late}) =>
//       StatusColors(
//         onTime: onTime ?? this.onTime,
//         caution: caution ?? this.caution,
//         late: late ?? this.late,
//       );

//   static const defaults = StatusColors(
//     onTime: Color(0xFF4CAF50),
//     caution: Color(0xFFFFC107),
//     late: Color(0xFFEF5350),
//   );
// }

// class StatusColorsNotifier extends StateNotifier<StatusColors> {
//   StatusColorsNotifier() : super(StatusColors.defaults);

//   void setOnTime(Color c) => state = state.copyWith(onTime: c);
//   void setCaution(Color c) => state = state.copyWith(caution: c);
//   void setLate(Color c) => state = state.copyWith(late: c);
//   void restoreDefaults() => state = StatusColors.defaults;
// }

// final statusColorsProvider =
//     StateNotifierProvider<StatusColorsNotifier, StatusColors>((ref) {
//       return StatusColorsNotifier();
//     });

// // ── Order type colors ────────────────────────────────────────
// class OrderTypeColorsNotifier extends StateNotifier<Map<OrderType, Color>> {
//   OrderTypeColorsNotifier() : super(_defaults);

//   static final Map<OrderType, Color> _defaults = {
//     for (final t in OrderType.values) t: _defaultFor(t),
//   };

//   static Color _defaultFor(OrderType t) {
//     switch (t) {
//       case OrderType.dineIn:
//         return const Color(0xFF9C27B0);
//       case OrderType.takeOut:
//         return const Color(0xFF2196F3);
//     }
//   }

//   void setColor(OrderType type, Color c) {
//     state = {...state, type: c};
//   }

//   void restoreDefaults() => state = {..._defaults};
// }

// final orderTypeColorsProvider =
//     StateNotifierProvider<OrderTypeColorsNotifier, Map<OrderType, Color>>((
//       ref,
//     ) {
//       return OrderTypeColorsNotifier();
//     });

// ═══════════════════════════════════════════════════════════
// FONTS & COLORS   (persisted to SharedPreferences)
// ═══════════════════════════════════════════════════════════

// ── Pref keys ────────────────────────────────────────────────
const _kFontSize = 'font_size';
const _kColOnTime = 'col_on_time';
const _kColCaution = 'col_caution';
const _kColLate = 'col_late';

// ── Font size ────────────────────────────────────────────────
enum KdsFontSize { small, medium, large, extraLarge }

extension KdsFontSizeX on KdsFontSize {
  String get label {
    switch (this) {
      case KdsFontSize.small:
        return 'Small';
      case KdsFontSize.medium:
        return 'Medium';
      case KdsFontSize.large:
        return 'Large';
      case KdsFontSize.extraLarge:
        return 'Extra Large';
    }
  }

  double get scale {
    switch (this) {
      case KdsFontSize.small:
        return 0.85;
      case KdsFontSize.medium:
        return 1.0;
      case KdsFontSize.large:
        return 1.15;
      case KdsFontSize.extraLarge:
        return 1.3;
    }
  }
}

// Loads the saved size, and saves again on every change (listenSelf).
// UI keeps working the same: ref.read(fontSizeProvider.notifier).state = x
// final fontSizeProvider = StateProvider<KdsFontSize>((ref) {
//   ref.listenSelf((_, next) {
//     Preferences.setInt(_kFontSize, next.index);
//   });

//   final saved = Preferences.getInt(_kFontSize);
//   if (saved != null && saved >= 0 && saved < KdsFontSize.values.length) {
//     return KdsFontSize.values[saved];
//   }
//   return KdsFontSize.medium;
// });




class FontSizeNotifier extends Notifier<KdsFontSize> {
  @override
  KdsFontSize build() {
    listenSelf((_, next) => Preferences.setInt(_kFontSize, next.index));
    final saved = Preferences.getInt(_kFontSize);
    if (saved != null && saved >= 0 && saved < KdsFontSize.values.length) {
      return KdsFontSize.values[saved];
    }
    return KdsFontSize.medium;
  }

  void set(KdsFontSize size) => state = size;
}

final fontSizeProvider =
    NotifierProvider<FontSizeNotifier, KdsFontSize>(FontSizeNotifier.new);

// ── Status colors (urgency) ──────────────────────────────────
class StatusColors {
  final Color onTime;
  final Color caution;
  final Color late;

  const StatusColors({
    required this.onTime,
    required this.caution,
    required this.late,
  });

  StatusColors copyWith({Color? onTime, Color? caution, Color? late}) =>
      StatusColors(
        onTime: onTime ?? this.onTime,
        caution: caution ?? this.caution,
        late: late ?? this.late,
      );

  static const defaults = StatusColors(
    onTime: Color(0xFF4CAF50),
    caution: Color(0xFFFFC107),
    late: Color(0xFFEF5350),
  );
}

class StatusColorsNotifier extends StateNotifier<StatusColors> {
  StatusColorsNotifier() : super(_loadInitial());

  // Load saved colors on startup, fall back to defaults.
  static StatusColors _loadInitial() {
    final on = Preferences.getInt(_kColOnTime);
    final ca = Preferences.getInt(_kColCaution);
    final la = Preferences.getInt(_kColLate);
    return StatusColors(
      onTime: on != null ? Color(on) : StatusColors.defaults.onTime,
      caution: ca != null ? Color(ca) : StatusColors.defaults.caution,
      late: la != null ? Color(la) : StatusColors.defaults.late,
    );
  }

  // void setOnTime(Color c) {
  //   state = state.copyWith(onTime: c);
  //   Preferences.setInt(_kColOnTime, c.value);
  // }

  // void setCaution(Color c) {
  //   state = state.copyWith(caution: c);
  //   Preferences.setInt(_kColCaution, c.value);
  // }

  // void setLate(Color c) {
  //   state = state.copyWith(late: c);
  //   Preferences.setInt(_kColLate, c.value);
  // }

  // void restoreDefaults() {
  //   state = StatusColors.defaults;
  //   Preferences.setInt(_kColOnTime, StatusColors.defaults.onTime.value);
  //   Preferences.setInt(_kColCaution, StatusColors.defaults.caution.value);
  //   Preferences.setInt(_kColLate, StatusColors.defaults.late.value);
  // }


    void setOnTime(Color c) {
    state = state.copyWith(onTime: c);
    Preferences.setInt(_kColOnTime, c.toARGB32());
  }

  void setCaution(Color c) {
    state = state.copyWith(caution: c);
    Preferences.setInt(_kColCaution, c.toARGB32());
  }

  void setLate(Color c) {
    state = state.copyWith(late: c);
    Preferences.setInt(_kColLate, c.toARGB32());
  }

  void restoreDefaults() {
    state = StatusColors.defaults;
    Preferences.setInt(_kColOnTime, StatusColors.defaults.onTime.toARGB32());
    Preferences.setInt(_kColCaution, StatusColors.defaults.caution.toARGB32());
    Preferences.setInt(_kColLate, StatusColors.defaults.late.toARGB32());
  }
}

final statusColorsProvider =
    StateNotifierProvider<StatusColorsNotifier, StatusColors>((ref) {
      return StatusColorsNotifier();
    });

// ── Order type colors ────────────────────────────────────────
class OrderTypeColorsNotifier extends StateNotifier<Map<OrderType, Color>> {
  OrderTypeColorsNotifier() : super(_loadInitial());

  static final Map<OrderType, Color> _defaults = {
    for (final t in OrderType.values) t: _defaultFor(t),
  };

  static Color _defaultFor(OrderType t) {
    switch (t) {
      case OrderType.dineIn:
        return const Color(0xFF9C27B0);
      case OrderType.takeOut:
        return const Color(0xFF2196F3);
    }
  }

  // One pref key per order type, e.g. col_ordertype_dineIn
  static String _keyFor(OrderType t) => 'col_ordertype_${t.name}';

  static Map<OrderType, Color> _loadInitial() {
    final map = <OrderType, Color>{};
    for (final t in OrderType.values) {
      final v = Preferences.getInt(_keyFor(t));
      map[t] = v != null ? Color(v) : _defaultFor(t);
    }
    return map;
  }

  // void setColor(OrderType type, Color c) {
  //   state = {...state, type: c};
  //   Preferences.setInt(_keyFor(type), c.value);
  // }

  // void restoreDefaults() {
  //   state = {..._defaults};
  //   for (final t in OrderType.values) {
  //     Preferences.setInt(_keyFor(t), _defaultFor(t).value);
  //   }
  // }

    void setColor(OrderType type, Color c) {
    state = {...state, type: c};
    Preferences.setInt(_keyFor(type), c.toARGB32());
  }

  void restoreDefaults() {
    state = {..._defaults};
    for (final t in OrderType.values) {
      Preferences.setInt(_keyFor(t), _defaultFor(t).toARGB32());
    }
  }
}

final orderTypeColorsProvider =
    StateNotifierProvider<OrderTypeColorsNotifier, Map<OrderType, Color>>((
      ref,
    ) {
      return OrderTypeColorsNotifier();
    });




// ═══════════════════════════════════════════════════════════
// GENERAL SETTINGS
// ═══════════════════════════════════════════════════════════

class GeneralSettings {
  final String kdsName;
  final String posSystem;
  final String integrationType;
  final String bumpBar;
  final int storageRecallMinutes;

  const GeneralSettings({
    this.kdsName = 'Expo Station',
    this.posSystem = 'YOGO POS',
    this.integrationType = 'Socket',
    this.bumpBar = 'Touch',
    this.storageRecallMinutes = 30,
  });

  GeneralSettings copyWith({
    String? kdsName,
    String? posSystem,
    String? integrationType,
    String? bumpBar,
    int? storageRecallMinutes,
  }) => GeneralSettings(
    kdsName: kdsName ?? this.kdsName,
    posSystem: posSystem ?? this.posSystem,
    integrationType: integrationType ?? this.integrationType,
    bumpBar: bumpBar ?? this.bumpBar,
    storageRecallMinutes: storageRecallMinutes ?? this.storageRecallMinutes,
  );
}

// class GeneralSettingsNotifier extends StateNotifier<GeneralSettings> {
//   GeneralSettingsNotifier() : super(const GeneralSettings());

//   void setKdsName(String v) => state = state.copyWith(kdsName: v);
//   void setPosSystem(String v) => state = state.copyWith(posSystem: v);
//   void setIntegrationType(String v) =>
//       state = state.copyWith(integrationType: v);
//   void setBumpBar(String v) => state = state.copyWith(bumpBar: v);
//   void setStorageRecall(int v) =>
//       state = state.copyWith(storageRecallMinutes: v);
// }
// class GeneralSettingsNotifier extends StateNotifier<GeneralSettings> {
//   GeneralSettingsNotifier() : super(const GeneralSettings()) {
//     final name = Preferences.deviceName;
//     if (name.trim().isNotEmpty) {
//       state = state.copyWith(kdsName: name);
//     }
//   }

//   void setKdsName(String v) => state = state.copyWith(kdsName: v);
//   void setPosSystem(String v) => state = state.copyWith(posSystem: v);
//   void setIntegrationType(String v) =>
//       state = state.copyWith(integrationType: v);
//   void setBumpBar(String v) => state = state.copyWith(bumpBar: v);
//   void setStorageRecall(int v) =>
//       state = state.copyWith(storageRecallMinutes: v);
// }

class GeneralSettingsNotifier extends StateNotifier<GeneralSettings> {
  GeneralSettingsNotifier() : super(const GeneralSettings()) {
    final name = Preferences.deviceName;
    if (name.trim().isNotEmpty) {
      state = state.copyWith(kdsName: name);
    }
  }

  // ── Rename KDS (API-backed) — optimistic + revert on failure ──
// Future<bool> renameKds(String name) async {
//   final trimmed = name.trim();
//   if (trimmed.isEmpty) return false;

//   // deviceDbId empty hole API call korei lাভ nei — URL e id thakbe na
//   final dbId = Preferences.deviceDbId;
//   debugPrint('[RENAME] deviceDbId = "$dbId"');
//   if (dbId.isEmpty) {
//     debugPrint('[RENAME] deviceDbId empty — pairing e Mongo id save koro nai');
//     return false;
//   }

//   final prev = state.kdsName;

//   // optimistic
//   state = state.copyWith(kdsName: trimmed);

//   try {
//     final saved = await ordersRepository.renameDevice(dbId, trimmed); // ← deviceDbId
//     final finalName = (saved == null || saved.isEmpty) ? trimmed : saved;
//     state = state.copyWith(kdsName: finalName);
//     Preferences.deviceName = finalName; // locally persist
//     return true;
//   } catch (e) {
//     debugPrint('renameDevice failed: $e');
//     state = state.copyWith(kdsName: prev); // revert
//     return false;
//   }
// }



Future<bool> renameKds(String name) async {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return false;

  // SOBSOMOY /me theke current device id ni — token-er device-ta.
  // ei vabe stale/bhul id-er jhamela purno bondho hoy.
  String dbId = Preferences.deviceDbId;
  try {
    final info = await ordersRepository.fetchDeviceInfo();
    final freshId = (info?['id'] ?? '').toString();
    if (freshId.isNotEmpty) {
      dbId = freshId;
      Preferences.deviceDbId = freshId; // local sync
    }
  } catch (e) {
    debugPrint('fetchDeviceInfo failed: $e');
  }

  if (dbId.isEmpty) {
    debugPrint('[RENAME] deviceDbId empty');
    return false;
  }
  debugPrint('[RENAME] using deviceDbId = $dbId');

  final prev = state.kdsName;
  state = state.copyWith(kdsName: trimmed); // optimistic

  try {
    final saved = await ordersRepository.renameDevice(dbId, trimmed);
    final finalName = (saved == null || saved.isEmpty) ? trimmed : saved;
    state = state.copyWith(kdsName: finalName);
    Preferences.deviceName = finalName;
    return true;
  } catch (e) {
    debugPrint('renameDevice failed: $e');
    state = state.copyWith(kdsName: prev); // revert
    return false;
  }
}

  // local-only setters (baki same)
  void setKdsName(String v) => state = state.copyWith(kdsName: v);
  void setPosSystem(String v) => state = state.copyWith(posSystem: v);
  void setIntegrationType(String v) =>
      state = state.copyWith(integrationType: v);
  void setBumpBar(String v) => state = state.copyWith(bumpBar: v);
  void setStorageRecall(int v) =>
      state = state.copyWith(storageRecallMinutes: v);
}

final generalSettingsProvider =
    StateNotifierProvider<GeneralSettingsNotifier, GeneralSettings>((ref) {
      return GeneralSettingsNotifier();
    });

// ═══════════════════════════════════════════════════════════
// DISPLAY MODES
// ═══════════════════════════════════════════════════════════

// ── Screen layout ────────────────────────────────────────────


enum KdsLayout { tiled, classic, split, fullColumns, grid }

extension KdsLayoutX on KdsLayout {
  String get label {
    switch (this) {
      case KdsLayout.tiled:
        return 'Tiled';
      case KdsLayout.classic:
        return 'Classic';
      case KdsLayout.split:
        return 'Split';
      case KdsLayout.fullColumns:
        return 'Full Columns';
      case KdsLayout.grid:
        return 'Grid';
    }
  }

  String get description {
    switch (this) {
      case KdsLayout.tiled:
        return 'Top to bottom, left to right. Tickets fill in where they fit.';
      case KdsLayout.classic:
        return 'Left to right, one horizontal row of tickets.';
      case KdsLayout.split:
        return 'Left to right, two separate horizontal rows of tickets.';
      case KdsLayout.fullColumns:
        return 'Equal-width columns. Best for larger orders.';
      case KdsLayout.grid:
        return 'Fixed grid cells. Best for more tickets at once.';
    }
  }

  String get highlight {
    switch (this) {
      case KdsLayout.tiled:
        return 'Most tickets on screen.';
      case KdsLayout.classic:
        return 'Simple, clean.';
      case KdsLayout.split:
        return 'Organized by order type.';
      case KdsLayout.fullColumns:
        return 'More items per order.';
      case KdsLayout.grid:
        return 'More tickets at once.';
    }
  }
}

// final kdsLayoutProvider = StateProvider<KdsLayout>((ref) => KdsLayout.grid);

// // ── Screen layout (persisted) ────────────────────────────────
// const _kKdsLayout = 'kds_layout';

// final kdsLayoutProvider = StateProvider<KdsLayout>((ref) {
//   // save on every change
//   ref.listenSelf((_, next) {
//     Preferences.setInt(_kKdsLayout, next.index);
//   });
//   // load the saved layout (fallback: grid)
//   final saved = Preferences.getInt(_kKdsLayout);
//   if (saved != null && saved >= 0 && saved < KdsLayout.values.length) {
//     return KdsLayout.values[saved];
//   }
//   return KdsLayout.fullColumns;
// });


// ── Screen layout (persisted) ────────────────────────────────
const _kKdsLayout = 'kds_layout';

class KdsLayoutNotifier extends Notifier<KdsLayout> {
  @override
  KdsLayout build() {
    // save on every change (non-deprecated listenSelf — inside Notifier)
    listenSelf((_, next) {
      Preferences.setInt(_kKdsLayout, next.index);
    });

    // load saved layout (fallback: grid)
    final saved = Preferences.getInt(_kKdsLayout);
    if (saved != null && saved >= 0 && saved < KdsLayout.values.length) {
      return KdsLayout.values[saved];
    }
    return KdsLayout.grid;
  }

  void set(KdsLayout layout) => state = layout;
}

final kdsLayoutProvider =
    NotifierProvider<KdsLayoutNotifier, KdsLayout>(KdsLayoutNotifier.new);



// ── Order type visibility toggles ────────────────────────────
class OrderTypeVisibilityNotifier extends StateNotifier<Map<OrderType, bool>> {
  OrderTypeVisibilityNotifier()
    : super({for (final t in OrderType.values) t: true});

  void toggle(OrderType type) {
    state = {...state, type: !(state[type] ?? true)};
  }
}

final orderTypeVisibilityProvider =
    StateNotifierProvider<OrderTypeVisibilityNotifier, Map<OrderType, bool>>((
      ref,
    ) {
      return OrderTypeVisibilityNotifier();
    });

// ═══════════════════════════════════════════════════════════
// SCREEN COMMUNICATION
// ═══════════════════════════════════════════════════════════

enum ScreenCommMode { multiClear, sendToNext }

extension ScreenCommModeX on ScreenCommMode {
  String get label {
    switch (this) {
      case ScreenCommMode.multiClear:
        return 'Multi Clear';
      case ScreenCommMode.sendToNext:
        return 'Send to Next';
    }
  }
}

class ConnectedScreen {
  final String id;
  final String name;
  final ScreenCommMode mode;

  const ConnectedScreen({
    required this.id,
    required this.name,
    this.mode = ScreenCommMode.sendToNext,
  });

  ConnectedScreen copyWith({ScreenCommMode? mode}) =>
      ConnectedScreen(id: id, name: name, mode: mode ?? this.mode);
}

class ScreenCommState {
  final bool enabled;
  final bool isScanning;
  final List<ConnectedScreen> myScreens; // connected
  final List<ConnectedScreen> availableScreens; // network এ পাওয়া

  const ScreenCommState({
    this.enabled = false,
    this.isScanning = false,
    this.myScreens = const [],
    this.availableScreens = const [],
  });

  ScreenCommState copyWith({
    bool? enabled,
    bool? isScanning,
    List<ConnectedScreen>? myScreens,
    List<ConnectedScreen>? availableScreens,
  }) => ScreenCommState(
    enabled: enabled ?? this.enabled,
    isScanning: isScanning ?? this.isScanning,
    myScreens: myScreens ?? this.myScreens,
    availableScreens: availableScreens ?? this.availableScreens,
  );
}

class ScreenCommNotifier extends StateNotifier<ScreenCommState> {
  ScreenCommNotifier() : super(const ScreenCommState());

  // void toggle() {
  //   final enabling = !state.enabled;
  //   if (enabling) {
  //     // enable হলে discovery শুরু — এখন mock, পরে real network scan হবে
  //     state = state.copyWith(
  //       enabled: true,
  //       myScreens: [
  //         const ConnectedScreen(id: '1', name: 'Sandboxandroid'),
  //       ],
  //       availableScreens: [
  //         const ConnectedScreen(id: '2', name: 'Kitchen Station 2'),
  //         const ConnectedScreen(id: '3', name: 'Expo Display'),
  //       ],
  //     );
  //   } else {
  //     state = const ScreenCommState();
  //   }
  // }
  Future<void> toggle() async {
    final enabling = !state.enabled;
    if (enabling) {
      // scan শুরু — loader দেখাবে
      state = state.copyWith(enabled: true, isScanning: true);

      // fake network scan — পরে real discovery বসবে এখানে
      await Future.delayed(const Duration(seconds: 3));

      // এর মধ্যে user toggle off করে দিলে কিছু করো না
      if (!state.enabled) return;

      // scan শেষ — results + loader বন্ধ
      state = state.copyWith(
        isScanning: false,
        myScreens: [const ConnectedScreen(id: '1', name: 'Sandboxandroid')],
        availableScreens: [
          const ConnectedScreen(id: '2', name: 'Kitchen Station 2'),
          const ConnectedScreen(id: '3', name: 'Expo Display'),
        ],
      );
    } else {
      state = const ScreenCommState();
    }
  }

  void setMode(String screenId, ScreenCommMode mode) {
    state = state.copyWith(
      myScreens: [
        for (final s in state.myScreens)
          if (s.id == screenId) s.copyWith(mode: mode) else s,
      ],
    );
  }

  void connect(String screenId) {
    final screen = state.availableScreens
        .where((s) => s.id == screenId)
        .firstOrNull;
    if (screen == null) return;
    state = state.copyWith(
      myScreens: [...state.myScreens, screen],
      availableScreens: state.availableScreens
          .where((s) => s.id != screenId)
          .toList(),
    );
  }

  void remove(String screenId) {
    final screen = state.myScreens.where((s) => s.id == screenId).firstOrNull;
    if (screen == null) return;
    state = state.copyWith(
      myScreens: state.myScreens.where((s) => s.id != screenId).toList(),
      availableScreens: [...state.availableScreens, screen],
    );
  }
}

final screenCommProvider =
    StateNotifierProvider<ScreenCommNotifier, ScreenCommState>((ref) {
      return ScreenCommNotifier();
    });

// detail page এ কোন screen দেখানো হচ্ছে ('' মানে list view)
final screenCommDetailProvider = StateProvider<String>((ref) => '');

// ═══════════════════════════════════════════════════════════
// PRINTERS
// ═══════════════════════════════════════════════════════════

enum PrinterType { epson, star, xprinter, other }

extension PrinterTypeX on PrinterType {
  String get label {
    switch (this) {
      case PrinterType.epson:
        return 'Epson (ESC/POS)';
      case PrinterType.star:
        return 'Star Micronics';
      case PrinterType.xprinter:
        return 'Xprinter';
      case PrinterType.other:
        return 'Other';
    }
  }
}

class KdsPrinter {
  final String id;
  final String name;
  final String ip;
  final int port;
  final PrinterType type;
  final bool isDefault;

  const KdsPrinter({
    required this.id,
    required this.name,
    required this.ip,
    this.port = 9100,
    this.type = PrinterType.epson,
    this.isDefault = false,
  });

  KdsPrinter copyWith({
    String? name,
    String? ip,
    int? port,
    PrinterType? type,
    bool? isDefault,
  }) => KdsPrinter(
    id: id,
    name: name ?? this.name,
    ip: ip ?? this.ip,
    port: port ?? this.port,
    type: type ?? this.type,
    isDefault: isDefault ?? this.isDefault,
  );
}

class PrintersNotifier extends StateNotifier<List<KdsPrinter>> {
  PrintersNotifier() : super([]);

  void add(KdsPrinter printer) {
    // প্রথম printer automatic default হবে
    final isFirst = state.isEmpty;
    state = [...state, printer.copyWith(isDefault: isFirst)];
  }

  void remove(String id) {
    final wasDefault =
        state.where((p) => p.id == id).firstOrNull?.isDefault ?? false;
    var list = state.where((p) => p.id != id).toList();
    // default টা remove হলে প্রথমটাকে default করো
    if (wasDefault && list.isNotEmpty) {
      list = [list.first.copyWith(isDefault: true), ...list.skip(1)];
    }
    state = list;
  }

  void setDefault(String id) {
    state = [for (final p in state) p.copyWith(isDefault: p.id == id)];
  }
}

final printersProvider =
    StateNotifierProvider<PrintersNotifier, List<KdsPrinter>>((ref) {
      return PrintersNotifier();
    });

// ═══════════════════════════════════════════════════════════
// ITEM SUMMARY POSITION
// ═══════════════════════════════════════════════════════════

enum SummaryPosition { left, right, bottom }

extension SummaryPositionX on SummaryPosition {
  String get label {
    switch (this) {
      case SummaryPosition.left:
        return 'Left';
      case SummaryPosition.right:
        return 'Right';
      case SummaryPosition.bottom:
        return 'Bottom';
    }
  }
}

final summaryPositionProvider = StateProvider<SummaryPosition>(
  (ref) => SummaryPosition.left,
);

// ═══════════════════════════════════════════════════════════
// ROUTING
// ═══════════════════════════════════════════════════════════

class RoutingState {
  final Map<String, bool> sources; // ordering source → enabled
  final Map<String, bool> categories; // category → enabled

  const RoutingState({this.sources = const {}, this.categories = const {}});

  RoutingState copyWith({
    Map<String, bool>? sources,
    Map<String, bool>? categories,
  }) => RoutingState(
    sources: sources ?? this.sources,
    categories: categories ?? this.categories,
  );

  bool isSourceOn(String s) => sources[s] ?? true;
  bool isCategoryOn(String c) => categories[c] ?? true;
}

class RoutingNotifier extends StateNotifier<RoutingState> {
  RoutingNotifier() : super(_defaults);

  // পরে backend থেকে আসবে — এখন static
  static const defaultSources = [
    'POS',
    'Online Orders',
    'DoorDash',
    'Uber Eats',
  ];
  static const defaultCategories = [
    'Appetizers',
    'Curry',
    'Tandoor',
    'Rice & Biryani',
    'Breads',
    'Desserts',
    'Drinks',
    'Unassigned',
  ];

  static final _defaults = RoutingState(
    sources: {for (final s in defaultSources) s: true},
    categories: {for (final c in defaultCategories) c: true},
  );

  void toggleSource(String source) {
    state = state.copyWith(
      sources: {...state.sources, source: !(state.sources[source] ?? true)},
    );
  }

  void toggleCategory(String category) {
    state = state.copyWith(
      categories: {
        ...state.categories,
        category: !(state.categories[category] ?? true),
      },
    );
  }

  void enableAllCategories() {
    state = state.copyWith(
      categories: {for (final c in state.categories.keys) c: true},
    );
  }

  void disableAllCategories() {
    state = state.copyWith(
      categories: {for (final c in state.categories.keys) c: false},
    );
  }
}

final routingProvider = StateNotifierProvider<RoutingNotifier, RoutingState>((
  ref,
) {
  return RoutingNotifier();
});



// ═══════════════════════════════════════════════════════════
// NOTIFICATION SOUND (persisted)  — default ON
// ═══════════════════════════════════════════════════════════
const _kNotificationSound = 'notification_sound';

class NotificationSoundNotifier extends Notifier<bool> {
  @override
  bool build() {
    listenSelf((_, next) =>
        Preferences.setInt(_kNotificationSound, next ? 1 : 0));
    final saved = Preferences.getInt(_kNotificationSound);
    return saved == null ? true : saved == 1; // default ON
  }

  void set(bool v) => state = v;
}

final notificationSoundProvider =
    NotifierProvider<NotificationSoundNotifier, bool>(
        NotificationSoundNotifier.new);


// ═══════════════════════════════════════════════════════════
// ORDERS OPTIONS
// ═══════════════════════════════════════════════════════════

enum ItemDisplayMode { combineLike, separate }

extension ItemDisplayModeX on ItemDisplayMode {
  String get label {
    switch (this) {
      case ItemDisplayMode.combineLike:
        return 'Combine Like Items';
      case ItemDisplayMode.separate:
        return 'Show Separately';
    }
  }
}

class OrdersSettings {
  final bool hideActionsAndType;
  final bool hideEmployeeName;
  final ItemDisplayMode itemDisplay;
  final bool showSeatNumber;
  final bool strikeIndividualModifiers;
  final bool mergeByName;
  final int mergeByNameMinutes;
  final bool newCardPerSend;

  const OrdersSettings({
    this.hideActionsAndType = false,
    this.hideEmployeeName = false,
    this.itemDisplay = ItemDisplayMode.combineLike,
    this.showSeatNumber = true,
    this.strikeIndividualModifiers = true,
    this.mergeByName = true,
    this.mergeByNameMinutes = 8,
    this.newCardPerSend = false,
  });

  OrdersSettings copyWith({
    bool? hideActionsAndType,
    bool? hideEmployeeName,
    ItemDisplayMode? itemDisplay,
    bool? showSeatNumber,
    bool? strikeIndividualModifiers,
    bool? mergeByName,
    int? mergeByNameMinutes,
    bool? newCardPerSend,
  }) => OrdersSettings(
    hideActionsAndType: hideActionsAndType ?? this.hideActionsAndType,
    hideEmployeeName: hideEmployeeName ?? this.hideEmployeeName,
    itemDisplay: itemDisplay ?? this.itemDisplay,
    showSeatNumber: showSeatNumber ?? this.showSeatNumber,
    strikeIndividualModifiers:
        strikeIndividualModifiers ?? this.strikeIndividualModifiers,
    mergeByName: mergeByName ?? this.mergeByName,
    mergeByNameMinutes: mergeByNameMinutes ?? this.mergeByNameMinutes,
    newCardPerSend: newCardPerSend ?? this.newCardPerSend,
  );
}

class OrdersSettingsNotifier extends StateNotifier<OrdersSettings> {
  OrdersSettingsNotifier() : super(const OrdersSettings());

  void toggleHideActions() =>
      state = state.copyWith(hideActionsAndType: !state.hideActionsAndType);
  void toggleHideEmployee() =>
      state = state.copyWith(hideEmployeeName: !state.hideEmployeeName);
  void setItemDisplay(ItemDisplayMode m) =>
      state = state.copyWith(itemDisplay: m);
  void toggleSeatNumber() =>
      state = state.copyWith(showSeatNumber: !state.showSeatNumber);
  void toggleStrikeModifiers() => state = state.copyWith(
    strikeIndividualModifiers: !state.strikeIndividualModifiers,
  );
  void toggleMergeByName() =>
      state = state.copyWith(mergeByName: !state.mergeByName);
  void setMergeMinutes(int m) => state = state.copyWith(mergeByNameMinutes: m);
  void toggleNewCardPerSend() =>
      state = state.copyWith(newCardPerSend: !state.newCardPerSend);
}

final ordersSettingsProvider =
    StateNotifierProvider<OrdersSettingsNotifier, OrdersSettings>((ref) {
      return OrdersSettingsNotifier();
    });
