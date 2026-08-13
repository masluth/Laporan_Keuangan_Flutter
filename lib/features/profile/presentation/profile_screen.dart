import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../../security/providers/security_provider.dart';
import '../providers/profil_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // =========================================================
  // PROFILE IMAGE
  // =========================================================

  Uint8List? _profileImageBytes;

  final ImagePicker _imagePicker = ImagePicker();

  // =========================================================
  // PICK PROFILE IMAGE
  // =========================================================

  Future<void> _pickProfileImage(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 12.0,
              bottom: 16.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Ganti Foto Profil',
                  style: GoogleFonts.inter(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Pilih sumber foto profil Anda.',
                  style: GoogleFonts.inter(
                    fontSize: 12.0,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 16.0),

                // =================================================
                // GALERI
                // =================================================

                ListTile(
                  leading: Container(
                    width: 42.0,
                    height: 42.0,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: const Icon(
                      Icons.photo_library_outlined,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  title: Text(
                    'Pilih dari Galeri',
                    style: GoogleFonts.inter(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Pilih foto dari galeri perangkat.',
                    style: GoogleFonts.inter(
                      fontSize: 11.0,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(
                      sheetContext,
                      ImageSource.gallery,
                    );
                  },
                ),

                // =================================================
                // KAMERA
                // =================================================

                ListTile(
                  leading: Container(
                    width: 42.0,
                    height: 42.0,
                    decoration: BoxDecoration(
                      color: AppColors.incomeGreen.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: AppColors.incomeGreen,
                    ),
                  ),
                  title: Text(
                    'Ambil Foto',
                    style: GoogleFonts.inter(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Gunakan kamera perangkat.',
                    style: GoogleFonts.inter(
                      fontSize: 11.0,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(
                      sheetContext,
                      ImageSource.camera,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!context.mounted || source == null) {
      return;
    }

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (!context.mounted || pickedFile == null) {
        return;
      }

      final imageBytes = await pickedFile.readAsBytes();

      if (!context.mounted) {
        return;
      }

      setState(() {
        _profileImageBytes = imageBytes;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Foto profil berhasil diperbarui.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal memilih foto profil: $e',
          ),
        ),
      );
    }
  }

  // =========================================================
  // LOGOUT
  // =========================================================

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
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
                  dialogContext,
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
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Keluar',
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    await ref.read(authProvider.notifier).logout();

    if (!context.mounted) {
      return;
    }

    context.go('/login');
  }

  // =========================================================
  // EDIT PROFIL UMKM
  // =========================================================

  Future<void> _showEditProfileDialog(
    BuildContext context,
  ) async {
    final profileState = ref.read(profileProvider);

    final profile = profileState.profile;

    final fullNameController = TextEditingController(
      text: profile?.fullName ?? '',
    );

    final businessNameController = TextEditingController(
      text: profile?.businessName ?? '',
    );

    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Edit Profil UMKM',
            style: GoogleFonts.inter(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Perbarui informasi nama pemilik dan nama UMKM Anda.',
                    style: GoogleFonts.inter(
                      fontSize: 12.0,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // =================================================
                  // NAMA PEMILIK
                  // =================================================

                  TextFormField(
                    controller: fullNameController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Nama Pemilik',
                      hintText: 'Masukkan nama pemilik',
                      prefixIcon: const Icon(
                        Icons.person_outline_rounded,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          12.0,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Nama pemilik wajib diisi.';
                      }

                      if (value.trim().length < 2) {
                        return 'Nama pemilik terlalu pendek.';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 14.0),

                  // =================================================
                  // NAMA UMKM
                  // =================================================

                  TextFormField(
                    controller: businessNameController,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Nama UMKM',
                      hintText: 'Masukkan nama UMKM',
                      prefixIcon: const Icon(
                        Icons.storefront_outlined,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          12.0,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Nama UMKM wajib diisi.';
                      }

                      if (value.trim().length < 2) {
                        return 'Nama UMKM terlalu pendek.';
                      }

                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Batal',
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                final fullName =
                    fullNameController.text.trim();

                final businessName =
                    businessNameController.text.trim();

                final success = await ref
                    .read(profileProvider.notifier)
                    .updateProfile(
                      fullName: fullName,
                      businessName: businessName,
                    );

                if (!dialogContext.mounted) {
                  return;
                }

                if (success) {
                  Navigator.pop(dialogContext);

                  if (!context.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Profil UMKM berhasil diperbarui.',
                      ),
                    ),
                  );
                } else {
                  final error =
                      ref.read(profileProvider).error ??
                          'Gagal memperbarui profil UMKM.';

                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(error),
                    ),
                  );
                }
              },
              child: const Text(
                'Simpan',
              ),
            ),
          ],
        );
      },
    );

    fullNameController.dispose();
    businessNameController.dispose();
  }

  // =========================================================
  // TWO STEP VERIFICATION
  // =========================================================

  void _showTwoStepVerificationDialog(
    BuildContext context,
  ) {
    final securityState = ref.read(securityProvider);

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
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(
                    alpha: 0.08,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  size: 32.0,
                  color: AppColors.primaryBlue,
                ),
              ),

              const SizedBox(height: 16.0),

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
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Tambahkan lapisan keamanan tambahan saat login.',
                          style: GoogleFonts.inter(
                            fontSize: 11.0,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8.0),

                  Switch(
                    value: securityState.isTwoFactorEnabled,
                    activeThumbColor: AppColors.primaryBlue,
                    onChanged: securityState.isLoading
                        ? null
                        : (value) {
                            Navigator.pop(
                              dialogContext,
                            );

                            _showTwoFactorPinSetupDialog(
                              context,
                              value,
                            );
                          },
                  ),
                ],
              ),

              const SizedBox(height: 8.0),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  securityState.isTwoFactorEnabled
                      ? 'Verifikasi dua langkah aktif.'
                      : 'Verifikasi dua langkah tidak aktif.',
                  style: GoogleFonts.inter(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    color: securityState.isTwoFactorEnabled
                        ? AppColors.incomeGreen
                        : AppColors.textMutedLight,
                  ),
                ),
              ),

              if (securityState.isLoading) ...[
                const SizedBox(height: 12.0),
                const SizedBox(
                  width: 18.0,
                  height: 18.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                  ),
                ),
              ],

              if (securityState.error != null) ...[
                const SizedBox(height: 12.0),
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
                Navigator.pop(dialogContext);
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
    bool enable,
  ) {
    if (!enable) {
      _disableTwoFactor(context);
      return;
    }

    final pinController = TextEditingController();
    final confirmPinController = TextEditingController();

    bool obscurePin = true;
    bool obscureConfirmPin = true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            dialogInnerContext,
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
                      color: AppColors.textSecondaryLight,
                    ),
                  ),

                  const SizedBox(height: 18.0),

                  TextField(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
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
                            obscurePin = !obscurePin;
                          });
                        },
                        icon: Icon(
                          obscurePin
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12.0),

                  TextField(
                    controller: confirmPinController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    maxLength: 6,
                    obscureText: obscureConfirmPin,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi PIN',
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
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text(
                    'Batal',
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final pin = pinController.text.trim();

                    final confirmPin =
                        confirmPinController.text.trim();

                    if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
                      ScaffoldMessenger.of(
                        dialogInnerContext,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'PIN harus terdiri dari 6 digit angka.',
                          ),
                        ),
                      );
                      return;
                    }

                    if (!RegExp(r'^\d{6}$')
                        .hasMatch(confirmPin)) {
                      ScaffoldMessenger.of(
                        dialogInnerContext,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Konfirmasi PIN harus terdiri dari 6 digit angka.',
                          ),
                        ),
                      );
                      return;
                    }

                    if (pin != confirmPin) {
                      ScaffoldMessenger.of(
                        dialogInnerContext,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Konfirmasi PIN tidak cocok.',
                          ),
                        ),
                      );
                      return;
                    }

                    final success = await ref
                        .read(
                          securityProvider.notifier,
                        )
                        .enableTwoFactor(pin);

                    if (!dialogInnerContext.mounted) {
                      return;
                    }

                    if (success) {
                      Navigator.pop(dialogContext);

                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Verifikasi dua langkah berhasil diaktifkan.',
                          ),
                        ),
                      );
                    } else {
                      final error =
                          ref.read(securityProvider).error ??
                              'Gagal mengaktifkan verifikasi dua langkah.';

                      ScaffoldMessenger.of(
                        dialogInnerContext,
                      ).showSnackBar(
                        SnackBar(
                          content: Text(error),
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
  ) async {
    final pinController = TextEditingController();

    bool obscurePin = true;

    final pin = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            dialogInnerContext,
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
                      color: AppColors.textSecondaryLight,
                    ),
                  ),

                  const SizedBox(height: 18.0),

                  TextField(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
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
                            obscurePin = !obscurePin;
                          });
                        },
                        icon: Icon(
                          obscurePin
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.expenseRed,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final enteredPin =
                        pinController.text.trim();

                    if (!RegExp(r'^\d{6}$')
                        .hasMatch(enteredPin)) {
                      ScaffoldMessenger.of(
                        dialogInnerContext,
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
        .read(securityProvider.notifier)
        .disableTwoFactor(pin);

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
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final securityState = ref.watch(securityProvider);
    final profileState = ref.watch(profileProvider);

    final profile = profileState.profile;

    final displayName =
        profile?.fullName ??
        authState.userName ??
        'Alex Thompson';

    final businessName =
        profile?.businessName ??
        'Green Garden UMKM';

    final initials = _getInitials(displayName);

    return Scaffold(
      backgroundColor: AppColors.lightBg,

      // =====================================================
      // APP BAR
      // =====================================================

      appBar: AppBar(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        title: Text(
          'Profile',
          style: AppTextStyles.headlineMedium(),
        ),
      ),

      // =====================================================
      // BODY
      // =====================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // =================================================
            // USER HEADER CARD
            // =================================================

            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: AppColors.lightBorder,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // =================================================
                  // PROFILE PHOTO
                  // =================================================

                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 64.0,
                        height: 64.0,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryBlue,
                        ),
                        child: ClipOval(
                          child: _profileImageBytes != null
                              ? Image.memory(
                                  _profileImageBytes!,
                                  width: 64.0,
                                  height: 64.0,
                                  fit: BoxFit.cover,
                                )
                              : Center(
                                  child: Text(
                                    initials,
                                    style: GoogleFonts.inter(
                                      fontSize: 22.0,
                                      fontWeight:
                                          FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                        ),
                      ),

                      // =================================================
                      // CAMERA BUTTON
                      // =================================================

                      Positioned(
                        right: -2.0,
                        bottom: -2.0,
                        child: Material(
                          color: Colors.white,
                          shape: const CircleBorder(),
                          elevation: 2.0,
                          child: InkWell(
                            customBorder:
                                const CircleBorder(),
                            onTap: () {
                              _pickProfileImage(context);
                            },
                            child: Container(
                              width: 28.0,
                              height: 28.0,
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primaryBlue,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.0,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 14.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 16.0),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: GoogleFonts.inter(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color:
                                AppColors.textPrimaryLight,
                          ),
                        ),

                        const SizedBox(height: 2.0),

                        Text(
                          'Owner, $businessName',
                          style: GoogleFonts.inter(
                            fontSize: 13.0,
                            color:
                                AppColors.textSecondaryLight,
                          ),
                        ),

                        const SizedBox(height: 4.0),

                        Text(
                          authState.email ??
                              'alex.thompson@greengarden.id',
                          style: GoogleFonts.inter(
                            fontSize: 12.0,
                            color:
                                AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16.0),

            // =================================================
            // SECURITY BADGE
            // =================================================

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 14.0,
              ),
              decoration: BoxDecoration(
                color: AppColors.darkNavyBg,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: AppColors.incomeGreen.withValues(
                        alpha: 0.2,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      color: AppColors.incomeGreen,
                      size: 20.0,
                    ),
                  ),

                  const SizedBox(width: 14.0),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'End-to-End System',
                          style: GoogleFonts.inter(
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 2.0),

                        Text(
                          'Setiap Data Yang Ada Kami Pastikan Aman Dan Terlindungi.',
                          style: GoogleFonts.inter(
                            fontSize: 11.0,
                            color:
                                AppColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24.0),

            // =================================================
            // SETTINGS OPTIONS
            // =================================================

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: AppColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  _buildSettingTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Edit Profil UMKM',
                    trailing: profileState.isLoading
                        ? const SizedBox(
                            width: 20.0,
                            height: 20.0,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2.0,
                            ),
                          )
                        : null,
                    onTap: profileState.isLoading
                        ? () {}
                        : () {
                            _showEditProfileDialog(
                              context,
                            );
                          },
                  ),

                  const Divider(
                    height: 1,
                    color: AppColors.lightBorder,
                  ),

                  _buildSettingTile(
                    icon: Icons.security_outlined,
                    title: 'Autentikasi & Keamanan',
                    trailing:
                        securityState.isTwoFactorEnabled
                            ? Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color: AppColors
                                      .incomeGreen
                                      .withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                    6.0,
                                  ),
                                ),
                                child: Text(
                                  'Aktif',
                                  style:
                                      GoogleFonts.inter(
                                    fontSize: 10.0,
                                    fontWeight:
                                        FontWeight.w600,
                                    color: AppColors
                                        .incomeGreen,
                                  ),
                                ),
                              )
                            : null,
                    onTap: () {
                      _showTwoStepVerificationDialog(
                        context,
                      );
                    },
                  ),

                  const Divider(
                    height: 1,
                    color: AppColors.lightBorder,
                  ),

                  _buildSettingTile(
                    icon: Icons.help_outline_rounded,
                    title:
                        'Bantuan & Layanan Pelanggan',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24.0),

            // =================================================
            // PROFILE ERROR
            // =================================================

            if (profileState.error != null)
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 16.0,
                ),
                child: Text(
                  profileState.error!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11.0,
                    color: AppColors.expenseRed,
                  ),
                ),
              ),

            // =================================================
            // LOGOUT
            // =================================================

            OutlinedButton.icon(
              onPressed: () {
                _logout(context);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                side: const BorderSide(
                  color: AppColors.expenseRed,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12.0),
                ),
              ),
              icon: const Icon(
                Icons.logout_rounded,
                color: AppColors.expenseRed,
              ),
              label: Text(
                'Keluar / Logout',
                style: GoogleFonts.inter(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.expenseRed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // GET INITIALS
  // =========================================================

  String _getInitials(String name) {
    final trimmed = name.trim();

    if (trimmed.isEmpty) {
      return 'U';
    }

    final parts = trimmed
        .split(RegExp(r'\s+'))
        .where(
          (part) => part.isNotEmpty,
        )
        .toList();

    if (parts.length == 1) {
      return parts.first
          .substring(
            0,
            parts.first.length >= 2 ? 2 : 1,
          )
          .toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'
        .toUpperCase();
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
        color: AppColors.textPrimaryLight,
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
            color: AppColors.textMutedLight,
          ),
      onTap: onTap,
    );
  }
}
