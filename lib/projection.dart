import 'package:flutter/material.dart';
import 'services/api_service.dart';

class ProjectionScreen extends StatefulWidget {
  const ProjectionScreen({Key? key}) : super(key: key);

  @override
  State<ProjectionScreen> createState() => _ProjectionScreenState();
}

class _ProjectionScreenState extends State<ProjectionScreen> {
  final ApiService _apiService = ApiService();
  final int _userId = 1; // TODO: wire to authenticated user

  // Data models
  Map<String, dynamic>? _forecastData;
  Map<String, dynamic>? _adaptiveBudgets;
  Map<String, dynamic>? _savingsData;
  Map<String, dynamic>? _shockCapacity;
  Map<String, dynamic>? _goalImpact;
  Map<String, dynamic>? _llmInsight;

  bool _isLoading = true;
  String? _error;
  int _selectedShockAmount = 5000; // For custom shock simulation

  // Theme Colors
  static const Color bgColor = Color(0xFF163339);
  static const Color accentGreen = Color(0xFF5DF22A);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF8BA5A8);
  static const Color textDark = Color(0xFF1D2F35);
  static const Color cardBg = Colors.white;
  static const Color warningColor = Color(0xFFFF6F61);
  static const Color successColor = Color(0xFF5DF22A);

  @override
  void initState() {
    super.initState();
    _loadAllAnalytics();
  }

  Future<void> _loadAllAnalytics() async {
    try {
      setState(() => _isLoading = true);

      // Load all analytics in parallel
      await Future.wait([
        _loadForecast(),
        _loadAdaptiveBudgets(),
        _loadSavingsOpportunities(),
        _loadShockCapacity(),
        _loadLLMInsight(),
      ]);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load analytics: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadForecast() async {
    try {
      final data = await _apiService.getProjectionForecast(userId: _userId);
      if (!mounted) return;
      setState(() => _forecastData = data);
    } catch (e) {
      debugPrint('Error loading forecast: $e');
    }
  }

  Future<void> _loadAdaptiveBudgets() async {
    try {
      final data = await _apiService.getAdaptiveBudgets(userId: _userId);
      if (!mounted) return;
      setState(() => _adaptiveBudgets = data);
    } catch (e) {
      debugPrint('Error loading adaptive budgets: $e');
    }
  }

  Future<void> _loadSavingsOpportunities() async {
    try {
      final data = await _apiService.getSavingsOpportunities(userId: _userId);
      if (!mounted) return;
      setState(() => _savingsData = data);
    } catch (e) {
      debugPrint('Error loading savings: $e');
    }
  }

  Future<void> _loadShockCapacity() async {
    try {
      final data = await _apiService.getShockCapacity(userId: _userId);
      if (!mounted) return;
      setState(() => _shockCapacity = data);
    } catch (e) {
      debugPrint('Error loading shock data: $e');
    }
  }

  Future<void> _loadLLMInsight() async {
    try {
      final data = await _apiService.getLLMInsight(userId: _userId);
      if (!mounted) return;
      setState(() => _llmInsight = data);
    } catch (e) {
      debugPrint('Error loading LLM insight: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Projections',
            style: TextStyle(
              color: textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: _loadAllAnalytics,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: accentGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accentGreen.withOpacity(0.5)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.refresh, color: accentGreen, size: 18),
                  SizedBox(width: 4),
                  Text(
                    'Refresh',
                    style: TextStyle(
                      color: accentGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
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

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              const CircularProgressIndicator(color: accentGreen),
              const SizedBox(height: 16),
              const Text(
                'Loading analytics...',
                style: TextStyle(color: textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: warningColor, size: 48),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAllAnalytics,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildForecastSection(),
        const SizedBox(height: 20),
        _buildAdaptiveBudgetsSection(),
        const SizedBox(height: 20),
        _buildSavingsOpportunitiesSection(),
        const SizedBox(height: 20),
        _buildShockCapacitySection(),
        const SizedBox(height: 20),
        _buildLLMInsightSection(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildForecastSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E9EA), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart, color: accentGreen, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Probabilistic Forecast',
                style: TextStyle(
                  color: textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_forecastData == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Loading forecast data...',
                  style: TextStyle(color: textSecondary, fontSize: 13),
                ),
              ),
            )
          else
            Column(
              children: [
                _buildForecastMetric('Projected Month Spend', '₹15,200 - ₹18,500'),
                const SizedBox(height: 12),
                _buildForecastMetric('Projected Balance', '₹42,300 - ₹48,900'),
                const SizedBox(height: 12),
                _buildForecastMetric('Depletion Risk', 'Low (2%)'),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAdaptiveBudgetsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E9EA), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet, color: accentGreen, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Adaptive Budgets',
                style: TextStyle(
                  color: textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_adaptiveBudgets == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Loading budget data...',
                  style: TextStyle(color: textSecondary, fontSize: 13),
                ),
              ),
            )
          else
            Column(
              children: [
                _buildBudgetCategory('Food & Dining', 8000, 2150, false),
                const SizedBox(height: 12),
                _buildBudgetCategory('Transport', 5000, 1200, false),
                const SizedBox(height: 12),
                _buildBudgetCategory('Shopping', 10000, 3450, false),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSavingsOpportunitiesSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E9EA), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: successColor, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Savings Opportunities',
                style: TextStyle(
                  color: textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_savingsData == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Loading savings data...',
                  style: TextStyle(color: textSecondary, fontSize: 13),
                ),
              ),
            )
          else
            Column(
              children: [
                _buildSavingsCard('Entertainment', '₹500-2,000/month', '10-20% reduction'),
                const SizedBox(height: 12),
                _buildSavingsCard('Shopping', '₹1,000-3,500/month', '15-30% reduction'),
                const SizedBox(height: 12),
                _buildSavingsCard('Dining Out', '₹600-1,500/month', '20-40% reduction'),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildShockCapacitySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E9EA), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield, color: accentGreen, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Shock Absorption',
                style: TextStyle(
                  color: textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_shockCapacity == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Loading shock data...',
                  style: TextStyle(color: textSecondary, fontSize: 13),
                ),
              ),
            )
          else
            Column(
              children: [
                _buildShockMetric('Safe Margin', '₹45,000', successColor),
                const SizedBox(height: 12),
                _buildShockMetric('Emergency Capacity', '₹25,000', accentGreen),
                const SizedBox(height: 12),
                _buildShockMetric('Critical Threshold', '₹10,000', warningColor),
                const SizedBox(height: 16),
                _buildShockSimulation(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildShockSimulation() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Simulate Shock Amount',
            style: TextStyle(
              color: textDark,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _selectedShockAmount.toDouble(),
                  min: 1000,
                  max: 50000,
                  divisions: 49,
                  activeColor: accentGreen,
                  inactiveColor: textSecondary,
                  onChanged: (value) {
                    setState(() => _selectedShockAmount = value.toInt());
                  },
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '₹${_selectedShockAmount.toString()}',
                style: const TextStyle(
                  color: textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Simulate shock
                debugPrint('Simulating shock: ₹$_selectedShockAmount');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGreen,
                foregroundColor: textDark,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Simulate Shock'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLLMInsightSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E9EA), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: accentGreen, size: 24),
              const SizedBox(width: 12),
              const Text(
                'AI Insights',
                style: TextStyle(
                  color: textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_llmInsight == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Loading AI insights...',
                  style: TextStyle(color: textSecondary, fontSize: 13),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accentGreen.withOpacity(0.3)),
              ),
              child: const Text(
                'Your spending is 15% below projected levels this month. If you maintain this pace, you\'ll have an additional ₹5,200 in emergency reserves by month-end. Consider allocating this surplus to your retirement goals.',
                style: TextStyle(
                  color: textDark,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildForecastMetric(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: textSecondary,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: accentGreen,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetCategory(String category, int budget, int spent, bool isOver) {
    final remaining = budget - spent;
    final percentage = (spent / budget * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category,
              style: const TextStyle(
                color: textDark,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '₹$spent / ₹$budget',
              style: TextStyle(
                color: isOver ? warningColor : textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: spent / budget,
            minHeight: 8,
            backgroundColor: const Color(0xFFE5E9EA),
            valueColor: AlwaysStoppedAnimation<Color>(
              isOver ? warningColor : accentGreen,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$percentage% used • $remaining remaining',
          style: const TextStyle(
            color: textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildSavingsCard(String category, String amount, String reduction) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E9EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: const TextStyle(
                  color: textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: successColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  reduction,
                  style: const TextStyle(
                    color: successColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: const TextStyle(
              color: accentGreen,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShockMetric(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: textSecondary,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
