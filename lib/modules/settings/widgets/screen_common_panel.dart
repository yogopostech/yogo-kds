import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/settings_provider.dart';

class ScreenCommPanel extends ConsumerWidget {
  const ScreenCommPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailId = ref.watch(screenCommDetailProvider);
    // detail page নাকি list page
    return detailId.isEmpty
        ? const _ScreenListView()
        : _ScreenDetailView(screenId: detailId);
  }
}

// ═══════════════════════════════════════════════════════════════
// LIST VIEW — toggle + my screens + available screens
// ═══════════════════════════════════════════════════════════════
class _ScreenListView extends ConsumerWidget {
  const _ScreenListView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final comm = ref.watch(screenCommProvider);

    return Column(
      children: [
        // ── Header ─────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              const SizedBox(width: 60),
              Expanded(
                child: Text(
                  'Screen Communication',
                  textAlign: TextAlign.center,
                  style: t.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              SizedBox(
                width: 60,
                child: comm.isScanning
                    ? Row(
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: t.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('Scan',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: t.colorScheme.primary)),
                        ],
                      )
                    : null,
              ),
            ],
          ),
        ),
        Divider(height: 1, color: t.dividerColor),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ── Enable toggle ────────────────────────────
              Container(
                decoration: _cardDecoration(t),
                child: SwitchListTile(
                  title: const Text('Screen Communication'),
                  value: comm.enabled,
                  onChanged: (_) =>
                      ref.read(screenCommProvider.notifier).toggle(),
                ),
              ),

              // ── enabled হলে বাকি সব দেখাবে ────────────────
              if (comm.enabled) ...[
                const SizedBox(height: 24),

                // My screens
                _SectionLabel('MY SCREEN COMMUNICATIONS'),
                if (comm.myScreens.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text('No connected screens',
                        style: t.textTheme.bodyMedium),
                  )
                else
                  Container(
                    decoration: _cardDecoration(t),
                    child: Column(
                      children:
                          List.generate(comm.myScreens.length, (i) {
                        final screen = comm.myScreens[i];
                        final isLast = i == comm.myScreens.length - 1;
                        return Column(
                          children: [
                            InkWell(
                              onTap: () => ref
                                  .read(
                                      screenCommDetailProvider.notifier)
                                  .state = screen.id,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(screen.name,
                                          style:
                                              t.textTheme.titleMedium),
                                    ),
                                    Text(
                                      screen.mode.label,
                                      style: t.textTheme.bodyMedium,
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(Icons.chevron_right,
                                        size: 20,
                                        color: t
                                            .colorScheme.onSurfaceVariant),
                                  ],
                                ),
                              ),
                            ),
                            if (!isLast)
                              Divider(
                                  height: 1, color: t.dividerColor),
                          ],
                        );
                      }),
                    ),
                  ),
                const SizedBox(height: 24),

                // Available screens
                _SectionLabel('AVAILABLE SCREENS ON NETWORK'),
                if (comm.availableScreens.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text('Searching for screens...',
                        style: t.textTheme.bodyMedium),
                  )
                else
                  Container(
                    decoration: _cardDecoration(t),
                    child: Column(
                      children: List.generate(
                          comm.availableScreens.length, (i) {
                        final screen = comm.availableScreens[i];
                        final isLast =
                            i == comm.availableScreens.length - 1;
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 9),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(screen.name,
                                        style: t.textTheme.titleMedium),
                                  ),
                                  OutlinedButton(
                                    onPressed: () => ref
                                        .read(
                                            screenCommProvider.notifier)
                                        .connect(screen.id),
                                    child: const Text('Connect'),
                                  ),
                                ],
                              ),
                            ),
                            if (!isLast)
                              Divider(
                                  height: 1, color: t.dividerColor),
                          ],
                        );
                      }),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration(ThemeData t) => BoxDecoration(
        color: t.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.dividerColor),
      );
}

// ═══════════════════════════════════════════════════════════════
// DETAIL VIEW — communication options + remove
// ═══════════════════════════════════════════════════════════════
class _ScreenDetailView extends ConsumerWidget {
  const _ScreenDetailView({required this.screenId});

  final String screenId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final comm = ref.watch(screenCommProvider);
    final screen =
        comm.myScreens.where((s) => s.id == screenId).firstOrNull;

    void goBack() =>
        ref.read(screenCommDetailProvider.notifier).state = '';

    // screen remove হয়ে গেলে back এ ফিরে যাও
    if (screen == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => goBack());
      return const SizedBox();
    }

    return Column(
      children: [
        // ── Header — back + name ─────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: TextButton.icon(
                  onPressed: goBack,
                  icon: const Icon(Icons.chevron_left, size: 20),
                  label: const Text('Back'),
                ),
              ),
              Expanded(
                child: Text(
                  screen.name,
                  textAlign: TextAlign.center,
                  style: t.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 80),
            ],
          ),
        ),
        Divider(height: 1, color: t.dividerColor),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _SectionLabel('COMMUNICATION OPTIONS'),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _ModeCard(
                      icon: Icons.account_tree_outlined,
                      title: 'Multi Clear',
                      description:
                          'When you clear an order from this screen, it will be cleared from other KDS screens on the same network.',
                      isSelected: screen.mode == ScreenCommMode.multiClear,
                      onTap: () => ref
                          .read(screenCommProvider.notifier)
                          .setMode(screenId, ScreenCommMode.multiClear),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ModeCard(
                      icon: Icons.double_arrow_rounded,
                      title: 'Send to Next Screen',
                      description:
                          'When you clear an order from this screen, it will appear on another KDS screen of your choosing on the same network.',
                      isSelected: screen.mode == ScreenCommMode.sendToNext,
                      onTap: () => ref
                          .read(screenCommProvider.notifier)
                          .setMode(screenId, ScreenCommMode.sendToNext),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Remove connection ────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: t.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: t.dividerColor),
                ),
                child: InkWell(
                  onTap: () {
                    ref
                        .read(screenCommProvider.notifier)
                        .remove(screenId);
                    goBack();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 15),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('Remove Connection',
                              style: t.textTheme.titleMedium),
                        ),
                        Text(
                          'Remove',
                          style: TextStyle(
                            color: t.colorScheme.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Icon(Icons.remove,
                            size: 18, color: t.colorScheme.error),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: t.textTheme.labelSmall?.copyWith(
          letterSpacing: 1,
          color: t.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ── Communication mode card ───────────────────────────────────────────────────
class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: t.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? t.colorScheme.primary : t.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 44,
                color: isSelected
                    ? t.colorScheme.primary
                    : t.colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: t.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: t.textTheme.bodyMedium?.copyWith(fontSize: 11),
            ),
            const SizedBox(height: 12),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected
                  ? t.colorScheme.primary
                  : t.colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}