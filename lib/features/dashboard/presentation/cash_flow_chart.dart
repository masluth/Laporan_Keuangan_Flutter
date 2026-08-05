import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class CashFlowChart extends StatelessWidget {
  final bool isDarkTheme;

  const CashFlowChart({
    super.key,
    this.isDarkTheme = true,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDarkTheme ? AppColors.darkSlateCard : Colors.white;
    final borderColor = isDarkTheme ? AppColors.darkSlateBorder : AppColors.lightBorder;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CASH FLOW TREND',
                style: GoogleFonts.inter(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: isDarkTheme ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              Row(
                children: [
                  _buildLegendDot(AppColors.primaryBlue, 'Income'),
                  const SizedBox(width: 12),
                  _buildLegendDot(AppColors.secondaryIndigo, 'Expense'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          SizedBox(
            height: 160.0,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDarkTheme ? AppColors.darkSlateBorder : AppColors.lightBorder,
                    strokeWidth: 0.8,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const days = ['18 Oct', '19 Oct', '20 Oct', '21 Oct', '22 Oct', '23 Oct', '24 Oct'];
                        final index = value.toInt();
                        if (index >= 0 && index < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              days[index],
                              style: TextStyle(
                                color: isDarkTheme ? AppColors.textMutedDark : AppColors.textMutedLight,
                                fontSize: 10.0,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 40,
                lineBarsData: [
                  // Income Line
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 15),
                      FlSpot(1, 22),
                      FlSpot(2, 18),
                      FlSpot(3, 30),
                      FlSpot(4, 25),
                      FlSpot(5, 38),
                      FlSpot(6, 35),
                    ],
                    isCurved: true,
                    color: AppColors.primaryBlue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primaryBlue.withValues(alpha: 0.15),
                    ),
                  ),
                  // Expense Line
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 8),
                      FlSpot(1, 12),
                      FlSpot(2, 10),
                      FlSpot(3, 14),
                      FlSpot(4, 9),
                      FlSpot(5, 18),
                      FlSpot(6, 12),
                    ],
                    isCurved: true,
                    color: AppColors.secondaryIndigo,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.secondaryIndigo.withValues(alpha: 0.08),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: isDarkTheme ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            fontSize: 11.0,
          ),
        ),
      ],
    );
  }
}
