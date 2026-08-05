import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class ExportReportSheet extends StatefulWidget {
  const ExportReportSheet({super.key});

  @override
  State<ExportReportSheet> createState() => _ExportReportSheetState();
}

class _ExportReportSheetState extends State<ExportReportSheet> {
  String _selectedFormat = 'PDF';
  String _selectedPeriod = 'Bulan Ini (Oktober 2023)';

  void _confirmExport() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Laporan ($_selectedFormat) berhasil diekspor!'),
        backgroundColor: AppColors.incomeGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
        top: 24.0,
        left: 24.0,
        right: 24.0,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: const Icon(Icons.download_rounded, color: AppColors.primaryBlue, size: 24.0),
              ),
              const SizedBox(width: 14.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export Report',
                    style: GoogleFonts.inter(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    'Confirm Export Data',
                    style: GoogleFonts.inter(
                      fontSize: 13.0,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          Text(
            'You are about to export report data.',
            style: GoogleFonts.inter(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 20.0),

          // Format Options
          Text(
            'PILIH FORMAT DOKUMEN',
            style: GoogleFonts.inter(fontSize: 11.0, fontWeight: FontWeight.bold, color: AppColors.textMutedLight),
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('PDF Document (.pdf)')),
                  selected: _selectedFormat == 'PDF',
                  selectedColor: AppColors.primaryBlue,
                  backgroundColor: AppColors.lightSurfaceLow,
                  labelStyle: TextStyle(color: _selectedFormat == 'PDF' ? Colors.white : AppColors.textPrimaryLight),
                  onSelected: (val) => setState(() => _selectedFormat = 'PDF'),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Excel / CSV (.csv)')),
                  selected: _selectedFormat == 'CSV',
                  selectedColor: AppColors.primaryBlue,
                  backgroundColor: AppColors.lightSurfaceLow,
                  labelStyle: TextStyle(color: _selectedFormat == 'CSV' ? Colors.white : AppColors.textPrimaryLight),
                  onSelected: (val) => setState(() => _selectedFormat = 'CSV'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // Period Options
          DropdownButtonFormField<String>(
            initialValue: _selectedPeriod,
            decoration: const InputDecoration(labelText: 'Periode Laporan'),
            items: const [
              DropdownMenuItem(value: 'Bulan Ini (Oktober 2023)', child: Text('Bulan Ini (Oktober 2023)')),
              DropdownMenuItem(value: 'Bulan Lalu (September 2023)', child: Text('Bulan Lalu (September 2023)')),
              DropdownMenuItem(value: 'Tahun 2023', child: Text('Tahun 2023')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _selectedPeriod = val);
            },
          ),
          const SizedBox(height: 24.0),

          // Confirm Export Button
          ElevatedButton(
            onPressed: _confirmExport,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            ),
            child: Text(
              'Confirm Export',
              style: GoogleFonts.inter(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
