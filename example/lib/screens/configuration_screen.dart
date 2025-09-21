// ignore_for_file: use_build_context_synchronously

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../cubits/configuration_cubit.dart';
import '../routes/app_router.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/dropdown_field.dart';
import '../widgets/multi_select_chips.dart';
import '../widgets/section_card.dart';

@RoutePage()
class ConfigurationScreen extends StatelessWidget {
  const ConfigurationScreen({super.key});

  // Available OAuth options
  static const List<String> _availableResponseTypes = [
    'code',
    'token',
    'id_token',
  ];
  static const List<String> _internalScopes = ['openid', 'profile-pegawai'];
  static const List<String> _externalScopes = ['openid', 'email', 'profile'];
  static const List<String> _availableCodeChallengeMethods = ['S256', 'plain'];

  Future<void> _initializeSDK(
    BuildContext context,
    GlobalKey<FormState> formKey,
  ) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final configCubit = context.read<ConfigurationCubit>();

    try {
      await configCubit.initializeSDK();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              PhosphorIcon(
                PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                color: Colors.white,
                size: 20,
              ),
              const Gap(8),
              const Text('SDK initialized successfully!'),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      context.router.replaceAll([HomeRoute(), OperationsRoute()]);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              PhosphorIcon(
                PhosphorIcons.warning(PhosphorIconsStyle.fill),
                color: Colors.white,
                size: 20,
              ),
              const Gap(8),
              Expanded(child: Text('Initialization failed: $e')),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.router.pop(),
                      icon: PhosphorIcon(
                        PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold),
                        size: 24,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface,
                        foregroundColor: theme.colorScheme.onSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SDK Configuration',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Set up authentication parameters',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, end: 0),

              // Form Content
              Expanded(
                child: Form(
                  key: formKey,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      BlocBuilder<ConfigurationCubit, ConfigurationState>(
                        builder: (context, state) {
                          return Column(
                            children: [
                              SectionCard(
                                icon: PhosphorIcons.globe(
                                  PhosphorIconsStyle.duotone,
                                ),
                                title: 'General Configuration',
                                subtitle: 'Base server settings',
                                delay: 200.ms,
                                children: [_BaseUrlField(state: state)],
                              ),

                              const Gap(24),

                              SectionCard(
                                icon: PhosphorIcons.building(
                                  PhosphorIconsStyle.duotone,
                                ),
                                title: 'Internal BPS Realm',
                                subtitle: 'Configuration for BPS employees',
                                delay: 400.ms,
                                children: [
                                  _InternalClientIdField(state: state),
                                  const Gap(16),
                                  _InternalRedirectUriField(state: state),
                                ],
                              ),

                              const Gap(24),

                              SectionCard(
                                icon: PhosphorIcons.gearSix(
                                  PhosphorIconsStyle.duotone,
                                ),
                                title: 'Internal OAuth Configuration',
                                subtitle:
                                    'Advanced OAuth2 settings for internal realm',
                                delay: 500.ms,
                                children: [
                                  MultiSelectChips(
                                    title: 'Response Types',
                                    icon: PhosphorIcons.code(
                                      PhosphorIconsStyle.duotone,
                                    ),
                                    selectedValues: state.internalResponseTypes,
                                    availableValues: _availableResponseTypes,
                                    onChanged: (values) {
                                      context
                                          .read<ConfigurationCubit>()
                                          .updateInternalResponseTypes(values);
                                    },
                                  ),
                                  const Gap(16),
                                  MultiSelectChips(
                                    title: 'Scopes',
                                    icon: PhosphorIcons.target(
                                      PhosphorIconsStyle.duotone,
                                    ),
                                    selectedValues: state.internalScopes,
                                    availableValues: _internalScopes,
                                    onChanged: (values) {
                                      context
                                          .read<ConfigurationCubit>()
                                          .updateInternalScopes(values);
                                    },
                                  ),
                                  const Gap(16),
                                  DropdownField(
                                    title: 'Code Challenge Method',
                                    icon: PhosphorIcons.shield(
                                      PhosphorIconsStyle.duotone,
                                    ),
                                    value: state.internalCodeChallengeMethod,
                                    items: _availableCodeChallengeMethods,
                                    onChanged: (value) {
                                      context
                                          .read<ConfigurationCubit>()
                                          .updateInternalCodeChallengeMethod(
                                            value!,
                                          );
                                    },
                                  ),
                                ],
                              ),

                              const Gap(24),

                              SectionCard(
                                icon: PhosphorIcons.users(
                                  PhosphorIconsStyle.duotone,
                                ),
                                title: 'External BPS Realm',
                                subtitle: 'Configuration for external users',
                                delay: 600.ms,
                                children: [
                                  _ExternalClientIdField(state: state),
                                  const Gap(16),
                                  _ExternalRedirectUriField(state: state),
                                ],
                              ),

                              const Gap(24),

                              SectionCard(
                                icon: PhosphorIcons.gearSix(
                                  PhosphorIconsStyle.duotone,
                                ),
                                title: 'External OAuth Configuration',
                                subtitle:
                                    'Advanced OAuth2 settings for external realm',
                                delay: 800.ms,
                                children: [
                                  MultiSelectChips(
                                    title: 'Response Types',
                                    icon: PhosphorIcons.code(
                                      PhosphorIconsStyle.duotone,
                                    ),
                                    selectedValues: state.externalResponseTypes,
                                    availableValues: _availableResponseTypes,
                                    onChanged: (values) {
                                      context
                                          .read<ConfigurationCubit>()
                                          .updateExternalResponseTypes(values);
                                    },
                                  ),
                                  const Gap(16),
                                  MultiSelectChips(
                                    title: 'Scopes',
                                    icon: PhosphorIcons.target(
                                      PhosphorIconsStyle.duotone,
                                    ),
                                    selectedValues: state.externalScopes,
                                    availableValues: _externalScopes,
                                    onChanged: (values) {
                                      context
                                          .read<ConfigurationCubit>()
                                          .updateExternalScopes(values);
                                    },
                                  ),
                                  const Gap(16),
                                  DropdownField(
                                    title: 'Code Challenge Method',
                                    icon: PhosphorIcons.shield(
                                      PhosphorIconsStyle.duotone,
                                    ),
                                    value: state.externalCodeChallengeMethod,
                                    items: _availableCodeChallengeMethods,
                                    onChanged: (value) {
                                      context
                                          .read<ConfigurationCubit>()
                                          .updateExternalCodeChallengeMethod(
                                            value!,
                                          );
                                    },
                                  ),
                                ],
                              ),

                              if (state.initializationError != null)
                                Container(
                                  margin: const EdgeInsets.only(top: 24),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    border: Border.all(
                                      color: Colors.red.shade200,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      PhosphorIcon(
                                        PhosphorIcons.warning(
                                          PhosphorIconsStyle.fill,
                                        ),
                                        color: Colors.red.shade600,
                                        size: 20,
                                      ),
                                      const Gap(12),
                                      Expanded(
                                        child: Text(
                                          'Error: ${state.initializationError}',
                                          style: GoogleFonts.inter(
                                            color: Colors.red.shade700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ).animate().fadeIn(duration: 300.ms).shake(),

                              const Gap(32),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Button
              BlocBuilder<ConfigurationCubit, ConfigurationState>(
                builder: (context, state) {
                  return Container(
                        padding: const EdgeInsets.all(24),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: state.isLoading
                                ? null
                                : () => _initializeSDK(context, formKey),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              elevation: 8,
                              shadowColor: theme.colorScheme.primary
                                  .withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: state.isLoading
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                theme.colorScheme.onPrimary,
                                              ),
                                        ),
                                      ),
                                      const Gap(12),
                                      Text(
                                        'Initializing...',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      PhosphorIcon(
                                        PhosphorIcons.rocketLaunch(
                                          PhosphorIconsStyle.duotone,
                                        ),
                                        size: 20,
                                        color: theme.colorScheme.onPrimary,
                                      ),
                                      const Gap(8),
                                      Text(
                                        'Initialize SDK',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 800.ms, duration: 600.ms)
                      .slideY(begin: 0.3, end: 0);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper widgets for text fields that update cubit directly
class _BaseUrlField extends StatefulWidget {
  final ConfigurationState state;

  const _BaseUrlField({required this.state});

  @override
  State<_BaseUrlField> createState() => _BaseUrlFieldState();
}

class _BaseUrlFieldState extends State<_BaseUrlField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.state.baseUrl);
    _controller.addListener(() {
      context.read<ConfigurationCubit>().updateBaseUrl(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: _controller,
      label: 'Base URL',
      hint: 'https://sso.bps.go.id',
      icon: PhosphorIcons.link(PhosphorIconsStyle.duotone),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter base URL';
        }
        if (!Uri.tryParse(value)!.isAbsolute) {
          return 'Please enter a valid URL';
        }
        return null;
      },
    );
  }
}

class _InternalClientIdField extends StatefulWidget {
  final ConfigurationState state;

  const _InternalClientIdField({required this.state});

  @override
  State<_InternalClientIdField> createState() => _InternalClientIdFieldState();
}

class _InternalClientIdFieldState extends State<_InternalClientIdField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.state.internalClientId);
    _controller.addListener(() {
      context.read<ConfigurationCubit>().updateInternalClientId(
        _controller.text,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: _controller,
      label: 'Client ID',
      hint: 'your-internal-client-id',
      icon: PhosphorIcons.key(PhosphorIconsStyle.duotone),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter internal client ID';
        }
        return null;
      },
    );
  }
}

class _InternalRedirectUriField extends StatefulWidget {
  final ConfigurationState state;

  const _InternalRedirectUriField({required this.state});

  @override
  State<_InternalRedirectUriField> createState() =>
      _InternalRedirectUriFieldState();
}

class _InternalRedirectUriFieldState extends State<_InternalRedirectUriField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.state.internalRedirectUri);
    _controller.addListener(() {
      context.read<ConfigurationCubit>().updateInternalRedirectUri(
        _controller.text,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: _controller,
      label: 'Redirect URI',
      hint: 'id.go.bps.examplesso://sso-internal',
      icon: PhosphorIcons.arrowBendDownRight(PhosphorIconsStyle.duotone),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter internal redirect URI';
        }
        return null;
      },
    );
  }
}

class _ExternalClientIdField extends StatefulWidget {
  final ConfigurationState state;

  const _ExternalClientIdField({required this.state});

  @override
  State<_ExternalClientIdField> createState() => _ExternalClientIdFieldState();
}

class _ExternalClientIdFieldState extends State<_ExternalClientIdField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.state.externalClientId);
    _controller.addListener(() {
      context.read<ConfigurationCubit>().updateExternalClientId(
        _controller.text,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: _controller,
      label: 'Client ID',
      hint: 'your-external-client-id',
      icon: PhosphorIcons.key(PhosphorIconsStyle.duotone),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter external client ID';
        }
        return null;
      },
    );
  }
}

class _ExternalRedirectUriField extends StatefulWidget {
  final ConfigurationState state;

  const _ExternalRedirectUriField({required this.state});

  @override
  State<_ExternalRedirectUriField> createState() =>
      _ExternalRedirectUriFieldState();
}

class _ExternalRedirectUriFieldState extends State<_ExternalRedirectUriField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.state.externalRedirectUri);
    _controller.addListener(() {
      context.read<ConfigurationCubit>().updateExternalRedirectUri(
        _controller.text,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: _controller,
      label: 'Redirect URI',
      hint: 'id.go.bps.examplesso://sso-eksternal',
      icon: PhosphorIcons.arrowBendDownRight(PhosphorIconsStyle.duotone),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter external redirect URI';
        }
        return null;
      },
    );
  }
}
