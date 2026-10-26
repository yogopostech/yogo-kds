import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/home_provider.dart';
import '../../../../providers/settings_provider.dart';

class ItemSummaryPanel extends ConsumerWidget {
  const ItemSummaryPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final summary = ref.watch(itemSummaryProvider);
    final position = ref.watch(summaryPositionProvider);

    
    final isBottom = position == SummaryPosition.bottom;

    final entries = summary.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); 

    if (isBottom) {
      return Container(
        height: 90,
        decoration: BoxDecoration(
          color: t.colorScheme.surface,
          border: Border(top: BorderSide(color: t.dividerColor)),
        ),
        child: entries.isEmpty
            ? Center(
                child: Text('No items', style: t.textTheme.bodyMedium))
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 12),
                itemCount: entries.length,
                itemBuilder: (_, i) =>
                    _SummaryChip(name: entries[i].key, qty: entries[i].value),
              ),
      );
    }

    // left / right — vertical panel
    return Container(
      width: 170,
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        border: Border(
          left: position == SummaryPosition.right
              ? BorderSide(color: t.dividerColor)
              : BorderSide.none,
          right: position == SummaryPosition.left
              ? BorderSide(color: t.dividerColor)
              : BorderSide.none,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Text(
              'ITEM SUMMARY',
              style: t.textTheme.labelSmall?.copyWith(
                letterSpacing: 1,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: t.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Divider(height: 1, color: t.dividerColor),
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Text('No items',
                        style: t.textTheme.bodyMedium))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: entries.length,
                    itemBuilder: (_, i) => _SummaryRow(
                        name: entries[i].key, qty: entries[i].value),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Vertical row (left/right) ─────────────────────────────────────────────────
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.name, required this.qty});

  final String name;
  final int qty;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // qty badge
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: t.colorScheme.onSurface,
              borderRadius: BorderRadius.circular(5),
            ),
            alignment: Alignment.center,
            child: Text(
              '$qty',
              style: TextStyle(
                color: t.colorScheme.surface,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: t.textTheme.titleMedium?.copyWith(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Horizontal chip (bottom) ──────────────────────────────────────────────────
class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.name, required this.qty});

  final String name;
  final int qty;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: t.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: t.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: t.colorScheme.onSurface,
              borderRadius: BorderRadius.circular(5),
            ),
            alignment: Alignment.center,
            child: Text(
              '$qty',
              style: TextStyle(
                color: t.colorScheme.surface,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(name, style: t.textTheme.titleMedium?.copyWith(fontSize: 18)),
        ],
      ),
    );
  }
}