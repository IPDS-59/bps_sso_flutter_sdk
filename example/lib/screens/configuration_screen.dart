// ignore_for_file: use_build_context_synchronously

import 'package:auto_route/auto_route.dart';
import 'package:bps_sso_sdk/bps_sso_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import '../cubits/configuration_cubit.dart';
import '../routes/app_router.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/dropdown_field.dart';
import '../widgets/multi_select_chips.dart';
import '../widgets/section_card.dart';

@RoutePage()
class ConfigurationScreen extends StatelessWidget {
  const ConfigurationScreen({super.key});

  static const _availableResponseTypes = BPSOAuthResponseType.values;
  static const _internalScopes = [
    BPSOAuthScope.openid,
    BPSOAuthScope.profilePegawai,
  ];
  static const _externalScopes = [
    BPSOAuthScope.openid,
    BPSOAuthScope.email,
    BPSOAuthScope.profile,
  ];
  static const _challengeMethods = BPSCodeChallengeMethod.values;

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
              Icon(Icons.check_circle, color: Colors.white, size: 20),
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
              Icon(Icons.warning_amber_outlined, color: Colors.white, size: 20),
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
              theme.colorScheme.primary.withValues(alpha: 0.05),
              theme.colorScheme.secondary.withValues(alpha: 0.05),
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
                      icon: Icon(Icons.arrow_back, size: 24),
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface,
                        foregroundColor: theme.colorScheme.onSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const Gap(12),
                    IconButton(
                      onPressed: () {
                        final configCubit = context.read<ConfigurationCubit>();
                        configCubit.alice.showInspector();
                      },
                      icon: Icon(Icons.desktop_windows_outlined, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        foregroundColor: theme.colorScheme.onPrimaryContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      tooltip: 'HTTP Inspector',
                    ),
                    const Gap(16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SDK Configuration',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Set up authentication parameters',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
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
                                icon: Icons.language,
                                title: 'General Configuration',
                                subtitle: 'Base server settings',
                                delay: 200.ms,
                                children: [_BaseUrlField(state: state)],
                              ),

                              const Gap(24),

                              SectionCard(
                                icon: Icons.business,
                                title: 'Internal BPS Realm',
                                subtitle: 'Configuration for BPS employees',
                                delay: 400.ms,
                                children: [
                                  _InternalClientIdField(state: state),
                                  const Gap(16),
                                  _InternalRedirectHostField(state: state),
                                  const Gap(16),
                                  _InternalRealmField(state: state),
                                ],
                              ),

                              const Gap(24),

                              SectionCard(
                                icon: Icons.settings,
                                title: 'Internal OAuth Configuration',
                                subtitle:
                                    'Advanced OAuth2 settings for internal realm',
                                delay: 500.ms,
                                children: [
                                  MultiSelectChips<BPSOAuthResponseType>(
                                    title: 'Response Types',
                                    icon: Icons.code,
                                    selectedValues: state.internalResponseTypes,
                                    availableValues: _availableResponseTypes,
                                    labelOf: (e) => e.value,
                                    onChanged: context
                                        .read<ConfigurationCubit>()
                                        .updateInternalResponseTypes,
                                  ),
                                  const Gap(16),
                                  MultiSelectChips<BPSOAuthScope>(
                                    title: 'Scopes',
                                    icon: Icons.my_location,
                                    selectedValues: state.internalScopes,
                                    availableValues: _internalScopes,
                                    labelOf: (e) => e.value,
                                    onChanged: context
                                        .read<ConfigurationCubit>()
                                        .updateInternalScopes,
                                  ),
                                  const Gap(16),
                                  DropdownField<BPSCodeChallengeMethod>(
                                    title: 'Code Challenge Method',
                                    icon: Icons.shield_outlined,
                                    value: state.internalCodeChallengeMethod,
                                    items: _challengeMethods,
                                    labelOf: (e) => e.value,
                                    onChanged: (v) => context
                                        .read<ConfigurationCubit>()
                                        .updateInternalCodeChallengeMethod(v!),
                                  ),
                                ],
                              ),

                              const Gap(24),

                              SectionCard(
                                icon: Icons.group_outlined,
                                title: 'External BPS Realm',
                                subtitle: 'Configuration for external users',
                                delay: 600.ms,
                                children: [
                                  _ExternalClientIdField(state: state),
                                  const Gap(16),
                                  _ExternalRedirectHostField(state: state),
                                  const Gap(16),
                                  _ExternalRealmField(state: state),
                                ],
                              ),

                              const Gap(24),

                              SectionCard(
                                icon: Icons.settings,
                                title: 'External OAuth Configuration',
                                subtitle:
                                    'Advanced OAuth2 settings for external realm',
                                delay: 800.ms,
                                children: [
                                  MultiSelectChips<BPSOAuthResponseType>(
                                    title: 'Response Types',
                                    icon: Icons.code,
                                    selectedValues: state.externalResponseTypes,
                                    availableValues: _availableResponseTypes,
                                    labelOf: (e) => e.value,
                                    onChanged: context
                                        .read<ConfigurationCubit>()
                                        .updateExternalResponseTypes,
                                  ),
                                  const Gap(16),
                                  MultiSelectChips<BPSOAuthScope>(
                                    title: 'Scopes',
                                    icon: Icons.my_location,
                                    selectedValues: state.externalScopes,
                                    availableValues: _externalScopes,
                                    labelOf: (e) => e.value,
                                    onChanged: context
                                        .read<ConfigurationCubit>()
                                        .updateExternalScopes,
                                  ),
                                  const Gap(16),
                                  DropdownField<BPSCodeChallengeMethod>(
                                    title: 'Code Challenge Method',
                                    icon: Icons.shield_outlined,
                                    value: state.externalCodeChallengeMethod,
                                    items: _challengeMethods,
                                    labelOf: (e) => e.value,
                                    onChanged: (v) => context
                                        .read<ConfigurationCubit>()
                                        .updateExternalCodeChallengeMethod(v!),
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
                                      Icon(
                                        Icons.warning_amber_outlined,
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
                              shadowColor: theme.colorScheme.primary.withValues(
                                alpha: 0.3,
                              ),
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
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.rocket_launch_outlined,
                                        size: 20,
                                        color: theme.colorScheme.onPrimary,
                                      ),
                                      const Gap(8),
                                      Text(
                                        'Initialize SDK',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
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
      icon: Icons.link,
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
      icon: Icons.key,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter internal client ID';
        }
        return null;
      },
    );
  }
}

class _InternalRedirectHostField extends StatefulWidget {
  final ConfigurationState state;

  const _InternalRedirectHostField({required this.state});

  @override
  State<_InternalRedirectHostField> createState() =>
      _InternalRedirectHostFieldState();
}

class _InternalRedirectHostFieldState
    extends State<_InternalRedirectHostField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.state.internalRedirectHost,
    );
    _controller.addListener(() {
      context.read<ConfigurationCubit>().updateInternalRedirectHost(
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
      label: 'Redirect Host',
      hint: 'your-app-sso-internal',
      icon: Icons.subdirectory_arrow_right,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter internal redirect host';
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
      icon: Icons.key,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter external client ID';
        }
        return null;
      },
    );
  }
}

class _ExternalRedirectHostField extends StatefulWidget {
  final ConfigurationState state;

  const _ExternalRedirectHostField({required this.state});

  @override
  State<_ExternalRedirectHostField> createState() =>
      _ExternalRedirectHostFieldState();
}

class _ExternalRedirectHostFieldState
    extends State<_ExternalRedirectHostField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.state.externalRedirectHost,
    );
    _controller.addListener(() {
      context.read<ConfigurationCubit>().updateExternalRedirectHost(
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
      label: 'Redirect Host',
      hint: 'your-app-sso-eksternal',
      icon: Icons.subdirectory_arrow_right,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter external redirect host';
        }
        return null;
      },
    );
  }
}

class _InternalRealmField extends StatefulWidget {
  const _InternalRealmField({required this.state});

  final ConfigurationState state;

  @override
  State<_InternalRealmField> createState() => _InternalRealmFieldState();
}

class _InternalRealmFieldState extends State<_InternalRealmField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.state.internalRealm);
    _controller.addListener(() {
      context.read<ConfigurationCubit>().updateInternalRealm(_controller.text);
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
      label: 'Realm Name',
      hint: 'pegawai-bps (default)',
      icon: Icons.workspace_premium,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter internal realm name';
        }
        return null;
      },
    );
  }
}

class _ExternalRealmField extends StatefulWidget {
  const _ExternalRealmField({required this.state});

  final ConfigurationState state;

  @override
  State<_ExternalRealmField> createState() => _ExternalRealmFieldState();
}

class _ExternalRealmFieldState extends State<_ExternalRealmField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.state.externalRealm);
    _controller.addListener(() {
      context.read<ConfigurationCubit>().updateExternalRealm(_controller.text);
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
      label: 'Realm Name',
      hint: 'eksternal (default)',
      icon: Icons.workspace_premium,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter external realm name';
        }
        return null;
      },
    );
  }
}
