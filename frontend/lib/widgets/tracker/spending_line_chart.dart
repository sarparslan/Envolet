import 'dart:math' as math;

import 'package:envolet_frontend/core/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Compares the selected month with the user's average, per day range.
class SpendingLineChart extends StatelessWidget {
  const SpendingLineChart({
    super.key,
    required this.monthBuckets,
    required this.averageBuckets,
    required this.currencySymbol,
  });

  static final Color averageColor = Colors.blue.shade900;
  static const Color monthColor = Colors.cyan;

  final List<double> monthBuckets;
  final List<double> averageBuckets;
  final String currencySymbol;

  List<FlSpot> _toSpots(List<double> buckets) {
    final values = buckets.isEmpty
        ? List<double>.filled(monthBucketLabels.length, 0)
        : buckets;
    return [
      for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i]),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final maxValue =
        [...monthBuckets, ...averageBuckets].fold<double>(0, math.max);
    final maxY = maxValue == 0 ? 500.0 : maxValue * 1.2;
    final yInterval = (maxY / 5).ceilToDouble();

    return AspectRatio(
      aspectRatio: 1.2,
      child: Card(
        color: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LineChart(
            LineChartData(
              backgroundColor: Colors.white,
              minX: 0,
              maxX: monthBucketLabels.length - 1.0,
              minY: 0,
              maxY: maxY,
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  tooltipBorderRadius: BorderRadius.circular(8),
                  tooltipPadding: const EdgeInsets.all(8),
                  tooltipMargin: 10,
                  getTooltipColor: (_) => Colors.white,
                  getTooltipItems: (spots) => spots.map((spot) {
                    final isAverage = spot.barIndex == 0;
                    return LineTooltipItem(
                      '${isAverage ? 'Average' : 'Selected'}: '
                      '${spot.y.toInt()}$currencySymbol',
                      TextStyle(
                        color: isAverage ? averageColor : monthColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    );
                  }).toList(),
                ),
              ),
              gridData: FlGridData(
                drawVerticalLine: true,
                verticalInterval: 1,
                horizontalInterval: yInterval,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: Colors.grey.withValues(alpha: 0.2),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    interval: yInterval,
                    getTitlesWidget: (value, _) => Text(
                      '${value.toInt()}$currencySymbol',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, _) => Text(
                      monthBucketLabels[value.toInt()],
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
                rightTitles: const AxisTitles(),
                topTitles: const AxisTitles(),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              ),
              lineBarsData: [
                _line(_toSpots(averageBuckets), averageColor),
                _line(_toSpots(monthBuckets), monthColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  LineChartBarData _line(List<FlSpot> spots, Color color) => LineChartBarData(
        spots: spots,
        isCurved: true,
        preventCurveOverShooting: true,
        barWidth: 3,
        color: color,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
      );
}
