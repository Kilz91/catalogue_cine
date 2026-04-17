import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../auth/domain/entities/user.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

/// Écran d'édition du profil
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _displayNameController;
  late TextEditingController _bioController;
  final _formKey = GlobalKey<FormState>();
  User? _lastKnownUser;
  bool _isSubmitting = false;

  bool get _hasUserInput {
    return _displayNameController.text.isNotEmpty ||
        _bioController.text.isNotEmpty;
  }

  bool get _hasInitializedForm {
    return _lastKnownUser != null || _hasUserInput;
  }

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _bioController = TextEditingController();
    _displayNameController.addListener(_onInputChanged);
    _bioController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _displayNameController.removeListener(_onInputChanged);
    _bioController.removeListener(_onInputChanged);
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _syncFormFromUser(User user) {
    _lastKnownUser = user;

    // N'initialise les champs qu'une fois pour ne pas écraser la saisie en cours.
    if (!_hasUserInput) {
      _displayNameController.text = user.displayName ?? '';
      _bioController.text = user.bio ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileCubit>()..loadProfile(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0D1B2A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D1B2A),
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          titleSpacing: 20,
          title: const Text('Modifier le profil'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.pop(),
            tooltip: 'Retour',
          ),
        ),
        body: _EditProfileBackground(
          child: BlocConsumer<ProfileCubit, ProfileState>(
            listener: (context, state) {
              if (state is ProfileLoadedState) {
                _syncFormFromUser(state.user);

                if (_isSubmitting) {
                  setState(() => _isSubmitting = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profil mis a jour')),
                  );
                  context.pop();
                }
                return;
              }

              if (state is ProfileUpdatingState) {
                _lastKnownUser = state.currentUser;
                return;
              }

              if (state is ProfileErrorState && _isSubmitting) {
                setState(() => _isSubmitting = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Echec de la mise a jour: ${state.message}'),
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is ProfileLoadingState && !_hasInitializedForm) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (state is ProfileErrorState && !_hasInitializedForm) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10253A).withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 50,
                            color: Color(0xFFFF8A80),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.84),
                            ),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<ProfileCubit>().loadProfile();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reessayer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A7BF7),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final currentUser = state is ProfileLoadedState
                  ? state.user
                  : state is ProfileUpdatingState
                  ? state.currentUser
                  : _lastKnownUser;
              final isUpdating = state is ProfileUpdatingState || _isSubmitting;

              return ListView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  if (isUpdating)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: LinearProgressIndicator(
                        color: Color(0xFFAED3FF),
                        backgroundColor: Color(0xFF1B3B58),
                      ),
                    ),
                  _buildAvatarCard(context, currentUser, isUpdating),
                  const SizedBox(height: 14),
                  _buildFormCard(context, isUpdating),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isUpdating ? null : () => context.pop(),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.26),
                            ),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Annuler'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isUpdating ? null : _saveProfile,
                          icon: isUpdating
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(
                            isUpdating ? 'Enregistrement...' : 'Enregistrer',
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            backgroundColor: const Color(0xFF4A7BF7),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarCard(BuildContext context, User? user, bool isUpdating) {
    final fallbackName = (user?.displayName ?? '').trim().isNotEmpty
        ? user!.displayName!.trim()
        : 'Utilisateur';
    final previewName = _displayNameController.text.trim().isEmpty
        ? fallbackName
        : _displayNameController.text.trim();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF10253A).withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFAED3FF).withValues(alpha: 0.7),
                  ),
                ),
                child: CircleAvatar(
                  radius: 52,
                  backgroundColor: const Color(0xFF1B3B58),
                  backgroundImage: user?.profileImageUrl != null
                      ? NetworkImage(user!.profileImageUrl!)
                      : null,
                  child: user?.profileImageUrl == null
                      ? Text(
                          _getInitials(previewName),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 30,
                          ),
                        )
                      : null,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A7BF7),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF10253A),
                      width: 2,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: isUpdating
                        ? null
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Selection d\'image bientot disponible',
                                ),
                              ),
                            );
                          },
                    tooltip: 'Changer la photo',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            previewName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? 'Email indisponible',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, bool isUpdating) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10253A).withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations publiques',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _displayNameController,
              enabled: !isUpdating,
              decoration: _inputDecoration(
                label: 'Nom d\'affichage',
                icon: Icons.person_outline,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le nom est requis';
                }
                if (value.trim().length < 2) {
                  return 'Minimum 2 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _bioController,
              enabled: !isUpdating,
              decoration: _inputDecoration(
                label: 'Biographie',
                icon: Icons.edit_note_outlined,
                hintText: 'Parlez un peu de vous...',
              ),
              maxLines: 4,
              maxLength: 200,
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hintText,
  }) {
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
    );

    return InputDecoration(
      labelText: label,
      hintText: hintText,
      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.52)),
      prefixIcon: Icon(icon, color: const Color(0xFFAED3FF)),
      filled: true,
      fillColor: const Color(0xFF17324C),
      counterStyle: TextStyle(color: Colors.white.withValues(alpha: 0.68)),
      enabledBorder: baseBorder,
      border: baseBorder,
      focusedBorder: baseBorder.copyWith(
        borderSide: const BorderSide(color: Color(0xFF4A7BF7), width: 1.4),
      ),
      errorBorder: baseBorder.copyWith(
        borderSide: const BorderSide(color: Color(0xFFFF8A80)),
      ),
      focusedErrorBorder: baseBorder.copyWith(
        borderSide: const BorderSide(color: Color(0xFFFF8A80), width: 1.4),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    await context.read<ProfileCubit>().updateProfile(
      displayName: _displayNameController.text.trim(),
      bio: _bioController.text.trim(),
    );
  }

  String _getInitials(String value) {
    final parts = value
        .trim()
        .split(' ')
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

class _EditProfileBackground extends StatelessWidget {
  final Widget child;

  const _EditProfileBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0D1B2A),
                  const Color(0xFF1B263B),
                  Colors.blueGrey.shade700,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -80,
          right: -60,
          child: _GlowCircle(
            diameter: 210,
            color: Colors.lightBlueAccent.withValues(alpha: 0.2),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -70,
          child: _GlowCircle(
            diameter: 240,
            color: Colors.tealAccent.withValues(alpha: 0.16),
          ),
        ),
        child,
      ],
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double diameter;
  final Color color;

  const _GlowCircle({required this.diameter, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
