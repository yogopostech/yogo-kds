import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primaryOrange = Color(0xFFFF6B2C);

  // Order urgency header colors
  static const urgencyFresh   = Color(0xFF4CAF50); // green  — < 3 min
  static const urgencyCaution = Color(0xFFFFC107); // amber  — 3–7 min
  static const urgencyLate    = Color(0xFFEF5350); // red    — > 7 min

  // Order type badge colors
  static const typeForHere  = Color(0xFF9C27B0); // purple
  static const typeToGo     = Color(0xFFFF9800); // orange
  // static const typePickup   = Color(0xFF2196F3);
  static const typePickup   = Color(0xFF3961e2); // blue 3961e2 
  static const typeDelivery = Color(0xFF009688); // teal
  static const typeCurbside = Color(0xFF607D8B); // blueGrey

  // Modifier text color (shown under item name)
  static const modifierLight = Color(0xFF0097A7);
  static const modifierDark  = Color(0xFF4DD0E1);

  // Tab bar
  static const tabActive   = Color(0xFFFF6B2C);
  static const tabInactive = Color(0xFF9E9E9E);
}