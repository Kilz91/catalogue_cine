import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

/// Widget formulaire d'inscription
class SignUpForm extends StatefulWidget {
  final bool isLoading;

  const SignUpForm({super.key, this.isLoading = false});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  static final RegExp _emailRegex = RegExp(r'^[^@ ]+@[^@ ]+\.[^@ ]+');
  static const Color _fieldFill = Color(0xFF17324C);
  static const Color _fieldBorder = Color(0xFF2E4B67);
  static const Color _fieldFocus = Color(0xFF6EA8FF);
  static const Color _fieldText = Color(0xFFF4F8FC);
  static const Color _fieldHint = Color(0xFF9BB2C7);

  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _displayNameController;
  late TextEditingController _confirmPasswordController;
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _displayNameController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (widget.isLoading) return;

    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        SignUpEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _displayNameController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fieldDecoration = InputDecoration(
      filled: true,
      fillColor: _fieldFill.withValues(alpha: 0.82),
      labelStyle: const TextStyle(color: _fieldHint),
      hintStyle: const TextStyle(color: _fieldHint),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _fieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _fieldFocus, width: 1.7),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.7),
      ),
    );

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _displayNameController,
            style: const TextStyle(color: _fieldText),
            decoration: fieldDecoration.copyWith(
              labelText: 'Nom d\'affichage',
              hintText: 'Comment on t\'appelle ?',
              prefixIcon: const Icon(Icons.person_outline, color: _fieldHint),
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              final name = value?.trim() ?? '';
              if (name.isEmpty) {
                return 'Nom requis';
              }
              if (name.length < 2) {
                return 'Minimum 2 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _emailController,
            style: const TextStyle(color: _fieldText),
            decoration: fieldDecoration.copyWith(
              labelText: 'Email',
              hintText: 'Entrez votre email',
              prefixIcon: const Icon(
                Icons.alternate_email_rounded,
                color: _fieldHint,
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username, AutofillHints.email],
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty) {
                return 'Email requis';
              }
              if (!_emailRegex.hasMatch(email)) {
                return 'Format email invalide';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _passwordController,
            style: const TextStyle(color: _fieldText),
            decoration: fieldDecoration.copyWith(
              labelText: 'Mot de passe',
              hintText: 'Choisissez un mot de passe',
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: _fieldHint,
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: _fieldHint,
                ),
              ),
            ),
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Mot de passe requis';
              }
              if ((value?.length ?? 0) < 6) {
                return 'Minimum 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _confirmPasswordController,
            style: const TextStyle(color: _fieldText),
            decoration: fieldDecoration.copyWith(
              labelText: 'Confirmer mot de passe',
              hintText: 'Retapez votre mot de passe',
              prefixIcon: const Icon(
                Icons.verified_user_outlined,
                color: _fieldHint,
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: _fieldHint,
                ),
              ),
            ),
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Confirmation requise';
              }
              if (value != _passwordController.text) {
                return 'Les mots de passe ne correspondent pas';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A7BF7),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: widget.isLoading
                    ? const SizedBox(
                        key: ValueKey('loading'),
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Text(key: ValueKey('label'), 'Creer un compte'),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Deja un compte ?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFD7E2EE),
                ),
              ),
              TextButton(
                onPressed: widget.isLoading
                    ? null
                    : () {
                        context.goNamed('login');
                      },
                child: const Text(
                  'Se connecter',
                  style: TextStyle(color: Color(0xFFA8C6FF)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
