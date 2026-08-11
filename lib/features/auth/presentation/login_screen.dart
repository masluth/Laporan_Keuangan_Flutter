import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _showingTwoFactorDialog = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // =========================================================
  // LOGIN
  // =========================================================

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final authNotifier = ref.read(authProvider.notifier);

    final success = await authNotifier.login(
      email,
      password,
    );

    if (!mounted) {
      return;
    }

    // =======================================================
    // LOGIN NORMAL
    // =======================================================

    if (success) {
      context.go('/dashboard');
      return;
    }

    // =======================================================
    // CEK 2FA
    // =======================================================

    final authState = ref.read(authProvider);

    if (authState.requiresTwoFactor) {
      await _showTwoFactorDialog();
    }
  }

  // =========================================================
  // TWO FACTOR DIALOG
  // =========================================================

  Future<void> _showTwoFactorDialog() async {
    if (_showingTwoFactorDialog) {
      return;
    }

    _showingTwoFactorDialog = true;

    final pinController = TextEditingController();

    bool obscurePin = true;
    bool isVerifying = false;

    try {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                backgroundColor: AppColors.darkSlateCard,
                surfaceTintColor: Colors.transparent,
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                titlePadding: const EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  8,
                ),
                contentPadding: const EdgeInsets.fromLTRB(
                  24,
                  8,
                  24,
                  8,
                ),
                actionsPadding: const EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  16,
                ),

                // =================================================
                // TITLE
                // =================================================

                title: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(
                          alpha: 0.15,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.security_rounded,
                        color: AppColors.primaryBlue,
                        size: 23,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Verifikasi Keamanan',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                        ),
                      ),
                    ),
                  ],
                ),

                // =================================================
                // CONTENT
                // =================================================

                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Masukkan 6 digit PIN keamanan untuk melanjutkan login.',
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondaryDark,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =================================================
                    // PIN FIELD
                    // =================================================

                    TextField(
                      controller: pinController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      obscureText: obscurePin,
                      autofocus: true,
                      enabled: !isVerifying,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        letterSpacing: 6,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      cursorColor: AppColors.primaryBlue,

                      decoration: InputDecoration(
                        counterText: '',
                        labelText: 'PIN 2FA',

                        labelStyle: const TextStyle(
                          color: AppColors.textSecondaryDark,
                        ),

                        floatingLabelStyle: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),

                        filled: true,

                        fillColor: AppColors.darkNavyBg,

                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.textSecondaryDark,
                        ),

                        suffixIcon: IconButton(
                          onPressed: isVerifying
                              ? null
                              : () {
                                  setDialogState(() {
                                    obscurePin = !obscurePin;
                                  });
                                },
                          color: AppColors.textSecondaryDark,
                          icon: Icon(
                            obscurePin
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.textSecondaryDark
                                .withValues(alpha: 0.25),
                          ),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primaryBlue,
                            width: 1.5,
                          ),
                        ),

                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.textSecondaryDark
                                .withValues(alpha: 0.15),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 15,
                          color: AppColors.textSecondaryDark,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'PIN harus terdiri dari 6 digit angka.',
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondaryDark,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // =================================================
                // ACTIONS
                // =================================================

                actions: [
                  TextButton(
                    onPressed: isVerifying
                        ? null
                        : () async {
                            Navigator.pop(
                              dialogContext,
                              false,
                            );

                            await ref
                                .read(authProvider.notifier)
                                .cancelTwoFactorLogin();
                          },
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColors.primaryBlue.withValues(
                        alpha: 0.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),

                    onPressed: isVerifying
                        ? null
                        : () async {
                            final pin =
                                pinController.text.trim();

                            // =========================================
                            // VALIDASI PIN
                            // =========================================

                            if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
                              ScaffoldMessenger.of(
                                dialogContext,
                              ).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'PIN harus terdiri dari 6 digit angka.',
                                  ),
                                  backgroundColor:
                                      Colors.redAccent,
                                ),
                              );

                              return;
                            }

                            // =========================================
                            // LOADING
                            // =========================================

                            setDialogState(() {
                              isVerifying = true;
                            });

                            // =========================================
                            // VERIFY 2FA
                            // =========================================

                            final success = await ref
                                .read(authProvider.notifier)
                                .verifyTwoFactor(pin);

                            if (!dialogContext.mounted) {
                              return;
                            }

                            // =========================================
                            // BERHASIL
                            // =========================================

                            if (success) {
                              Navigator.pop(
                                dialogContext,
                                true,
                              );

                              return;
                            }

                            // =========================================
                            // GAGAL
                            // =========================================

                            setDialogState(() {
                              isVerifying = false;
                            });

                            final error = ref
                                .read(authProvider)
                                .error;

                            ScaffoldMessenger.of(
                              dialogContext,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(
                                  error ??
                                      'PIN keamanan salah.',
                                ),
                                backgroundColor:
                                    Colors.redAccent,
                              ),
                            );
                          },

                    child: isVerifying
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'VERIFIKASI',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                  ),
                ],
              );
            },
          );
        },
      );

      if (!mounted) {
        return;
      }

      // =========================================================
      // 2FA BERHASIL
      // =========================================================

      if (result == true) {
        context.go('/dashboard');
      }
    } finally {
      pinController.dispose();
      _showingTwoFactorDialog = false;
    }
  }

  // =========================================================
  // FORGOT PASSWORD
  // =========================================================

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(
      text: _emailController.text,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.darkSlateCard,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Forgot Password?',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: resetEmailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(
              color: Colors.white,
            ),
            cursorColor: AppColors.primaryBlue,
            decoration: InputDecoration(
              labelText: 'Email Address',
              labelStyle: const TextStyle(
                color: AppColors.textSecondaryDark,
              ),
              floatingLabelStyle: const TextStyle(
                color: AppColors.primaryBlue,
              ),
              filled: true,
              fillColor: AppColors.darkNavyBg,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: AppColors.textSecondaryDark
                      .withValues(alpha: 0.25),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                resetEmailController.dispose();
              },
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                resetEmailController.dispose();

                ScaffoldMessenger.of(
                  this.context,
                ).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Fitur reset password akan segera tersedia.',
                    ),
                  ),
                );
              },
              child: const Text(
                'Kirim Link',
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.darkNavyBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 32,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // =================================================
                    // LOGO
                    // =================================================

                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(
                          alpha: 0.15,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 42,
                        color: AppColors.primaryBlue,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // =================================================
                    // TITLE
                    // =================================================

                    Text(
                      'Revenant Finance',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Kelola keuangan dengan lebih mudah',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondaryDark,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // =================================================
                    // EMAIL
                    // =================================================

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      cursorColor: AppColors.primaryBlue,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                        ),
                        filled: true,
                        fillColor: AppColors.darkSlateCard,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.textSecondaryDark
                                .withValues(alpha: 0.20),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primaryBlue,
                            width: 1.5,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Email wajib diisi';
                        }

                        if (!value.contains('@')) {
                          return 'Format email tidak valid';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // =================================================
                    // PASSWORD
                    // =================================================

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      cursorColor: AppColors.primaryBlue,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword =
                                  !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors.darkSlateCard,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.textSecondaryDark
                                .withValues(alpha: 0.20),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primaryBlue,
                            width: 1.5,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return 'Password wajib diisi';
                        }

                        return null;
                      },
                      onFieldSubmitted: (_) {
                        if (!authState.isLoading) {
                          _submit();
                        }
                      },
                    ),

                    // =================================================
                    // LOGIN ERROR
                    // =================================================

                    if (authState.error != null) ...[
                      const SizedBox(height: 12),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(
                            alpha: 0.10,
                          ),
                          borderRadius:
                              BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.red.withValues(
                              alpha: 0.30,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 20,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                authState.error!,
                                style: GoogleFonts.inter(
                                  color: Colors.redAccent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // =================================================
                    // FORGOT PASSWORD
                    // =================================================

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showForgotPasswordDialog,
                        child: const Text(
                          'Forgot Password?',
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // =================================================
                    // LOGIN BUTTON
                    // =================================================

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed:
                            authState.isLoading
                                ? null
                                : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),
                        child: authState.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'SIGN IN',
                                style: GoogleFonts.inter(
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // =================================================
                    // SECURITY INFO
                    // =================================================

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.security_rounded,
                          size: 16,
                          color:
                              AppColors.textSecondaryDark,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Secure Authentication',
                          style: GoogleFonts.inter(
                            color:
                                AppColors.textSecondaryDark,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}