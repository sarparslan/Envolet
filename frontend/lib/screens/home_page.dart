import 'package:dotted_border/dotted_border.dart';
import 'package:envolet_frontend/models/asset.dart';
import 'package:envolet_frontend/models/transaction.dart';
import 'package:envolet_frontend/providers/session_provider.dart';
import 'package:envolet_frontend/services/api_service.dart';
import 'package:envolet_frontend/utils/dialogs.dart';
import 'package:envolet_frontend/widgets/asset_form_dialog.dart';
import 'package:envolet_frontend/widgets/bottom_nav_bar.dart';
import 'package:envolet_frontend/widgets/credit_card.dart';
import 'package:envolet_frontend/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _latestTransactionCount = 3;

  final _pageController = PageController(viewportFraction: 0.8);
  late final ApiService _api = context.read<ApiService>();

  List<Transaction> _latestTransactions = [];
  List<Asset> _assets = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final session = context.read<SessionProvider>();
      await Future.wait([
        if (session.user == null) session.refreshUser(),
        _loadTransactions(),
        _loadAssets(),
      ]);
    } on ApiException catch (e) {
      _error = e.message;
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadTransactions() async {
    final transactions = await _api.getTransactions();
    if (!mounted) return;
    setState(() {
      _latestTransactions = transactions.take(_latestTransactionCount).toList();
    });
  }

  Future<void> _loadAssets() async {
    final assets = await _api.getAssets();
    if (!mounted) return;
    setState(() => _assets = assets.reversed.toList());
  }

  Future<void> _addAsset() async {
    final result = await AssetFormDialog.show(context);
    if (result is! AssetSaved) return;
    await _runAssetAction(
      () => _api.addAsset(result.draft),
      success: 'Your card was successfully added.',
      failure: 'Something went wrong while adding the card.',
    );
  }

  Future<void> _editAsset(Asset asset) async {
    final result = await AssetFormDialog.show(context, initial: asset);
    switch (result) {
      case AssetSaved(:final draft):
        await _runAssetAction(
          () => _api.updateAsset(asset.id, draft),
          success: 'Your card was successfully updated.',
          failure: 'Something went wrong while updating the card.',
        );
      case AssetDeleted():
        await _runAssetAction(
          () => _api.deleteAsset(asset.id),
          success: 'Your card was successfully deleted.',
          failure: 'Something went wrong while deleting the card.',
        );
      case null:
        break;
    }
  }

  Future<void> _runAssetAction(
    Future<void> Function() action, {
    required String success,
    required String failure,
  }) async {
    try {
      await action();
      await _loadAssets();
      if (mounted) AppDialogs.showSuccess(context, success);
    } on ApiException {
      if (mounted) AppDialogs.showError(context, failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionProvider>().user;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.only(top: 80),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 15),
                    child: Text(
                      'Welcome, ${user?.fullName ?? ''}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  _buildCards(),
                  const Padding(
                    padding: EdgeInsets.only(top: 40, left: 20, bottom: 10),
                    child: Text(
                      'Latest Transactions',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_latestTransactions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No transactions yet.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ..._latestTransactions
                      .map((tx) => TransactionTile(transaction: tx)),
                ],
              ),
            ),
      bottomNavigationBar: const BottomNavBarWidget(currentPage: Pages.home),
    );
  }

  Widget _buildCards() {
    return SizedBox(
      height: 240,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _assets.length + 1,
        itemBuilder: (context, index) {
          final child = index == _assets.length
              ? _AddCardPlaceholder(onTap: _addAsset)
              : CreditCard(
                  asset: _assets[index],
                  onEdit: () => _editAsset(_assets[index]),
                );
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: child,
          );
        },
      ),
    );
  }
}

class _AddCardPlaceholder extends StatelessWidget {
  const _AddCardPlaceholder({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(12),
        padding: const EdgeInsets.all(6),
        color: Colors.grey,
        dashPattern: const [8, 4],
        strokeWidth: 2,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 48, color: Colors.grey),
              SizedBox(height: 10),
              Text(
                'Tap to add a new card',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
