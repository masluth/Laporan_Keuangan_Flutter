import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'export_report_sheet.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  void _showExportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ExportReportSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: AppColors.lightBg,
        title: Text(
          'Reports',
          style: AppTextStyles.headlineMedium(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: AppColors.primaryBlue),
            onPressed: () => _showExportSheet(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Export Banner Card matching Stitch
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryBlueDark, AppColors.primaryBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Export Report Data',
                          style: GoogleFonts.inter(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        Text(
                          'Unduh rekap keuangan UMKM lengkap format PDF & Excel CSV.',
                          style: GoogleFonts.inter(
                            fontSize: 13.0,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        ElevatedButton.icon(
                          onPressed: () => _showExportSheet(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primaryBlueDark,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                          ),
                          icon: const Icon(Icons.download_rounded, size: 18.0),
                          label: Text(
                            'Export Report',
                            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  const Icon(Icons.assessment_rounded, size: 64.0, color: Colors.white24),
                ],
              ),
            ),
            const SizedBox(height: 28.0),

            Text(
              'Recent Reports Overview',
              style: AppTextStyles.headlineMedium(),
            ),
            const SizedBox(height: 14.0),

            // Financial Metrics Grid
            Row(
              children: [
                Expanded(
                  child: _buildReportMetricCard(
                    title: 'Health Score',
                    value: '92%',
                    trend: '+4% vs bulan lalu',
                    icon: Icons.favorite_rounded,
                    color: AppColors.incomeGreen,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: _buildReportMetricCard(
                    title: 'Profit Margin',
                    value: '71.6%',
                    trend: 'Sangat Sehat',
                    icon: Icons.pie_chart_rounded,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),

            // Category Breakdown Section
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alokasi Keuangan & Arus Kas',
                    style: GoogleFonts.inter(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  _buildProgressItem('Penjualan Produk', 0.65, 'Rp 29.380.000', AppColors.primaryBlue),
                  const SizedBox(height: 14.0),
                  _buildProgressItem('Inventaris & Stok', 0.20, 'Rp 9.040.000', AppColors.secondaryIndigo),
                  const SizedBox(height: 14.0),
                  _buildProgressItem('Biaya Operasional', 0.10, 'Rp 4.520.000', AppColors.debtAmber),
                  const SizedBox(height: 14.0),
                  _buildProgressItem('Biaya Logistik', 0.05, 'Rp 2.260.000', AppColors.expenseRed),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportMetricCard({
    required String title,
    required String value,
    required String trend,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: AppTextStyles.labelMedium(),
              ),
              Icon(icon, color: color, size: 20.0),
            ],
          ),
          const SizedBox(height: 10.0),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            trend,
            style: AppTextStyles.bodySmall(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, double percentage, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 13.0, fontWeight: FontWeight.w600),
            ),
            Text(
              amount,
              style: GoogleFonts.inter(fontSize: 13.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6.0),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8.0,
            backgroundColor: AppColors.lightSurfaceLow,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
