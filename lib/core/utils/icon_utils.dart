import 'package:flutter/material.dart';

class IconUtils {
  static const iconMap = <String, IconData>{
    'work': Icons.work_outline,
    'school': Icons.school_outlined,
    'fitness': Icons.fitness_center_outlined,
    'home': Icons.home_outlined,
    'code': Icons.code_outlined,
    'travel': Icons.flight_outlined,
    'marketing': Icons.campaign_outlined,
    'finance': Icons.account_balance_wallet_outlined,
  };

  static IconData fromKey(String key) => iconMap[key] ?? Icons.folder_outlined;
}
