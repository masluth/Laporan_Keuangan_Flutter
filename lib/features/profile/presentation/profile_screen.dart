import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _logout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari Akun?'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi Revenant Finance?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.expenseRed),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authProvider.notifier).logout();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: AppColors.lightBg,
        title: Text(
          'Profile',
          style: AppTextStyles.headlineMedium(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // User Header Card
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32.0,
                    backgroundColor: AppColors.primaryBlue,
                    child: Text(
                      'AT',
                      style: GoogleFonts.inter(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authState.userName ?? 'Alex Thompson',
                          style: GoogleFonts.inter(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          'Owner, Green Garden UMKM',
                          style: GoogleFonts.inter(
                            fontSize: 13.0,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          authState.email ?? 'alex.thompson@greengarden.id',
                          style: GoogleFonts.inter(
                            fontSize: 12.0,
                            color: AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),

            // Security Badge Box matching Stitch
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              decoration: BoxDecoration(
                color: AppColors.darkNavyBg,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: AppColors.incomeGreen.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield_rounded, color: AppColors.incomeGreen, size: 20.0),
                  ),
                  const SizedBox(width: 14.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enterprise Grade Security Enabled',
                          style: GoogleFonts.inter(
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          'Data keuangan Anda terenkripsi end-to-end dengan Firebase.',
                          style: GoogleFonts.inter(
                            fontSize: 11.0,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // Settings Options List
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Column(
                children: [
                  _buildSettingTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Edit Profil UMKM',
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: AppColors.lightBorder),
                  _buildSettingTile(
                    icon: Icons.security_outlined,
                    title: 'Autentikasi & Keamanan',
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: AppColors.lightBorder),
                  _buildSettingTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Pengaturan Notifikasi',
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: AppColors.lightBorder),
                  _buildSettingTile(
                    icon: Icons.monetization_on_outlined,
                    title: 'Mata Uang & Format (IDR)',
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: AppColors.lightBorder),
                  _buildSettingTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Bantuan & Layanan Pelanggan',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // Logout Button
            OutlinedButton.icon(
              onPressed: () => _logout(context, ref),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                side: const BorderSide(color: AppColors.expenseRed),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              ),
              icon: const Icon(Icons.logout_rounded, color: AppColors.expenseRed),
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

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimaryLight, size: 22.0),
      title: Text(
        title,
        style: GoogleFonts.inter(fontSize: 14.0, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMutedLight),
      onTap: onTap,
    );
  }
}
