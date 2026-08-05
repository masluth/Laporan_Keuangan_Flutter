import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'status_chip.dart';

class TransactionTile extends StatelessWidget {
  final String title;
  final String date;
  final String amount;
  final bool isExpense;
  final TransactionStatus? status;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.title,
    required this.date,
    required this.amount,
    this.isExpense = false,
    this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          margin: const EdgeInsets.only(bottom: 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: AppColors.lightBorder, width: 1.0),
          ),
          child: Row(
            children: [
              Container(
                width: 42.0,
                height: 42.0,
                decoration: BoxDecoration(
                  color: isExpense ? AppColors.expenseRedBg : AppColors.incomeGreenBg,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(
                  isExpense ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                  color: isExpense ? AppColors.expenseRed : AppColors.incomeGreen,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      date,
                      style: AppTextStyles.bodySmall(),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isExpense ? '-' : '+'}$amount',
                    style: GoogleFonts.inter(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w700,
                      color: isExpense ? AppColors.expenseRed : AppColors.incomeGreen,
                    ),
                  ),
                  if (status != null) ...[
                    const SizedBox(height: 4.0),
                    StatusChip(status: status!),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
