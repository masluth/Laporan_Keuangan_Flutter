import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'report_preview_screen.dart';
import '../../../core/theme/app_colors.dart';

class ExportReportSheet extends StatefulWidget {
  const ExportReportSheet({super.key});

  @override
  State<ExportReportSheet> createState() =>
      _ExportReportSheetState();
}

class _ExportReportSheetState
    extends State<ExportReportSheet> {
  String _selectedFormat = 'PDF';

  late String _selectedPeriod;

  @override
  void initState() {
    super.initState();

    // Default periode mengikuti bulan berjalan.
    _selectedPeriod = _getCurrentMonthPeriod();
  }

  // =========================================================
  // FORMAT PERIODE
  // =========================================================

  String _getCurrentMonthPeriod() {
    final now = DateTime.now();

    final monthName = DateFormat(
      'MMMM',
      'id_ID',
    ).format(now);

    return 'Bulan Ini ($monthName ${now.year})';
  }

  String _getPreviousMonthPeriod() {
    final now = DateTime.now();

    final previousMonth = DateTime(
      now.year,
      now.month - 1,
    );

    final monthName = DateFormat(
      'MMMM',
      'id_ID',
    ).format(previousMonth);

    return 'Bulan Lalu ($monthName ${previousMonth.year})';
  }

  String _getCurrentYearPeriod() {
    final now = DateTime.now();

    return 'Tahun Ini (${now.year})';
  }

  // =========================================================
  // PERIOD OPTIONS
  // =========================================================

  List<String> _getPeriodOptions() {
    return [
      _getCurrentMonthPeriod(),
      _getPreviousMonthPeriod(),
      _getCurrentYearPeriod(),
    ];
  }

  // =========================================================
  // CONFIRM EXPORT
  // =========================================================

  void _confirmExport() {
    final selectedFormat = _selectedFormat;
    final selectedPeriod = _selectedPeriod;

    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportPreviewScreen(
          format: selectedFormat,
          period: selectedPeriod,
        ),
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final periodOptions = _getPeriodOptions();

    return Container(
      padding: EdgeInsets.only(
        bottom:
            MediaQuery.of(context).viewInsets.bottom + 24.0,
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
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          // ===================================================
          // HANDLE
          // ===================================================

          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightBorder,
                borderRadius:
                    BorderRadius.circular(2.0),
              ),
            ),
          ),

          const SizedBox(height: 16.0),

          // ===================================================
          // HEADER
          // ===================================================

          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue
                      .withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(12.0),
                ),
                child: const Icon(
                  Icons.download_rounded,
                  color: AppColors.primaryBlue,
                  size: 24.0,
                ),
              ),

              const SizedBox(width: 14.0),

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export Report',
                    style: GoogleFonts.inter(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color:
                          AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    'Confirm Export Data',
                    style: GoogleFonts.inter(
                      fontSize: 13.0,
                      color:
                          AppColors.textSecondaryLight,
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
              color:
                  AppColors.textSecondaryLight,
            ),
          ),

          const SizedBox(height: 20.0),

          // ===================================================
          // FORMAT
          // ===================================================

          Text(
            'PILIH FORMAT DOKUMEN',
            style: GoogleFonts.inter(
              fontSize: 11.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textMutedLight,
            ),
          ),

          const SizedBox(height: 8.0),

          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Center(
                    child: Text(
                      'PDF Document (.pdf)',
                    ),
                  ),
                  selected:
                      _selectedFormat == 'PDF',
                  selectedColor:
                      AppColors.primaryBlue,
                  backgroundColor:
                      AppColors.lightSurfaceLow,
                  labelStyle: TextStyle(
                    color:
                        _selectedFormat == 'PDF'
                            ? Colors.white
                            : AppColors
                                .textPrimaryLight,
                  ),
                  onSelected: (value) {
                    if (!value) return;

                    setState(() {
                      _selectedFormat = 'PDF';
                    });
                  },
                ),
              ),

              const SizedBox(width: 10.0),

              Expanded(
                child: ChoiceChip(
                  label: const Center(
                    child: Text(
                      'Excel / CSV (.csv)',
                    ),
                  ),
                  selected:
                      _selectedFormat == 'CSV',
                  selectedColor:
                      AppColors.primaryBlue,
                  backgroundColor:
                      AppColors.lightSurfaceLow,
                  labelStyle: TextStyle(
                    color:
                        _selectedFormat == 'CSV'
                            ? Colors.white
                            : AppColors
                                .textPrimaryLight,
                  ),
                  onSelected: (value) {
                    if (!value) return;

                    setState(() {
                      _selectedFormat = 'CSV';
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16.0),

          // ===================================================
          // PERIOD
          // ===================================================

          DropdownButtonFormField<String>(
            initialValue: _selectedPeriod,
            decoration: const InputDecoration(
              labelText: 'Periode Laporan',
            ),
            items: periodOptions.map(
              (period) {
                return DropdownMenuItem<String>(
                  value: period,
                  child: Text(period),
                );
              },
            ).toList(),
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _selectedPeriod = value;
              });
            },
          ),

          const SizedBox(height: 24.0),

          // ===================================================
          // CONFIRM
          // ===================================================

          ElevatedButton(
            onPressed: _confirmExport,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  AppColors.primaryBlue,
              minimumSize:
                  const Size.fromHeight(50),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12.0),
              ),
            ),
            child: Text(
              'Confirm Export',
              style: GoogleFonts.inter(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}