import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../providers/settings_provider.dart';

// ── App version provider ──────────────────────────────────────
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version}+${info.buildNumber}';
});

// ── Local IP provider ─────────────────────────────────────────
// final localIpProvider = FutureProvider<String>((ref) async {
//   try {
//     final interfaces = await NetworkInterface.list(
//       type: InternetAddressType.IPv4,
//       includeLinkLocal: false,
//     );
//     for (final iface in interfaces) {
//       for (final addr in iface.addresses) {
//         if (!addr.isLoopback) return addr.address;
//       }
//     }
//   } catch (_) {}
//   return 'Unavailable';
// });
final localIpProvider = FutureProvider<String>((ref) async {
  try {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLinkLocal: false,
    );
    String? fallback;
    for (final iface in interfaces) {
      for (final addr in iface.addresses) {
        if (addr.isLoopback) continue;
        // LAN IP কে priority
        if (addr.address.startsWith('192.168.')) {
          return addr.address;
        }
        fallback ??= addr.address;
      }
    }
    return fallback ?? 'Unavailable';
  } catch (_) {
    return 'Unavailable';
  }
});
// ── Device identifier — সহজ unique id ─────────────────────────
final deviceIdProvider = Provider<String>((ref) {
  // hostname based simple identifier
  return Platform.localHostname.toUpperCase();
});

class GeneralPanel extends ConsumerWidget {
  const GeneralPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final settings = ref.watch(generalSettingsProvider);
    final version = ref.watch(appVersionProvider);
    final ip = ref.watch(localIpProvider);
    final deviceId = ref.watch(deviceIdProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Text(
            'General',
            style: t.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Divider(height: 1, color: t.dividerColor),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ══ Device info group ═══════════════════════════
              // ══ App Sound ═══════════════════════════════════
_Group(
  children: [
    _ToggleRow(
      label: 'Notification Sound',
      subtitle: 'Play a sound when a new order arrives',
      value: ref.watch(notificationSoundProvider),
      onChanged: (v) =>
          ref.read(notificationSoundProvider.notifier).set(v),
      isLast: true,
    ),
  ],
),
const SizedBox(height: 20),
              _Group(
                children: [
                  _NavRow(
                    label: 'KDS Name',
                    value: settings.kdsName,
                    onTap: () => _editKdsName(context, ref, settings.kdsName),
                  ),
                  _InfoRow(
                    label: 'Current Version',
                    value: version.when(
                      data: (v) => v,
                      loading: () => '...',
                      error: (_, __) => 'Unknown',
                    ),
                  ),
                  _InfoRow(
                    label: 'Ip Address',
                    value: ip.when(
                      data: (v) => v,
                      loading: () => '...',
                      error: (_, __) => 'Unavailable',
                    ),
                  ),
                  _InfoRow(
                    label: 'Identifier',
                    value: deviceId,
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ══ POS group ═══════════════════════════════════
              _Group(
                children: [
                  _NavRow(
                    label: 'Point of Sale System',
                    value: settings.posSystem,
                    onTap: () => _pickOption(
                      context,
                      title: 'Point of Sale System',
                      options: const ['YOGO POS', 'YOGO POS', 'YOGO POS', 'Other'],
                      current: settings.posSystem,
                      onSelected: (v) => ref
                          .read(generalSettingsProvider.notifier)
                          .setPosSystem(v),
                    ),
                  ),
                  _NavRow(
                    label: 'Integration Type',
                    value: settings.integrationType,
                    isLast: true,
                    onTap: () => _pickOption(
                      context,
                      title: 'Integration Type',
                      options: const ['Socket', 'Printer', 'API'],
                      current: settings.integrationType,
                      onSelected: (v) => ref
                          .read(generalSettingsProvider.notifier)
                          .setIntegrationType(v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ══ Bump bar group ══════════════════════════════
              _Group(
                children: [
                  _NavRow(
                    label: 'Bump Bar',
                    value: settings.bumpBar,
                    isLast: true,
                    onTap: () => _pickOption(
                      context,
                      title: 'Bump Bar',
                      options: const ['Touch', 'Keyboard', 'None'],
                      current: settings.bumpBar,
                      onSelected: (v) => ref
                          .read(generalSettingsProvider.notifier)
                          .setBumpBar(v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ══ Storage recall group ════════════════════════
              _Group(
                children: [
                  _NavRow(
                    label: 'Storage Recall Time',
                    value: '${settings.storageRecallMinutes} min',
                    isLast: true,
                    onTap: () => _pickOption(
                      context,
                      title: 'Storage Recall Time',
                      options: const ['15', '30', '60', '120', '240'],
                      optionLabels: const [
                        '15 minutes',
                        '30 minutes',
                        '1 hour',
                        '2 hours',
                        '4 hours'
                      ],
                      current: '${settings.storageRecallMinutes}',
                      onSelected: (v) => ref
                          .read(generalSettingsProvider.notifier)
                          .setStorageRecall(int.parse(v)),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  'Set how long your KDS stores past orders',
                  style: t.textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── KDS Name edit dialog ────────────────────────────────────
  // Future<void> _editKdsName(
  //     BuildContext context, WidgetRef ref, String current) async {
  //   final controller = TextEditingController(text: current);
  //   final result = await showDialog<String>(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       title: const Text('KDS Name'),
  //       content: TextField(
  //         controller: controller,
  //         autofocus: true,
  //         inputFormatters: [LengthLimitingTextInputFormatter(30)],
  //         decoration: const InputDecoration(hintText: 'Enter station name'),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.of(ctx).pop(),
  //           child: const Text('Cancel'),
  //         ),
  //         ElevatedButton(
  //           onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
  //           child: const Text('Save'),
  //         ),
  //       ],
  //     ),
  //   );
  //   if (result != null && result.isNotEmpty) {
  //     ref.read(generalSettingsProvider.notifier).setKdsName(result);
  //   }
  // }



  Future<void> _editKdsName(
  BuildContext context,
  WidgetRef ref,
  String current,
) async {
  final controller = TextEditingController(text: current);

  final newName = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('KDS Name'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Enter KDS name'),
        onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, controller.text.trim()),
          child: const Text('Save'),
        ),
      ],
    ),
  );

  // dialog cancel / empty hole kichu korbo na
  if (newName == null || newName.isEmpty || newName == current) return;

  // ↓↓↓ EI KHANE renameKds call ↓↓↓
  final ok = await ref.read(generalSettingsProvider.notifier).renameKds(newName);

  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Name update failed — try again')),
    );
  }
}

  // ── Generic option picker ───────────────────────────────────
  Future<void> _pickOption(
    BuildContext context, {
    required String title,
    required List<String> options,
    List<String>? optionLabels,
    required String current,
    required ValueChanged<String> onSelected,
  }) async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final t = Theme.of(ctx);
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320, maxHeight: 460),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    title,
                    style: t.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Divider(height: 1, color: t.dividerColor),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: List.generate(options.length, (i) {
                      final opt = options[i];
                      final label =
                          optionLabels != null ? optionLabels[i] : opt;
                      final isSelected = opt == current;
                      return ListTile(
                        leading: isSelected
                            ? Icon(Icons.check, color: t.colorScheme.primary)
                            : const SizedBox(width: 24),
                        title: Text(label),
                        onTap: () => Navigator.of(ctx).pop(opt),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (result != null) onSelected(result);
  }
}

// ── Group container ───────────────────────────────────────────────────────────
class _Group extends StatelessWidget {
  const _Group({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: t.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.dividerColor),
      ),
      child: Column(children: children),
    );
  }
}

// ── Info row ──────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(child: Text(label, style: t.textTheme.titleMedium)),
              Text(value, style: t.textTheme.bodyMedium),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: t.dividerColor),
      ],
    );
  }
}

// ── Nav row — tap  edit/picker ───────────────────────────────────────────
class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.label,
    required this.value,
    required this.onTap,
    this.isLast = false,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(child: Text(label, style: t.textTheme.titleMedium)),
                Text(value, style: t.textTheme.bodyMedium),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right,
                    size: 20, color: t.colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
        if (!isLast) Divider(height: 1, color: t.dividerColor),
      ],
    );
  }
}



// ── Toggle row (switch) ───────────────────────────────────────
class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.isLast = false,
  });

  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: t.textTheme.titleMedium),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: t.textTheme.bodySmall?.copyWith(
                          color: t.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Switch(value: value, onChanged: onChanged),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: t.dividerColor),
      ],
    );
  }
}
