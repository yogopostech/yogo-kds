import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/home_provider.dart';

class BumpToast extends ConsumerStatefulWidget {
  const BumpToast({super.key});

  @override
  ConsumerState<BumpToast> createState() => _BumpToastState();
}

class _BumpToastState extends ConsumerState<BumpToast> {
  @override
  Widget build(BuildContext context) {
    final order = ref.watch(lastBumpedOrderProvider);

    // কোনো bump হয়নি — কিছু দেখাবে না
    if (order == null) return const SizedBox.shrink();

    // 4 second পর auto hide
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && ref.read(lastBumpedOrderProvider)?.id == order.id) {
        ref.read(lastBumpedOrderProvider.notifier).state = null;
      }
    });

     return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50),
        borderRadius: BorderRadius.circular(0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 35),
          const SizedBox(width: 18),
          Text(
            'Completed ${order.customerName}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 26),
          // Undo button
          InkWell(
            onTap: () {
              ref.read(ordersProvider.notifier).undoBump(order.id);
              ref.read(lastBumpedOrderProvider.notifier).state = null;
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Undo',
                style: TextStyle(
                  color: Color.fromARGB(255, 15, 180, 21),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}