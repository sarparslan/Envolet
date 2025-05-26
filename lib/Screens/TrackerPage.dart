import 'package:envolet_frontend/Services/api.dart';
import 'package:envolet_frontend/Util/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:envolet_frontend/Util/Widgets/bottomBarWidget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});

  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage>
    with SingleTickerProviderStateMixin {
  @override
  late TabController _tabController;
  String _selectedDate = DateFormat.yMMM().format(DateTime.now());
  List<FlSpot> selectedMonthSpots = [];
  List<FlSpot> generalAverageSpots = [];
  final transactions = Api.getTransactions();
  String _selectedCategory = 'General';
  List<Map<String, dynamic>> categorySummary = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchChartData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showDatePicker() async {
    final picked = await showMonthPicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = DateFormat.yMMM().format(picked);
      });
      _fetchChartData();
    }
  }

  Future<void> _fetchChartData() async {
    final selectedMonthDate = DateFormat.yMMM().parse(_selectedDate);
    final formattedMonth = DateFormat('yyyy-MM').format(selectedMonthDate);
    final overview = await Api.getMonthlyCategoryPercentages(formattedMonth);

    setState(() {
      categorySummary = overview;
    });

    List<double> selectedMonthBuckets = [];
    List<double> averageBuckets = [];

    if (_selectedCategory == 'General') {
      selectedMonthBuckets = await Api.getGeneralBucketsByMonth(formattedMonth);
      averageBuckets = await Api.getGeneralBuckets();
    } else {
      selectedMonthBuckets = await Api.getCategoryBucketsByMonth(
          _selectedCategory, formattedMonth);
      averageBuckets = await Api.getCategoryBuckets(_selectedCategory);
    }

    final selectedSpots = selectedMonthBuckets.asMap().entries.map((entry) {
      final index = entry.key;
      final value = entry.value;
      return FlSpot(index.toDouble(), value);
    }).toList();

    final averageSpots = averageBuckets.asMap().entries.map((entry) {
      final index = entry.key;
      final value = entry.value;
      return FlSpot(index.toDouble(), value);
    }).toList();

    setState(() {
      selectedMonthSpots = selectedSpots;
      generalAverageSpots = averageSpots;
    });
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.wallet, color: Colors.blue),
            const SizedBox(width: 8),
            const Text('Tracker', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 12),
          ],
        ),
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
                const Icon(Icons.arrow_drop_down, color: Colors.black87),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SizedBox(
          height: 250,
          child: CupertinoPicker(
            backgroundColor: Colors.white,
            itemExtent: 32.0,
            scrollController: FixedExtentScrollController(
              initialItem: categoriesForAnalysis.indexOf(_selectedCategory),
            ),
            onSelectedItemChanged: (int index) {
              setState(() {
                _selectedCategory = categoriesForAnalysis[index];
              });
              _fetchChartData();
            },
            children: categoriesForAnalysis.map((e) => Text(e)).toList(),
          ),
        );
      },
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
          const SizedBox(height: 30),
          _aiSuggestionCard(),
        ],
      ),
    );
  }

  Widget _incomeSpendingRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // General Average
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(width: 4, height: 16, color: Colors.blue.shade900),
                const SizedBox(width: 6),
                const Text(
                  'Average',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${generalAverageSpots.isNotEmpty ? generalAverageSpots.map((e) => e.y).reduce((a, b) => a + b).toInt() ~/ generalAverageSpots.length : 0}\$',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(width: 30),
        // Selected Month
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(width: 4, height: 16, color: Colors.cyan),
                const SizedBox(width: 6),
                Text(
                  _selectedDate,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${selectedMonthSpots.isNotEmpty ? selectedMonthSpots.map((e) => e.y).reduce((a, b) => a + b).toInt() : 0}\$',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(width: 30),
        GestureDetector(
          onTap: _showCategoryPicker,
          child: Container(
            height: 50,
            width: 100, // Sabit genişlik
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    _selectedCategory,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.black87),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.black87),
              ],
            ),
          ),
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
                        final label = isIncome ? 'Average' : 'Selected';
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
                      const labels = ['1-6', '7-12', '13-18', '19-24', '25-31'];
                      return Text(
                        labels[value.toInt()],
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
              minX: 0,
              maxX: 4,
              minY: 0,
              maxY: 500,
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  barWidth: 3,
                  color: Colors.cyan, // Genel ortalama: açık mavi
                  belowBarData: BarAreaData(show: false),
                  dotData: FlDotData(show: true),
                  spots: generalAverageSpots.isNotEmpty
                      ? generalAverageSpots
                      : [FlSpot(15, 200), FlSpot(16, 250)], // default
                ),
                LineChartBarData(
                  isCurved: true,
                  barWidth: 3,
                  color: Colors.blue.shade900, // Seçilen ay: koyu mavi
                  belowBarData: BarAreaData(show: false),
                  dotData: FlDotData(show: true),
                  spots: selectedMonthSpots.isNotEmpty
                      ? selectedMonthSpots
                      : [FlSpot(15, 180), FlSpot(16, 230)], // default
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
          ],
        ),
      ),
    );
  }

  Widget _analyticTab() {
    final Map<String, Color> categoryColorMap = {
      'Food & Drinks': Colors.green,
      'Transportation': Colors.orange,
      'Housing': Colors.blueGrey,
      'Bills': Colors.blue,
      'Health': Colors.redAccent,
      'Entertainment': Colors.purple,
      'Shopping': Colors.teal,
      'Education': Colors.indigo,
      'Travel': Colors.cyan,
    };

    if (categorySummary.isEmpty) {
      return const Center(
        child: Text(
          "No data available for selected month.",
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    final List<Map<String, dynamic>> data = categorySummary;

    final List<PieChartSectionData> sections = data.map((item) {
      final category = item['category'].toString();
      final percentage = (item['percentage'] as num).toDouble();

      return PieChartSectionData(
        value: percentage,
        title: '${percentage.toStringAsFixed(1)}%',
        color: categoryColorMap[category] ?? Colors.grey,
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
            children: data.map((item) {
              final category = item['category'].toString();

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: categoryColorMap[category] ?? Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
