import 'package:flutter/material.dart';
import '../utils/budget_tracker.dart';

class BudgetDisplayWidget extends StatefulWidget {
  final BudgetTracker budgetTracker;
  final bool isExpanded;
  final VoidCallback? onToggle;

  const BudgetDisplayWidget({
    Key? key,
    required this.budgetTracker,
    this.isExpanded = false,
    this.onToggle,
  }) : super(key: key);

  @override
  State<BudgetDisplayWidget> createState() => _BudgetDisplayWidgetState();
}

class _BudgetDisplayWidgetState extends State<BudgetDisplayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );

    if (_isExpanded) {
      _expandController.forward();
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
    widget.onToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.budgetTracker,
      builder: (context, child) {
        final totalAllocated = widget.budgetTracker.getTotalAllocated();
        final totalSpent = widget.budgetTracker.getTotalSpent();
        final totalRemaining = widget.budgetTracker.getTotalRemaining();
        final usagePercentage = totalAllocated > 0
            ? (totalSpent / totalAllocated).clamp(0.0, 1.0)
            : 0.0;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _toggleExpand,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.wallet,
                            color: Colors.orange.shade700,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Monthly Budget',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                '₹${totalRemaining.toStringAsFixed(0)} remaining',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: totalRemaining < 0
                                      ? Colors.red
                                      : Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Progress Bar
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator(
                                  value: usagePercentage,
                                  strokeWidth: 3,
                                  backgroundColor: Colors.grey.shade300,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    usagePercentage >= 0.9
                                        ? Colors.red
                                        : usagePercentage >= 0.7
                                            ? Colors.orange
                                            : Colors.green,
                                  ),
                                ),
                              ),
                              Text(
                                '${(usagePercentage * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        RotationTransition(
                          turns: _expandAnimation,
                          child: const Icon(Icons.expand_more),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Expanded Content
              SizeTransition(
                sizeFactor: _expandAnimation,
                axisAlignment: -1.0,
                child: Column(
                  children: [
                    Divider(
                      height: 1,
                      color: Colors.grey.shade200,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Summary Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildSummaryItem(
                                'Allocated',
                                '₹${totalAllocated.toStringAsFixed(0)}',
                                Colors.blue,
                              ),
                              _buildSummaryItem(
                                'Spent',
                                '₹${totalSpent.toStringAsFixed(0)}',
                                Colors.orange,
                              ),
                              _buildSummaryItem(
                                'Remaining',
                                '₹${totalRemaining.toStringAsFixed(0)}',
                                totalRemaining < 0 ? Colors.red : Colors.green,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Category Grid
                          Text(
                            'Category Breakdown',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1.0,
                            ),
                            itemCount: widget.budgetTracker.getCategoriesList().length,
                            itemBuilder: (context, index) {
                              final category =
                                  widget.budgetTracker.getCategoriesList()[index];
                              return _buildCategoryCard(category);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(String label, String amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(BudgetCategory category) {
    final percentage = category.usagePercentage;
    final isOverBudget = category.isOverBudget;

    return Container(
      decoration: BoxDecoration(
        color: Color(category.color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(category.color).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category.icon,
                style: const TextStyle(fontSize: 24),
              ),
              if (isOverBudget)
                Icon(
                  Icons.warning_amber,
                  size: 16,
                  color: Colors.red.shade700,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            category.name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '₹${category.remaining.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isOverBudget ? Colors.red : Colors.green,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage >= 1.0
                    ? Colors.red
                    : percentage >= 0.8
                        ? Colors.orange
                        : Color(category.color),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(percentage * 100).toInt()}%',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
