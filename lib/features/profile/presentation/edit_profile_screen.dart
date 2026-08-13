import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/profil_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _businessNameController;

  @override
  void initState() {
    super.initState();

    final profile = ref.read(profileProvider).profile;

    _fullNameController = TextEditingController(
      text: profile?.fullName ?? '',
    );

    _businessNameController = TextEditingController(
      text: profile?.businessName ?? '',
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _businessNameController.dispose();
    super.dispose();
  }

  // =========================================================
  // SAVE PROFILE
  // =========================================================

  Future<void> _saveProfile() async {
    final fullName = _fullNameController.text.trim();
    final businessName = _businessNameController.text.trim();

    // =======================================================
    // VALIDATION
    // =======================================================

    if (fullName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nama pemilik tidak boleh kosong.',
          ),
        ),
      );

      return;
    }

    if (businessName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nama UMKM tidak boleh kosong.',
          ),
        ),
      );

      return;
    }

    // =======================================================
    // UPDATE PROFILE
    // =======================================================

    final success = await ref
        .read(profileProvider.notifier)
        .updateProfile(
          fullName: fullName,
          businessName: businessName,
        );

    // =======================================================
    // CEK CONTEXT SETELAH ASYNC
    // =======================================================

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profil UMKM berhasil diperbarui.',
          ),
        ),
      );

      Navigator.pop(context, true);
    } else {
      final error =
          ref.read(profileProvider).error ??
          'Gagal memperbarui profil UMKM.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
        ),
      );
    }
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBg,

      // =====================================================
      // APP BAR
      // =====================================================

      appBar: AppBar(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        title: Text(
          'Edit Profil UMKM',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ),

      // =====================================================
      // BODY
      // =====================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =================================================
            // HEADER
            // =================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(
                        alpha: 0.1,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      size: 36,
                      color: AppColors.primaryBlue,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    'Informasi Profil UMKM',
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Perbarui informasi pemilik dan nama usaha Anda.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =================================================
            // NAMA PEMILIK
            // =================================================

            Text(
              'Nama Pemilik',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _fullNameController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'Masukkan nama pemilik',
                prefixIcon: const Icon(
                  Icons.person_outline_rounded,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.lightBorder,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.lightBorder,
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
            ),

            const SizedBox(height: 20),

            // =================================================
            // NAMA UMKM
            // =================================================

            Text(
              'Nama UMKM',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _businessNameController,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                if (!profileState.isLoading) {
                  _saveProfile();
                }
              },
              decoration: InputDecoration(
                hintText: 'Masukkan nama UMKM',
                prefixIcon: const Icon(
                  Icons.storefront_outlined,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.lightBorder,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.lightBorder,
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
            ),

            const SizedBox(height: 12),

            // =================================================
            // INFO
            // =================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(
                  alpha: 0.06,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: AppColors.primaryBlue,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Perubahan profil akan disimpan ke database dan langsung digunakan pada profil akun Anda.',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondaryLight,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // =================================================
            // SAVE BUTTON
            // =================================================

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed:
                    profileState.isLoading
                        ? null
                        : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppColors.primaryBlue.withValues(
                    alpha: 0.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: profileState.isLoading
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
                        'Simpan Perubahan',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 12),

            // =================================================
            // CANCEL BUTTON
            // =================================================

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: profileState.isLoading
                    ? null
                    : () {
                        Navigator.pop(context);
                      },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: AppColors.lightBorder,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Batal',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}