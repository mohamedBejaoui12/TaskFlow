import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/models/user_model.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this.ref) {
    _sub = ref.listen<UserModel?>(sessionProvider, (_, __) {
      notifyListeners();
    });
  }

  final Ref ref;
  late final ProviderSubscription<UserModel?> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}
