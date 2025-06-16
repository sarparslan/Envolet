import 'package:envolet_frontend/core/constants.dart';
import 'package:envolet_frontend/models/category_share.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Pie chart showing how a month's spending is split across categories.
class CategoryPieChart extends StatelessWidget {
  const CategoryPieChart({super.key, required this.shares});

  final List<CategoryShare> shares;

  @override
  Widget build(BuildContext context) {
    if (shares.isEmpty) {
      return const Center(
        child: Text(
          'No data available for selected month.',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          AspectRatio(
            aspectRatio: 1.3,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 60,
                sectionsSpace: 2,
                borderData: FlBorderData(show: false),
                sections: [
                  for (final share in shares)
                    PieChartSectionData(
                      value: share.percentage,
                      title: '${share.percentage.toStringAsFixed(1)}%',
                      color: categoryColors[share.category] ?? Colors.grey,
                      radius: 60,
                      titleStyle:
                          const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              for (final share in shares)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 6,
                      backgroundColor:
                          categoryColors[share.category] ?? Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      share.category,
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
