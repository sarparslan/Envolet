import 'package:flutter/material.dart';

import 'package:envolet_frontend/Widgets/bottomBarWidget.dart';
import 'package:fl_chart/fl_chart.dart';

class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});

  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage>
    with SingleTickerProviderStateMixin {
  @override
  late TabController _tabController;
  String _selectedDate = 'This week';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate =
            '${pickedDate.month}/${pickedDate.day}/${pickedDate.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Column(
          children: [
            const SizedBox(height: 50),
            _trackerHeader(),
            const SizedBox(height: 10),
            _tabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _transactionsTab(),
                  _analyticTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.03,
        ),
        child: BottomNavBarWidget(currentPage: Pages.TrackerPage),
      ),
    );
  }

  Widget _trackerHeader() {
    return Row(
      children: [
        const Icon(Icons.wallet, color: Colors.blue),
        const SizedBox(width: 8),
        const Text('Tracker', style: TextStyle(fontSize: 16)),
        const Spacer(),
        GestureDetector(
          onTap: _showDatePicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              border: Border.all(color: Colors.grey.withOpacity(0.4), width: 1),
            ),
            child: Row(
              children: [
                Text(
                  _selectedDate,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Colors.black87,
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.black87,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _tabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: Colors.blue,
      unselectedLabelColor: Colors.grey,
      indicatorColor: Colors.blue,
      indicatorWeight: 3,
      tabs: const [
        Tab(child: Text("Transactions", style: TextStyle(color: Colors.black))),
        Tab(child: Text("Analytic", style: TextStyle(color: Colors.black))),
      ],
    );
  }

  Widget _transactionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _incomeSpendingRow(),
          const SizedBox(height: 16),
          _lineChartCard(),
          const SizedBox(height: 16),
          _aiSuggestionCard(),
        ],
      ),
    );
  }

  Widget _incomeSpendingRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Income
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(width: 4, height: 16, color: Colors.blue.shade900),
                const SizedBox(width: 6),
                const Text(
                  'Income',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              '\$2,500',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(width: 30),
        // Spending
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(width: 4, height: 16, color: Colors.cyan),
                const SizedBox(width: 6),
                const Text(
                  'Spending',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              '\$1,850',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _lineChartCard() {
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
              lineTouchData: LineTouchData(
                handleBuiltInTouches: true,
                touchTooltipData: LineTouchTooltipData(
                    tooltipBorderRadius: BorderRadius.circular(8),
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 10,
                    getTooltipColor: (spot) => Colors.white,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final touchedX = spot.x;
                        final matchingSpot = spot.bar.spots.firstWhere(
                          (s) => s.x == touchedX,
                          orElse: () => FlSpot.nullSpot,
                        );

                        // Spot yoksa gösterme
                        if (matchingSpot == FlSpot.nullSpot) return null;

                        final isIncome = spot.barIndex == 0;
                        final label = isIncome ? 'Income' : 'Spending';
                        final color =
                            isIncome ? Colors.blue.shade900 : Colors.cyan;

                        return LineTooltipItem(
                          '$label: \$${spot.y.toInt()}',
                          TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        );
                      }).toList();
                    }),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withOpacity(0.2),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    interval: 100,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '\$${value.toInt()}',
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              minX: 15,
              maxX: 20,
              minY: 0,
              maxY: 400,
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  barWidth: 3,
                  color: Colors.blue.shade900,
                  belowBarData: BarAreaData(show: false),
                  dotData: FlDotData(show: true),
                  spots: const [
                    FlSpot(15, 200),
                    FlSpot(16, 250),
                    FlSpot(17, 220),
                    FlSpot(18, 300),
                    FlSpot(19, 180),
                    FlSpot(20, 360),
                  ],
                ),
                LineChartBarData(
                  isCurved: true,
                  barWidth: 3,
                  color: Colors.cyan,
                  belowBarData: BarAreaData(show: false),
                  dotData: FlDotData(show: true),
                  spots: const [
                    FlSpot(15, 160),
                    FlSpot(16, 280),
                    FlSpot(17, 200),
                    FlSpot(18, 260),
                    FlSpot(19, 150),
                    FlSpot(20, 340),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _aiSuggestionCard() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.attach_money_rounded,
                  color: Colors.lightBlue,
                  size: 36,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Envolet AI says:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "You are spending way too much money on global food chains. Maybe it’s time to cook your own food, or support local stores!",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // TODO: AI kutusunu kapat
                  },
                  child: const Icon(Icons.close, color: Colors.grey),
                )
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Start now action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  "Start now",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _analyticTab() {
    final List<Map<String, dynamic>> categories = [
      {'label': 'Food', 'value': 25.0, 'color': Colors.blue},
      {'label': 'Transport', 'value': 15.0, 'color': Colors.green},
      {'label': 'Lifestyle', 'value': 20.0, 'color': Colors.purple},
      {'label': 'Health', 'value': 10.0, 'color': Colors.orange},
      {'label': 'Utilities', 'value': 5.0, 'color': Colors.teal},
      {'label': 'Shopping', 'value': 10.0, 'color': Colors.cyan},
      {'label': 'Education', 'value': 5.0, 'color': Colors.amber},
      {'label': 'Entertainment', 'value': 5.0, 'color': Colors.indigo},
      {'label': 'Travel', 'value': 3.0, 'color': Colors.redAccent},
    ];

    final List<PieChartSectionData> sections = categories.map((data) {
      return PieChartSectionData(
        value: data['value'],
        title: '${data['value']}%',
        color: data['color'],
        radius: 60,
        titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          AspectRatio(
            aspectRatio: 1.3,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 60,
                sectionsSpace: 2,
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: categories.map((item) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: item['color'],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(item['label'],
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black87)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
