import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

enum TransactionStatus { lunas, belumLunas }

class StatusChip extends StatelessWidget {
  final TransactionStatus status;
  final String? customLabel;

  const StatusChip({
    super.key,
    required this.status,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLunas = status == TransactionStatus.lunas;
    final String label = customLabel ?? (isLunas ? 'Lunas' : 'Belum Lunas');

    final Color bgColor = isLunas ? AppColors.incomeGreenBg : AppColors.debtAmberBg;
    final Color textColor = isLunas ? const Color(0xFF047857) : const Color(0xFFB45309);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11.0,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
