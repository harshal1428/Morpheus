import 'package:flutter/foundation.dart';

/// Category budgets with allocated amounts for the month
class BudgetCategory {
  final String name;
  final String icon;
  final int color; // Material color value
  double allocatedBudget;
  double spentAmount;

  BudgetCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.allocatedBudget,
    this.spentAmount = 0.0,
  });

  /// Remaining budget for this category
  double get remaining => allocatedBudget - spentAmount;

  /// Budget usage percentage (0-1)
  double get usagePercentage {
    if (allocatedBudget <= 0) return 0.0;
    return (spentAmount / allocatedBudget).clamp(0.0, 1.0);
  }

  /// Returns true if over budget
  bool get isOverBudget => spentAmount > allocatedBudget;

  /// Deduct amount from budget
  void deductAmount(double amount) {
    spentAmount += amount;
  }

  /// Reset spent amount
  void reset() {
    spentAmount = 0.0;
  }

  /// Copy with new values
  BudgetCategory copyWith({
    String? name,
    String? icon,
    int? color,
    double? allocatedBudget,
    double? spentAmount,
  }) {
    return BudgetCategory(
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      allocatedBudget: allocatedBudget ?? this.allocatedBudget,
      spentAmount: spentAmount ?? this.spentAmount,
    );
  }
}

/// Budget tracker notifier
class BudgetTracker extends ChangeNotifier {
  Map<String, BudgetCategory> _categories = {};

  BudgetTracker() {
    _initializeCategories();
  }

  /// Initialize default budget categories with allocated amounts
  void _initializeCategories() {
    _categories = {
      'Food & Dining': BudgetCategory(
        name: 'Food & Dining',
        icon: '🍔',
        color: 0xFFFF6B6B,
        allocatedBudget: 8000.0,
        spentAmount: 2150.50, // Pre-added spending
      ),
      'Transport': BudgetCategory(
        name: 'Transport',
        icon: '🚗',
        color: 0xFF4ECDC4,
        allocatedBudget: 5000.0,
        spentAmount: 1200.00, // Pre-added spending
      ),
      'Shopping': BudgetCategory(
        name: 'Shopping',
        icon: '🛍️',
        color: 0xFFFFE66D,
        allocatedBudget: 10000.0,
        spentAmount: 3450.75, // Pre-added spending
      ),
      'Health & Medical': BudgetCategory(
        name: 'Health & Medical',
        icon: '⚕️',
        color: 0xFF95E1D3,
        allocatedBudget: 3000.0,
        spentAmount: 850.00, // Pre-added spending
      ),
      'Entertainment': BudgetCategory(
        name: 'Entertainment',
        icon: '🎬',
        color: 0xFFC7CEEA,
        allocatedBudget: 5000.0,
        spentAmount: 1500.00, // Pre-added spending
      ),
      'Bills & Utilities': BudgetCategory(
        name: 'Bills & Utilities',
        icon: '💡',
        color: 0xFFFFA07A,
        allocatedBudget: 4000.0,
        spentAmount: 0.0,
      ),
      'Education': BudgetCategory(
        name: 'Education',
        icon: '📚',
        color: 0xFF74B9FF,
        allocatedBudget: 3000.0,
        spentAmount: 0.0,
      ),
      'Investment': BudgetCategory(
        name: 'Investment',
        icon: '📈',
        color: 0xFF00B894,
        allocatedBudget: 15000.0,
        spentAmount: 5000.00, // Pre-added spending
      ),
      'Savings': BudgetCategory(
        name: 'Savings',
        icon: '💰',
        color: 0xFFDDA15E,
        allocatedBudget: 12000.0,
        spentAmount: 0.0,
      ),
      'Lifestyle': BudgetCategory(
        name: 'Lifestyle',
        icon: '✨',
        color: 0xFFC9ADA7,
        allocatedBudget: 6000.0,
        spentAmount: 1250.50, // Pre-added spending
      ),
      'Other': BudgetCategory(
        name: 'Other',
        icon: '📦',
        color: 0xFF949494,
        allocatedBudget: 2000.0,
        spentAmount: 400.00, // Pre-added spending
      ),
    };
  }

  /// Get all categories
  Map<String, BudgetCategory> get categories => _categories;

  /// Get category by name
  BudgetCategory? getCategory(String name) => _categories[name];

  /// Get all categories as list
  List<BudgetCategory> getCategoriesList() => _categories.values.toList();

  /// Deduct amount from a category
  void deductFromCategory(String categoryName, double amount) {
    final category = _categories[categoryName];
    if (category != null) {
      category.deductAmount(amount);
      notifyListeners();
    }
  }

  /// Get total allocated budget
  double getTotalAllocated() {
    return _categories.values.fold(0.0, (sum, cat) => sum + cat.allocatedBudget);
  }

  /// Get total spent
  double getTotalSpent() {
    return _categories.values.fold(0.0, (sum, cat) => sum + cat.spentAmount);
  }

  /// Get remaining total
  double getTotalRemaining() {
    return getTotalAllocated() - getTotalSpent();
  }

  /// Reset all categories
  void resetAll() {
    for (var category in _categories.values) {
      category.reset();
    }
    notifyListeners();
  }

  /// Reset specific category
  void resetCategory(String name) {
    final category = _categories[name];
    if (category != null) {
      category.reset();
      notifyListeners();
    }
  }

  /// Update category budget allocation
  void updateCategoryBudget(String name, double amount) {
    final category = _categories[name];
    if (category != null) {
      category.allocatedBudget = amount;
      notifyListeners();
    }
  }
}
