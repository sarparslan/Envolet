import 'package:envolet_frontend/core/constants.dart';
import 'package:envolet_frontend/models/category_share.dart';
import 'package:envolet_frontend/providers/settings_provider.dart';
import 'package:envolet_frontend/services/api_service.dart';
import 'package:envolet_frontend/widgets/bottom_nav_bar.dart';
import 'package:envolet_frontend/widgets/tracker/ai_suggestion_card.dart';
import 'package:envolet_frontend/widgets/tracker/category_pie_chart.dart';
import 'package:envolet_frontend/widgets/tracker/spending_line_chart.dart';
import 'package:envolet_frontend/widgets/tracker/spending_summary.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';

class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});

  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage>
    with SingleTickerProviderStateMixin {
  static final DateFormat _monthLabelFormat = DateFormat.yMMM();
  static final DateFormat _monthApiFormat = DateFormat('yyyy-MM');

  late final TabController _tabController =
      TabController(length: 2, vsync: this);
  late final ApiService _api = context.read<ApiService>();

  DateTime _selectedMonth = DateTime.now();
  String _selectedCategory = generalCategory;

  List<double> _monthBuckets = [];
  List<double> _averageBuckets = [];
  List<CategoryShare> _categoryShares = [];

  String _suggestion = '';
  bool _isSuggestionLoading = false;

  /// Incremented on every reload so stale responses can be ignored.
  int _requestId = 0;

  double get _monthTotal => _monthBuckets.fold(0, (sum, v) => sum + v);
  double get _monthlyAverage => _averageBuckets.fold(0, (sum, v) => sum + v);

  String get _monthLabel => _monthLabelFormat.format(_selectedMonth);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final requestId = ++_requestId;
    final month = _monthApiFormat.format(_selectedMonth);
    final category =
        _selectedCategory == generalCategory ? null : _selectedCategory;

    try {
      final results = await Future.wait([
        _api.getMonthBuckets(month, category: category),
        _api.getAverageBuckets(category: category),
        _api.getCategoryShares(month),
      ]);
      if (!mounted || requestId != _requestId) return;

      setState(() {
        _monthBuckets = results[0] as List<double>;
        _averageBuckets = results[1] as List<double>;
        _categoryShares = results[2] as List<CategoryShare>;
      });
      await _loadSuggestion(requestId);
    } on ApiException catch (e) {
      if (!mounted || requestId != _requestId) return;
      setState(() => _suggestion = e.message);
    }
  }

  Future<void> _loadSuggestion(int requestId) async {
    setState(() => _isSuggestionLoading = true);

    String suggestion;
    try {
      suggestion = await _api.getSpendingSuggestion(
        category: _selectedCategory,
        month: _monthLabel,
        monthTotal: _monthTotal,
        monthlyAverage: _monthlyAverage,
        currency: context.read<SettingsProvider>().currency,
      );
    } on ApiException catch (e) {
      suggestion = e.statusCode == 503
          ? 'AI suggestions are not configured on the server yet.'
          : 'Could not get a response from Envolet AI. Please try again later.';
    }

    if (!mounted || requestId != _requestId) return;
    setState(() {
      _suggestion = suggestion;
      _isSuggestionLoading = false;
    });
  }

  Future<void> _pickMonth() async {
    final picked = await showMonthPicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;

    setState(() => _selectedMonth = picked);
    _loadData();
  }

  Future<void> _pickCategory() async {
    var selected = _selectedCategory;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      builder: (_) => SizedBox(
        height: 250,
        child: CupertinoPicker(
          backgroundColor: Colors.white,
          itemExtent: 32,
          scrollController: FixedExtentScrollController(
            initialItem: analysisCategories.indexOf(selected),
          ),
          onSelectedItemChanged: (index) =>
              selected = analysisCategories[index],
          children:
              analysisCategories.map((c) => Center(child: Text(c))).toList(),
        ),
      ),
    );

    // Reload once the picker is closed instead of on every scroll step.
    if (!mounted || selected == _selectedCategory) return;
    setState(() => _selectedCategory = selected);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 10),
              TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                indicatorWeight: 3,
                tabs: const [Tab(text: 'Transactions'), Tab(text: 'Analytic')],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    CategoryPieChart(shares: _categoryShares),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBarWidget(currentPage: Pages.tracker),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(Icons.wallet, color: Colors.blue),
            SizedBox(width: 8),
            Text('Tracker', style: TextStyle(fontSize: 16)),
          ],
        ),
        _DropdownButton(label: _monthLabel, onTap: _pickMonth),
      ],
    );
  }

  Widget _buildOverviewTab() {
    final settings = context.watch<SettingsProvider>();
    final currencyIcon =
        currencyIcons[settings.currency] ?? FontAwesomeIcons.moneyBillWave;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SpendingSummaryItem(
                label: 'Average',
                amount: _monthlyAverage,
                color: SpendingLineChart.averageColor,
                currencyIcon: currencyIcon,
              ),
              const SizedBox(width: 24),
              SpendingSummaryItem(
                label: _monthLabel,
                amount: _monthTotal,
                color: SpendingLineChart.monthColor,
                currencyIcon: currencyIcon,
              ),
              const Spacer(),
              _DropdownButton(
                label: _selectedCategory,
                onTap: _pickCategory,
                width: 110,
                fontSize: 11,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SpendingLineChart(
            monthBuckets: _monthBuckets,
            averageBuckets: _averageBuckets,
            currencySymbol: settings.currencySymbol,
          ),
          const SizedBox(height: 30),
          AiSuggestionCard(
            suggestion: _suggestion,
            isLoading: _isSuggestionLoading,
          ),
        ],
      ),
    );
  }
}

class _DropdownButton extends StatelessWidget {
  const _DropdownButton({
    required this.label,
    required this.onTap,
    this.width,
    this.fontSize = 14,
  });

  final String label;
  final VoidCallback onTap;
  final double? width;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        width: width,
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: fontSize, color: Colors.black87),
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.black87),
          ],
        ),
      ),
    );
  }
}
