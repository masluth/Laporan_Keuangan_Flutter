import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'status_chip.dart';

class TransactionTile extends StatelessWidget {
  final String title;
  final String date;
  final String amount;
  final bool isExpense;
  final TransactionStatus status;

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  // Menentukan apakah tombol Edit dan Delete ditampilkan.
  // Default true supaya halaman Transactions tetap memiliki tombol aksi.
  final bool showActions;

  const TransactionTile({
    super.key,
    required this.title,
    required this.date,
    required this.amount,
    required this.isExpense,
    required this.status,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          // =========================
          // TRANSACTION ICON
          // =========================

          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isExpense
                  ? Colors.red.withValues(alpha: 0.08)
                  : AppColors.primaryBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isExpense
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: isExpense
                  ? Colors.red
                  : AppColors.primaryBlue,
            ),
          ),

          const SizedBox(width: 12),

          // =========================
          // TRANSACTION INFO
          // =========================

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyLarge(
                    color: AppColors.textPrimaryLight,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  date,
                  style: AppTextStyles.bodySmall(
                    color: AppColors.textSecondaryLight,
                  ),
                ),

                const SizedBox(height: 6),

                StatusChip(
                  status: status,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // =========================
          // AMOUNT + ACTION
          // =========================

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isExpense
                      ? Colors.red
                      : AppColors.primaryBlue,
                ),
              ),

              // =========================
              // EDIT + DELETE
              // =========================

              if (showActions) ...[
                const SizedBox(height: 8),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // EDIT
                    IconButton(
                      onPressed: onEdit,
                      tooltip: 'Edit',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      splashRadius: 20,
                      icon: const Icon(
                        Icons.edit_rounded,
                        size: 19,
                        color: AppColors.primaryBlue,
                      ),
                    ),

                    // DELETE
                    IconButton(
                      onPressed: onDelete,
                      tooltip: 'Hapus',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      splashRadius: 20,
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}