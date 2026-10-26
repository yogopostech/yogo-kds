import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/settings_provider.dart';

class RoutingPanel extends ConsumerWidget {
  const RoutingPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final routing = ref.watch(routingProvider);

    final offCount =
        routing.categories.values.where((on) => !on).length;

    return Column(
      children: [
        // ── Header ─────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Text(
            'Routing',
            style: t.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Divider(height: 1, color: t.dividerColor),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // ── Explanation ──────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: t.colorScheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        size: 20, color: t.colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'By default this screen displays all orders it receives. '
                        'Turn off a source or category below to hide those items from this screen.',
                        style: t.textTheme.bodyMedium?.copyWith(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Ordering sources ─────────────────────────
              _SectionLabel('ORDERING SOURCES'),
              Container(
                decoration: _cardDecoration(t),
                child: Column(
                  children: List.generate(routing.sources.length, (i) {
                    final source = routing.sources.keys.elementAt(i);
                    final isLast = i == routing.sources.length - 1;
                    return Column(
                      children: [
                        SwitchListTile(
                          title: Text(source),
                          value: routing.isSourceOn(source),
                          onChanged: (_) => ref
                              .read(routingProvider.notifier)
                              .toggleSource(source),
                        ),
                        if (!isLast)
                          Divider(height: 1, color: t.dividerColor),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 28),

              // ── Categories header + bulk actions ─────────
              Row(
                children: [
                  Expanded(child: _SectionLabel('CATEGORIES')),
                  TextButton(
                    onPressed: () => ref
                        .read(routingProvider.notifier)
                        .enableAllCategories(),
                    child: const Text('All on', style: TextStyle(fontSize: 12)),
                  ),
                  TextButton(
                    onPressed: () => ref
                        .read(routingProvider.notifier)
                        .disableAllCategories(),
                    child:
                        const Text('All off', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              Container(
                decoration: _cardDecoration(t),
                child: Column(
                  children: List.generate(routing.categories.length, (i) {
                    final cat = routing.categories.keys.elementAt(i);
                    final isLast = i == routing.categories.length - 1;
                    return Column(
                      children: [
                        SwitchListTile(
                          title: Text(cat),
                          value: routing.isCategoryOn(cat),
                          onChanged: (_) => ref
                              .read(routingProvider.notifier)
                              .toggleCategory(cat),
                        ),
                        if (!isLast)
                          Divider(height: 1, color: t.dividerColor),
                      ],
                    );
                  }),
                ),
              ),

              if (offCount > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 4),
                  child: Row(
                    children: [
                      Icon(Icons.visibility_off_outlined,
                          size: 15, color: t.colorScheme.error),
                      const SizedBox(width: 6),
                      Text(
                        '$offCount ${offCount == 1 ? "category is" : "categories are"} hidden from this screen',
                        style: t.textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: t.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
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