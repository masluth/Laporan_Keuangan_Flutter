import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../../security/providers/security_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  // =========================================================
  // LOGOUT
  // =========================================================

  Future<void> _logout(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Keluar dari Akun?',
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari aplikasi Revenant Finance?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                false,
              );
            },
            child: const Text(
              'Batal',
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expenseRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(
                context,
                true,
              );
            },
            child: const Text(
              'Keluar',
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(authProvider.notifier)
          .logout();

      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  // =========================================================
  // TWO STEP VERIFICATION
  // =========================================================

  void _showTwoStepVerificationDialog(
    BuildContext context,
    WidgetRef ref,
  ) {
    final securityState = ref.read(
      securityProvider,
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Verifikasi Dua Langkah',
            style: GoogleFonts.inter(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(
                  12.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(
                    alpha: 0.08,
                  ),
                  borderRadius: BorderRadius.circular(
                    12.0,
                  ),
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  size: 32.0,
                  color: AppColors.primaryBlue,
                ),
              ),

              const SizedBox(
                height: 16.0,
              ),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aktifkan Verifikasi Dua Langkah',
                          style: GoogleFonts.inter(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            color:
                                AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(
                          height: 4.0,
                        ),
                        Text(
                          'Tambahkan lapisan keamanan tambahan saat login.',
                          style: GoogleFonts.inter(
                            fontSize: 11.0,
                            color:
                                AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    width: 8.0,
                  ),

                  Switch(
                    value:
                        securityState.isTwoFactorEnabled,
                    activeThumbColor:
                        AppColors.primaryBlue,
                    onChanged: securityState.isLoading
                        ? null
                        : (value) {
                            Navigator.pop(
                              dialogContext,
                            );

                            _showTwoFactorPinSetupDialog(
                              context,
                              ref,
                              value,
                            );
                          },
                  ),
                ],
              ),

              const SizedBox(
                height: 8.0,
              ),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  securityState.isTwoFactorEnabled
                      ? 'Verifikasi dua langkah aktif.'
                      : 'Verifikasi dua langkah tidak aktif.',
                  style: GoogleFonts.inter(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    color:
                        securityState.isTwoFactorEnabled
                            ? AppColors.incomeGreen
                            : AppColors.textMutedLight,
                  ),
                ),
              ),

              if (securityState.isLoading) ...[
                const SizedBox(
                  height: 12.0,
                ),
                const SizedBox(
                  width: 18.0,
                  height: 18.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                  ),
                ),
              ],

              if (securityState.error != null) ...[
                const SizedBox(
                  height: 12.0,
                ),
                Text(
                  securityState.error!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11.0,
                    color: AppColors.expenseRed,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: Text(
                'Tutup',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // PIN SETUP DIALOG
  // =========================================================

  void _showTwoFactorPinSetupDialog(
    BuildContext context,
    WidgetRef ref,
    bool enable,
  ) {
    if (!enable) {
      _disableTwoFactor(
        context,
        ref,
      );

      return;
    }

    final pinController =
        TextEditingController();

    final confirmPinController =
        TextEditingController();

    bool obscurePin = true;
    bool obscureConfirmPin = true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: Text(
                'Buat PIN Keamanan',
                style: GoogleFonts.inter(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Buat PIN 6 digit yang akan digunakan sebagai verifikasi tambahan saat login.',
                    style: GoogleFonts.inter(
                      fontSize: 12.0,
                      color:
                          AppColors.textSecondaryLight,
                    ),
                  ),

                  const SizedBox(
                    height: 18.0,
                  ),

                  // =====================================================
                  // PIN
                  // =====================================================

                  TextField(
                    controller: pinController,
                    keyboardType:
                        TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter
                          .digitsOnly,
                      LengthLimitingTextInputFormatter(
                        6,
                      ),
                    ],
                    maxLength: 6,
                    obscureText: obscurePin,
                    decoration: InputDecoration(
                      labelText: 'PIN 6 Digit',
                      counterText: '',
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setDialogState(() {
                            obscurePin =
                                !obscurePin;
                          });
                        },
                        icon: Icon(
                          obscurePin
                              ? Icons
                                  .visibility_outlined
                              : Icons
                                  .visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 12.0,
                  ),

                  // =====================================================
                  // KONFIRMASI PIN
                  // =====================================================

                  TextField(
                    controller:
                        confirmPinController,
                    keyboardType:
                        TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter
                          .digitsOnly,
                      LengthLimitingTextInputFormatter(
                        6,
                      ),
                    ],
                    maxLength: 6,
                    obscureText:
                        obscureConfirmPin,
                    decoration: InputDecoration(
                      labelText:
                          'Konfirmasi PIN',
                      counterText: '',
                      prefixIcon: const Icon(
                        Icons.lock_reset_outlined,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setDialogState(() {
                            obscureConfirmPin =
                                !obscureConfirmPin;
                          });
                        },
                        icon: Icon(
                          obscureConfirmPin
                              ? Icons
                                  .visibility_outlined
                              : Icons
                                  .visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child: const Text(
                    'Batal',
                  ),
                ),

                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.primaryBlue,
                    foregroundColor:
                        Colors.white,
                  ),
                  onPressed: () async {
                    final pin =
                        pinController.text.trim();

                    final confirmPin =
                        confirmPinController
                            .text
                            .trim();

                    // =================================================
                    // VALIDASI PIN
                    // =================================================

                    if (!RegExp(
                      r'^\d{6}$',
                    ).hasMatch(pin)) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'PIN harus terdiri dari 6 digit angka.',
                          ),
                        ),
                      );

                      return;
                    }

                    // =================================================
                    // VALIDASI KONFIRMASI
                    // =================================================

                    if (!RegExp(
                      r'^\d{6}$',
                    ).hasMatch(confirmPin)) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Konfirmasi PIN harus terdiri dari 6 digit angka.',
                          ),
                        ),
                      );

                      return;
                    }

                    // =================================================
                    // CEK PIN
                    // =================================================

                    if (pin != confirmPin) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Konfirmasi PIN tidak cocok.',
                          ),
                        ),
                      );

                      return;
                    }

                    // =================================================
                    // ENABLE 2FA
                    // =================================================

                    final success =
                        await ref
                            .read(
                              securityProvider
                                  .notifier,
                            )
                            .enableTwoFactor(
                              pin,
                            );

                    if (!context.mounted) {
                      return;
                    }

                    if (success) {
                      Navigator.pop(
                        dialogContext,
                      );

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Verifikasi dua langkah berhasil diaktifkan.',
                          ),
                        ),
                      );
                    } else {
                      final error =
                          ref
                              .read(
                                securityProvider,
                              )
                              .error ??
                          'Gagal mengaktifkan verifikasi dua langkah.';

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        SnackBar(
                          content: Text(
                            error,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Simpan PIN',
                  ),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() {
      pinController.dispose();
      confirmPinController.dispose();
    });
  }

  // =========================================================
  // DISABLE TWO FACTOR
  // =========================================================

  Future<void> _disableTwoFactor(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final pinController =
        TextEditingController();

    bool obscurePin = true;

    final pin = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: Text(
                'Nonaktifkan 2FA',
                style: GoogleFonts.inter(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Masukkan PIN keamanan 6 digit untuk menonaktifkan verifikasi dua langkah.',
                    style: GoogleFonts.inter(
                      fontSize: 12.0,
                      color:
                          AppColors.textSecondaryLight,
                    ),
                  ),

                  const SizedBox(
                    height: 18.0,
                  ),

                  // =================================================
                  // PIN NONAKTIFKAN
                  // =================================================

                  TextField(
                    controller: pinController,
                    keyboardType:
                        TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter
                          .digitsOnly,
                      LengthLimitingTextInputFormatter(
                        6,
                      ),
                    ],
                    maxLength: 6,
                    obscureText: obscurePin,
                    decoration: InputDecoration(
                      labelText: 'PIN 6 Digit',
                      counterText: '',
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setDialogState(() {
                            obscurePin =
                                !obscurePin;
                          });
                        },
                        icon: Icon(
                          obscurePin
                              ? Icons
                                  .visibility_outlined
                              : Icons
                                  .visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      null,
                    );
                  },
                  child: const Text(
                    'Batal',
                  ),
                ),

                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.expenseRed,
                    foregroundColor:
                        Colors.white,
                  ),
                  onPressed: () {
                    final enteredPin =
                        pinController.text.trim();

                    if (!RegExp(
                      r'^\d{6}$',
                    ).hasMatch(enteredPin)) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'PIN harus terdiri dari 6 digit angka.',
                          ),
                        ),
                      );

                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      enteredPin,
                    );
                  },
                  child: const Text(
                    'Nonaktifkan',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    pinController.dispose();

    if (pin == null) {
      return;
    }

    final success = await ref
        .read(
          securityProvider.notifier,
        )
        .disableTwoFactor(
          pin,
        );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Verifikasi dua langkah berhasil dinonaktifkan.'
              : 'PIN salah atau gagal menonaktifkan verifikasi dua langkah.',
        ),
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final authState = ref.watch(
      authProvider,
    );

    final securityState = ref.watch(
      securityProvider,
    );

    return Scaffold(
      backgroundColor:
          AppColors.lightBg,

      // =====================================================
      // APP BAR
      // =====================================================

      appBar: AppBar(
        backgroundColor:
            AppColors.lightBg,
        elevation: 0,
        title: Text(
          'Profile',
          style:
              AppTextStyles.headlineMedium(),
        ),
      ),

      // =====================================================
      // BODY
      // =====================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
          20.0,
        ),
        child: Column(
          children: [
            // =================================================
            // USER HEADER CARD
            // =================================================

            Container(
              padding:
                  const EdgeInsets.all(
                20.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  20.0,
                ),
                border: Border.all(
                  color:
                      AppColors.lightBorder,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32.0,
                    backgroundColor:
                        AppColors.primaryBlue,
                    child: Text(
                      'AT',
                      style:
                          GoogleFonts.inter(
                        fontSize: 22.0,
                        fontWeight:
                            FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 16.0,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          authState.userName ??
                              'Alex Thompson',
                          style:
                              GoogleFonts.inter(
                            fontSize: 18.0,
                            fontWeight:
                                FontWeight.bold,
                            color: AppColors
                                .textPrimaryLight,
                          ),
                        ),

                        const SizedBox(
                          height: 2.0,
                        ),

                        Text(
                          'Owner, Green Garden UMKM',
                          style:
                              GoogleFonts.inter(
                            fontSize: 13.0,
                            color: AppColors
                                .textSecondaryLight,
                          ),
                        ),

                        const SizedBox(
                          height: 4.0,
                        ),

                        Text(
                          authState.email ??
                              'alex.thompson@greengarden.id',
                          style:
                              GoogleFonts.inter(
                            fontSize: 12.0,
                            color: AppColors
                                .textMutedLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 16.0,
            ),

            // =================================================
            // SECURITY BADGE
            // =================================================

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 14.0,
              ),
              decoration: BoxDecoration(
                color:
                    AppColors.darkNavyBg,
                borderRadius:
                    BorderRadius.circular(
                  16.0,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.all(
                      8.0,
                    ),
                    decoration:
                        BoxDecoration(
                      color: AppColors
                          .incomeGreen
                          .withValues(
                        alpha: 0.2,
                      ),
                      shape:
                          BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      color: AppColors
                          .incomeGreen,
                      size: 20.0,
                    ),
                  ),

                  const SizedBox(
                    width: 14.0,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'End-to-End System',
                          style:
                              GoogleFonts.inter(
                            fontSize: 13.0,
                            fontWeight:
                                FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(
                          height: 2.0,
                        ),

                        Text(
                          'Setiap Data Yang Ada Kami Pastikan Aman Dan Terlindungi.',
                          style:
                              GoogleFonts.inter(
                            fontSize: 11.0,
                            color: AppColors
                                .textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 24.0,
            ),

            // =================================================
            // SETTINGS OPTIONS
            // =================================================

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  16.0,
                ),
                border: Border.all(
                  color:
                      AppColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  // =================================================
                  // EDIT PROFIL UMKM
                  // =================================================

                  _buildSettingTile(
                    icon: Icons
                        .person_outline_rounded,
                    title:
                        'Edit Profil UMKM',
                    onTap: () {},
                  ),

                  const Divider(
                    height: 1,
                    color:
                        AppColors.lightBorder,
                  ),

                  // =================================================
                  // AUTENTIKASI & KEAMANAN
                  // =================================================

                  _buildSettingTile(
                    icon: Icons
                        .security_outlined,
                    title:
                        'Autentikasi & Keamanan',
                    trailing:
                        securityState
                                .isTwoFactorEnabled
                            ? Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal:
                                      8.0,
                                  vertical:
                                      4.0,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color: AppColors
                                      .incomeGreen
                                      .withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    6.0,
                                  ),
                                ),
                                child: Text(
                                  'Aktif',
                                  style:
                                      GoogleFonts.inter(
                                    fontSize:
                                        10.0,
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                    color: AppColors
                                        .incomeGreen,
                                  ),
                                ),
                              )
                            : null,
                    onTap: () {
                      _showTwoStepVerificationDialog(
                        context,
                        ref,
                      );
                    },
                  ),

                  const Divider(
                    height: 1,
                    color:
                        AppColors.lightBorder,
                  ),

                  // =================================================
                  // BANTUAN & LAYANAN
                  // =================================================

                  _buildSettingTile(
                    icon: Icons
                        .help_outline_rounded,
                    title:
                        'Bantuan & Layanan Pelanggan',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 24.0,
            ),

            // =================================================
            // LOGOUT BUTTON
            // =================================================

            OutlinedButton.icon(
              onPressed: () => _logout(
                context,
                ref,
              ),
              style:
                  OutlinedButton.styleFrom(
                minimumSize:
                    const Size.fromHeight(
                  50,
                ),
                side:
                    const BorderSide(
                  color:
                      AppColors.expenseRed,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12.0,
                  ),
                ),
              ),
              icon: const Icon(
                Icons.logout_rounded,
                color:
                    AppColors.expenseRed,
              ),
              label: Text(
                'Keluar / Logout',
                style:
                    GoogleFonts.inter(
                  fontSize: 15.0,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      AppColors.expenseRed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // SETTING TILE
  // =========================================================

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color:
            AppColors.textPrimaryLight,
        size: 22.0,
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing ??
          const Icon(
            Icons.chevron_right_rounded,
            color:
                AppColors.textMutedLight,
          ),
      onTap: onTap,
    );
  }
}