import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class TwoFactorScreen extends ConsumerStatefulWidget {
  const TwoFactorScreen({super.key});

  @override
  ConsumerState<TwoFactorScreen> createState() =>
      _TwoFactorScreenState();
}

class _TwoFactorScreenState extends ConsumerState<TwoFactorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  final _pinFocusNode = FocusNode();

  bool _obscurePin = true;

  @override
  void initState() {
    super.initState();

    _pinController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _pinFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  // =========================================================
  // VERIFY PIN
  // =========================================================

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final pin = _pinController.text.trim();

    final success = await ref
        .read(authProvider.notifier)
        .verifyTwoFactor(pin);

    if (!mounted) {
      return;
    }

    if (success) {
      context.go('/dashboard');
    }
  }

  // =========================================================
  // PIN INPUT
  // =========================================================

  void _handlePinChanged(String value) {
    if (value.length > 6) {
      _pinController.text = value.substring(0, 6);
      _pinController.selection = TextSelection.fromPosition(
        TextPosition(
          offset: _pinController.text.length,
        ),
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  // =========================================================
  // PIN DOTS
  // =========================================================

  Widget _buildPinIndicators() {
    final pinLength = _pinController.text.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        6,
        (index) {
          final isFilled = index < pinLength;
          final isCurrent = index == pinLength && pinLength < 6;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 7),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFilled
                  ? AppColors.primaryBlue
                  : Colors.transparent,
              border: Border.all(
                color: isFilled
                    ? AppColors.primaryBlue
                    : isCurrent
                        ? Colors.white
                        : AppColors.textSecondaryDark.withValues(
                            alpha: 0.45,
                          ),
                width: isCurrent ? 2 : 1.5,
              ),
              boxShadow: isFilled
                  ? [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(
                          alpha: 0.35,
                        ),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          );
        },
      ),
    );
  }

  // =========================================================
  // PIN FIELD
  // =========================================================

  Widget _buildPinInput() {
    return Stack(
      children: [
        // Invisible text field.
        //
        // Text tetap benar-benar diketik ke TextField,
        // tetapi tampilannya dibuat transparan karena
        // indikator PIN custom berada di atasnya.
        TextFormField(
          controller: _pinController,
          focusNode: _pinFocusNode,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          maxLength: 6,
          autofocus: true,
          obscureText: true,
          enableSuggestions: false,
          autocorrect: false,
          cursorColor: Colors.transparent,
          style: const TextStyle(
            color: Colors.transparent,
            fontSize: 1,
          ),
          selectionControls: null,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: AppColors.darkNavyBg,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 22,
              horizontal: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.textSecondaryDark.withValues(
                  alpha: 0.25,
                ),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.textSecondaryDark.withValues(
                  alpha: 0.25,
                ),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.primaryBlue,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Colors.redAccent,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Colors.redAccent,
                width: 2,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'PIN wajib diisi';
            }

            if (!RegExp(r'^\d{6}$').hasMatch(value)) {
              return 'PIN harus terdiri dari 6 digit angka';
            }

            return null;
          },
          onChanged: _handlePinChanged,
          onFieldSubmitted: (_) {
            final authState = ref.read(authProvider);

            if (!authState.isLoading) {
              _verify();
            }
          },
        ),

        // Custom PIN indicators.
        Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: _buildPinIndicators(),
            ),
          ),
        ),

        // Visibility button.
        Positioned(
          right: 8,
          top: 0,
          bottom: 0,
          child: IconButton(
            tooltip: _obscurePin
                ? 'Tampilkan PIN'
                : 'Sembunyikan PIN',
            onPressed: () {
              setState(() {
                _obscurePin = !_obscurePin;
              });
            },
            icon: Icon(
              _obscurePin
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.textSecondaryDark,
            ),
          ),
        ),
      ],
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
                    // =====================================================
                    // ICON
                    // =====================================================

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
                        Icons.shield_outlined,
                        size: 42,
                        color: AppColors.primaryBlue,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // =====================================================
                    // TITLE
                    // =====================================================

                    Text(
                      'Two-Factor Authentication',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Masukkan PIN 6 digit untuk melanjutkan.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondaryDark,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 8),

                    if (authState.email != null)
                      Text(
                        authState.email!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: AppColors.primaryBlue,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                    const SizedBox(height: 36),

                    // =====================================================
                    // PIN
                    // =====================================================

                    _buildPinInput(),

                    const SizedBox(height: 12),

                    Text(
                      '${_pinController.text.length}/6 digit',
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondaryDark,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Masukkan 6 digit PIN keamanan Anda.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondaryDark,
                        fontSize: 12,
                      ),
                    ),

                    // =====================================================
                    // ERROR
                    // =====================================================

                    if (authState.error != null) ...[
                      const SizedBox(height: 16),

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
                          borderRadius: BorderRadius.circular(10),
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

                    const SizedBox(height: 24),

                    // =====================================================
                    // VERIFY BUTTON
                    // =====================================================

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed:
                            authState.isLoading ? null : _verify,
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
                                'VERIFY PIN',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // =====================================================
                    // SECURITY INFO
                    // =====================================================

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
                          'Two-Factor Authentication',
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