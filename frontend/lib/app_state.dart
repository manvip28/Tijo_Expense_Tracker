import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'api_service.dart';

class AppState extends ChangeNotifier {
  List<Expense> _expenses = [];
  Map<String, double> _limits = {};
  List<FinancialGoal> _goals = [];
  List<Reward> _rewards = [];
  double _salary = 30000.0;
  int _streak = 3;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  double _savings = 0.0;
  List<Gift> _gifts = [];

  AppState() {
    _loadAuthStatus();
  }

  Future<void> _loadAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null && token.isNotEmpty) {
        ApiService.token = token;
        _isAuthenticated = true;
        await fetchData();
      }
    } catch (e) {
      print('Load auth error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  List<Expense> get expenses => _expenses;
  Map<String, double> get limits => _limits;
  List<FinancialGoal> get goals => _goals;
  List<Reward> get rewards => _rewards;
  double get salary => _salary;
  int get streak => _streak;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  double get savings => _savings;
  List<Gift> get gifts => _gifts;

  double get totalBudget => _limits['Monthly Budget'] ?? 10000.0;
  
  String get _currentMonth {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}";
  }

  double get totalSpent => _expenses
      .where((e) => e.type != 'Income' && e.type != 'Credit')
      .fold(0.0, (acc, cur) => acc + cur.amount);

  double get totalIncome => _expenses
      .where((e) => e.type == 'Income' || e.type == 'Credit')
      .fold(0.0, (acc, cur) => acc + cur.amount);

  double get remainingBalance => _savings + totalIncome - totalSpent;

  double get thisMonthSpent => _expenses
      .where((e) => (e.type != 'Income' && e.type != 'Credit') && e.date.startsWith(_currentMonth))
      .fold(0.0, (acc, cur) => acc + cur.amount);

  double get thisMonthIncome => _expenses
      .where((e) => (e.type == 'Income' || e.type == 'Credit') && e.date.startsWith(_currentMonth))
      .fold(0.0, (acc, cur) => acc + cur.amount);

  double get thisMonthBalance => _salary - thisMonthSpent + thisMonthIncome;

  double get totalSavings => _savings;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();
    final res = await ApiService.login(username, password);
    if (res && ApiService.token != null) {
      _isAuthenticated = true;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', ApiService.token!);
      } catch (e) {
        print('Save auth error: $e');
      }
      await fetchData();
    }
    _isLoading = false;
    notifyListeners();
    return res;
  }

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _expenses = await ApiService.getExpenses();
      _limits = await ApiService.getLimits();
      _savings = await ApiService.getSavings();
      _salary = await ApiService.getSalary();
      _gifts = await ApiService.getGifts();
      final data = await ApiService.getGoalsAndRewards();
      _goals = data['goals'] ?? [];
      _rewards = data['rewards'] ?? [];
    } catch (e) {
      print('Fetch error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addExpense(double amount, String category, String description, String note, String type, String date) async {
    final success = await ApiService.addExpense(
      amount: amount,
      category: category,
      description: description,
      note: note,
      type: type,
      date: date,
    );
    if (success) {
      await fetchData();
    }
  }

  Future<void> deleteExpense(int id) async {
    final success = await ApiService.deleteExpense(id);
    if (success) {
      await fetchData();
    }
  }

  Future<void> updateExpense(int id, double amount, String category, String description, String note, String type, String date) async {
    final success = await ApiService.updateExpense(
      id: id,
      amount: amount,
      category: category,
      description: description,
      note: note,
      type: type,
      date: date,
    );
    if (success) {
      await fetchData();
    }
  }

  Future<void> setLimits(Map<String, double> updatedLimits) async {
    final success = await ApiService.setLimits(updatedLimits);
    if (success) {
      await fetchData();
    }
  }

  Future<void> deleteLimit(String category) async {
    final success = await ApiService.deleteLimit(category);
    if (success) {
      await fetchData();
    }
  }

  Future<void> updateSavings(double val) async {
    final success = await ApiService.updateSavings(val);
    if (success) {
      await fetchData();
    }
  }

  Future<void> rolloverSalary(double leftover) async {
    final success = await ApiService.rolloverSalary(leftover);
    if (success) {
      await fetchData();
    }
  }

  Future<void> addGift(String title, String link, String description, double target) async {
    final success = await ApiService.addGift(title, link, description, target);
    if (success) {
      await fetchData();
    }
  }

  Future<void> deleteGift(int id) async {
    final success = await ApiService.deleteGift(id);
    if (success) {
      await fetchData();
    }
  }

  Future<void> updateSalary(double val) async {
    final success = await ApiService.updateSalary(val);
    if (success) {
      await fetchData();
    }
  }

  Future<void> resetData() async {
    final success = await ApiService.resetDatabase();
    if (success) {
      await fetchData();
    }
  }
}
