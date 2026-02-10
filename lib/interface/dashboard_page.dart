import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import '../models/user_model.dart';
import '../models/dashboard_model.dart';
import '../core/dashboard_service.dart';
import 'login_page.dart';

class DashboardPage extends StatefulWidget {
  final UserModel user;

  const DashboardPage({super.key, required this.user});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _dashboardService = DashboardService();
  DashboardData? _dashboardData;
  bool _isLoading = true;

  // Track the currently expanded category
  String? _expandedCategory;
  final Map<String, GlobalKey<FlipCardState>> _cardKeys = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await _dashboardService.getDashboardData(widget.user.token);
    if (mounted) {
      setState(() {
        _dashboardData = data;
        _isLoading = false;

        // Initialize keys for each category
        if (_dashboardData != null) {
          for (var category in _dashboardData!.categories.keys) {
            _cardKeys[category] = GlobalKey<FlipCardState>();
          }
        }
      });
    }
  }

  void _onCardTap(String category) {
    // Logic:
    // 1. Default card is false (closed).
    // 2. If user presses a card (that is currently closed/false):
    //    a. Check if there is any card true (open).
    //    b. If yes, make it false (flip back).
    //    c. Make the pressed card true (flip open).

    // If another card is currently expanded
    if (_expandedCategory != null && _expandedCategory != category) {
      // Close the previously expanded card
      _cardKeys[_expandedCategory]?.currentState?.toggleCard();
    }

    // Update the expanded category to the new one
    setState(() {
      _expandedCategory = category;
    });

    // Open the clicked card
    _cardKeys[category]?.currentState?.toggleCard();
  }

  void _onHeaderTap(String category) {
    // Optional: Allow closing by tapping the header of the open card
    if (_expandedCategory == category) {
      _cardKeys[category]?.currentState?.toggleCard();
      setState(() {
        _expandedCategory = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                widget.user.fullName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dashboardData == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Failed to load dashboard data'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                      });
                      _fetchData();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Responsive grid count based on width
                  int crossAxisCount = constraints.maxWidth > 1200
                      ? 4
                      : constraints.maxWidth > 800
                      ? 3
                      : constraints.maxWidth > 600
                      ? 2
                      : 1;

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio:
                          0.8, // Adjust aspect ratio for card height
                    ),
                    itemCount: _dashboardData!.categories.length,
                    itemBuilder: (context, index) {
                      final category = _dashboardData!.categories.keys
                          .elementAt(index);
                      final items = _dashboardData!.categories[category]!;

                      return _buildFlipCard(category, items);
                    },
                  );
                },
              ),
            ),
    );
  }

  Widget _buildFlipCard(String category, List<MenuItem> items) {
    return FlipCard(
      key: _cardKeys[category],
      flipOnTouch: false, // We handle taps manually
      front: GestureDetector(
        onTap: () => _onCardTap(category),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.7),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_getCategoryIcon(category), size: 64, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  category.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${items.length} Systems',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      back: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _onHeaderTap(category),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.close, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(
                      item.module.moduleName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      item.module.moduleDescription,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      // Handle navigation or action
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Opening ${item.module.moduleName}'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'sd':
        return Icons.shopping_cart_outlined;
      case 'mm':
        return Icons.inventory_2_outlined;
      case 'fico':
        return Icons.attach_money;
      case 'pp':
        return Icons.factory_outlined;
      default:
        return Icons.grid_view;
    }
  }
}
