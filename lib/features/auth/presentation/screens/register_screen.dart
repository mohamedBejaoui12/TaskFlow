import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/color_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  Color _avatarColor = const Color(0xFF6C63FF);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickColor() async {
    final selected = await showColorPickerDialog(
      context,
      _avatarColor,
      title: const Text('Avatar Color'),
      width: 40,
      height: 40,
      borderRadius: 20,
      enableShadesSelection: false,
      pickersEnabled: const {
        ColorPickerType.wheel: true,
        ColorPickerType.primary: true,
        ColorPickerType.accent: false,
      },
    );
    if (selected != _avatarColor) {
      setState(() => _avatarColor = selected);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(sessionProvider.notifier).register(
          name: _nameCtrl.text,
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
          avatarColor: ColorUtils.toHex(_avatarColor),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.accountCreated)),
    );
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.register)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(labelText: l10n.name),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(labelText: l10n.email),
                        validator: (v) => (v == null || !v.contains('@')) ? 'Invalid email' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: true,
                        decoration: InputDecoration(labelText: l10n.password),
                        validator: (v) => (v == null || v.length < 4) ? 'Min 4 chars' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmCtrl,
                        obscureText: true,
                        decoration: InputDecoration(labelText: l10n.confirmPassword),
                        validator: (v) => v != _passwordCtrl.text ? 'Passwords do not match' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text('Avatar:'),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _pickColor,
                            child: CircleAvatar(backgroundColor: _avatarColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _submit,
                        child: Text(l10n.register),
                      ),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: Text(l10n.login),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
