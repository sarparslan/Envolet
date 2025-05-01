import 'package:envolet_frontend/Widgets/bottomBarWidget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage>
    with SingleTickerProviderStateMixin {
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
            _insightsHeader(),
            const SizedBox(height: 16),
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
        child: BottomNavBarWidget(currentPage: Pages.InsightsPage),
      ),
    );
  }

  Widget _insightsHeader() {
    return const Row(
      children: [
        Text(
          "Insights",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
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
    return SizedBox(
      height: 250,
      child: Card(
        color: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 50,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withOpacity(0.2),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 50,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      switch (value.toInt()) {
                        case 15:
                          return const Text('15');
                        case 16:
                          return const Text('16');
                        case 17:
                          return const Text('17');
                        case 18:
                          return const Text('18');
                        case 19:
                          return const Text('19');
                        case 20:
                          return const Text('20');
                        default:
                          return const SizedBox();
                      }
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 15,
              maxX: 20,
              minY: 0,
              maxY: 400,
              lineBarsData: [
                LineChartBarData(
                  spots: const [
                    FlSpot(15, 200),
                    FlSpot(16, 250),
                    FlSpot(17, 220),
                    FlSpot(18, 300),
                    FlSpot(19, 180),
                    FlSpot(20, 360),
                  ],
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  dotData: FlDotData(show: false),
                ),
                LineChartBarData(
                  spots: const [
                    FlSpot(15, 160),
                    FlSpot(16, 280),
                    FlSpot(17, 200),
                    FlSpot(18, 260),
                    FlSpot(19, 150),
                    FlSpot(20, 340),
                  ],
                  isCurved: true,
                  color: Colors.lightBlueAccent,
                  barWidth: 3,
                  dotData: FlDotData(show: false),
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
    final List<PieChartSectionData> sections = [
      PieChartSectionData(value: 25, title: 'Food', color: Colors.blue),
      PieChartSectionData(value: 15, title: 'Transport', color: Colors.green),
      PieChartSectionData(value: 20, title: 'Lifestyle', color: Colors.purple),
      PieChartSectionData(value: 10, title: 'Health', color: Colors.orange),
      PieChartSectionData(value: 5, title: 'Utilities', color: Colors.teal),
      PieChartSectionData(value: 10, title: 'Shopping', color: Colors.cyan),
      PieChartSectionData(value: 5, title: 'Education', color: Colors.amber),
      PieChartSectionData(
          value: 5, title: 'Entertainment', color: Colors.indigo),
      PieChartSectionData(value: 3, title: 'Travel', color: Colors.redAccent),
      PieChartSectionData(value: 2, title: 'Others', color: Colors.grey),
      PieChartSectionData(value: 2, title: 'Custom', color: Colors.pinkAccent),
      PieChartSectionData(value: 1, title: 'Custom', color: Colors.pink),
      PieChartSectionData(value: 1, title: 'Custom', color: Colors.deepOrange),
      PieChartSectionData(value: 0.5, title: 'Custom', color: Colors.lime),
      PieChartSectionData(value: 0.5, title: 'Custom', color: Colors.brown),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Spending Breakdown',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          AspectRatio(
            aspectRatio: 1.2,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 60,
                sectionsSpace: 2,
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
