// import 'package:flutter/material.dart';

// class HomeNavCard extends StatelessWidget {
//   const HomeNavCard({
//     super.key,
//     required this.icon,
//     required this.label,
//     required this.subtitle,
//     required this.onTap,
//   });

//   final IconData icon;
//   final String label;
//   final String subtitle;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     final t = Theme.of(context);
//     return Card(
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Row(
//             children: [
//               Container(
//                 width: 48,
//                 height: 48,
//                 decoration: BoxDecoration(
//                   color: t.colorScheme.primary.withOpacity(0.12),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Icon(icon, color: t.colorScheme.primary, size: 24),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(label, style: t.textTheme.titleMedium),
//                     const SizedBox(height: 2),
//                     Text(subtitle, style: t.textTheme.bodyMedium),
//                   ],
//                 ),
//               ),
//               Icon(
//                 Icons.chevron_right_rounded,
//                 color: t.iconTheme.color?.withOpacity(0.4),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
