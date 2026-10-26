import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/settings_provider.dart';

class PrintersPanel extends ConsumerWidget {
  const PrintersPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final printers = ref.watch(printersProvider);

    return Column(
      children: [
        // ── Header + Add button ──────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              const SizedBox(width: 100),
              Expanded(
                child: Text(
                  'Printers',
                  textAlign: TextAlign.center,
                  style: t.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              SizedBox(
                width: 100,
                child: TextButton.icon(
                  onPressed: () => _showAddDialog(context, ref),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: t.dividerColor),

        // ── Printer list ─────────────────────────────────────
        Expanded(
          child: printers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.print_outlined,
                          size: 56,
                          color: t.colorScheme.onSurfaceVariant
                              .withOpacity(0.4)),
                      const SizedBox(height: 12),
                      Text('No printers added',
                          style: t.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text('Tap Add to connect a network printer',
                          style: t.textTheme.bodyMedium),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showAddDialog(context, ref),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Printer'),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: t.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: t.dividerColor),
                      ),
                      child: Column(
                        children: List.generate(printers.length, (i) {
                          final p = printers[i];
                          final isLast = i == printers.length - 1;
                          return Column(
                            children: [
                              _PrinterRow(printer: p),
                              if (!isLast)
                                Divider(
                                    height: 1, color: t.dividerColor),
                            ],
                          );
                        }),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 4),
                      child: Text(
                        'Tap the star to set the default printer',
                        style:
                            t.textTheme.bodyMedium?.copyWith(fontSize: 12),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  // ── Add printer dialog ──────────────────────────────────────
  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final ipController = TextEditingController();
    final portController = TextEditingController(text: '9100');
    var selectedType = PrinterType.epson;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final t = Theme.of(ctx);
        return StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            title: const Text('Add Printer'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Printer Name',
                      hintText: 'e.g. Kitchen Printer',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: ipController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9.]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'IP Address',
                      hintText: 'e.g. 192.168.1.100',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: portController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Port',
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<PrinterType>(
                    value: selectedType,
                    decoration:
                        const InputDecoration(labelText: 'Printer Type'),
                    items: PrinterType.values
                        .map((tp) => DropdownMenuItem(
                              value: tp,
                              child: Text(tp.label),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => selectedType = v);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty ||
                      ipController.text.trim().isEmpty) {
                    return;
                  }
                  Navigator.of(ctx).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: t.colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Add'),
              ),
            ],
          ),
        );
      },
    );

    if (result == true) {
      ref.read(printersProvider.notifier).add(
            KdsPrinter(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: nameController.text.trim(),
              ip: ipController.text.trim(),
              port: int.tryParse(portController.text) ?? 9100,
              type: selectedType,
            ),
          );
    }
  }
}

// ── Single printer row ────────────────────────────────────────────────────────
class _PrinterRow extends ConsumerWidget {
  const _PrinterRow({required this.printer});

  final KdsPrinter printer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // printer icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: t.colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.print_outlined,
                size: 22, color: t.colorScheme.primary),
          ),
          const SizedBox(width: 14),

          // name + details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        printer.name,
                        style: t.textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (printer.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: t.colorScheme.primary.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'DEFAULT',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: t.colorScheme.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${printer.ip}:${printer.port}  •  ${printer.type.label}',
                  style: t.textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),

          // set default
          IconButton(
            tooltip: 'Set as default',
            onPressed: printer.isDefault
                ? null
                : () => ref
                    .read(printersProvider.notifier)
                    .setDefault(printer.id),
            icon: Icon(
              printer.isDefault ? Icons.star : Icons.star_border,
              color: printer.isDefault
                  ? Colors.amber
                  : t.colorScheme.onSurfaceVariant,
            ),
          ),

          // remove
          IconButton(
            tooltip: 'Remove',
            onPressed: () => _confirmRemove(context, ref),
            icon: Icon(Icons.delete_outline, color: t.colorScheme.error),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRemove(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Printer'),
        content: Text('Remove "${printer.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(printersProvider.notifier).remove(printer.id);
    }
  }
}