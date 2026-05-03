import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

class ApiService {
  static String baseUrl = 'https://tijo-expense-tracker-1.onrender.com';

  static Future<List<Expense>> getExpenses() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get-expenses'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Expense.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error getting expenses: $e');
    }
    return [];
  }

  static Future<bool> addExpense({
    required double amount,
    required String category,
    required String description,
    required String note,
    required String type,
    required String date,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add-expense'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': amount,
          'category': category,
          'description': description,
          'note': note,
          'type': type,
          'date': date,
        }),
      );
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print('Error adding expense: $e');
    }
    return false;
  }

  static Future<bool> deleteExpense(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/delete-expense'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': id}),
      );
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print('Error deleting expense: $e');
    }
    return false;
  }

  static Future<bool> updateExpense({
    required int id,
    required double amount,
    required String category,
    required String description,
    required String note,
    required String type,
    required String date,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update-expense'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': id,
          'amount': amount,
          'category': category,
          'description': description,
          'note': note,
          'type': type,
          'date': date,
        }),
      );
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print('Error updating expense: $e');
    }
    return false;
  }

  static Future<Map<String, double>> getLimits() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get-limits'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data.map((key, value) => MapEntry(key, (value as num).toDouble()));
      }
    } catch (e) {
      print('Error getting limits: $e');
    }
    return {};
  }

  static Future<bool> setLimits(Map<String, double> limits) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/set-limits'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(limits),
      );
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print('Error setting limits: $e');
    }
    return false;
  }

  static Future<bool> deleteLimit(String category) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/delete-limit'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'category': category}),
      );
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print('Error deleting limit: $e');
    }
    return false;
  }

  static Future<double> getSavings() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get-savings'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['savings'] as num?)?.toDouble() ?? 0.0;
      }
    } catch (e) {
      print('Error getting savings: $e');
    }
    return 0.0;
  }

  static Future<bool> updateSavings(double amount) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update-savings'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'savings': amount}),
      );
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print('Error updating savings: $e');
    }
    return false;
  }

  static Future<double> getSalary() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get-salary'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['salary'] as num?)?.toDouble() ?? 30000.0;
      }
    } catch (e) {
      print('Error getting salary: $e');
    }
    return 30000.0;
  }

  static Future<bool> updateSalary(double amount) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update-salary'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'salary': amount}),
      );
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print('Error updating salary: $e');
    }
    return false;
  }

  static Future<List<Gift>> getGifts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get-gifts'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Gift.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error getting gifts: $e');
    }
    return [];
  }

  static Future<bool> addGift(String title, String link, String description, double target) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add-gift'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'link': link,
          'description': description,
          'target': target,
        }),
      );
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print('Error adding gift: $e');
    }
    return false;
  }

  static Future<bool> deleteGift(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/delete-gift'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': id}),
      );
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print('Error deleting gift: $e');
    }
    return false;
  }

  static Future<Map<String, dynamic>> getGoalsAndRewards() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get-goals'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> goalsData = data['goals'] ?? [];
        final List<dynamic> rewardsData = data['rewards'] ?? [];
        
        return {
          'goals': goalsData.map((json) => FinancialGoal.fromJson(json)).toList(),
          'rewards': rewardsData.map((json) => Reward.fromJson(json)).toList(),
        };
      }
    } catch (e) {
      print('Error getting goals and rewards: $e');
    }
    return {'goals': <FinancialGoal>[], 'rewards': <Reward>[]};
  }

  static Future<bool> rolloverSalary(double leftover) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/rollover-salary'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'leftover': leftover}),
      );
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print('Error rolling over salary: $e');
    }
    return false;
  }

  static Future<bool> resetDatabase() async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/reset'));
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print('Error resetting database: $e');
    }
    return false;
  }
}
