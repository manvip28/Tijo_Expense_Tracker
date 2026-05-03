class Expense {
  final int id;
  final double amount;
  final String category;
  final String description;
  final String note;
  final String type; // 'Expense' or 'Income'
  final String date;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.note,
    required this.type,
    required this.date,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] ?? 'Misc',
      description: json['description'] ?? '',
      note: json['note'] ?? '',
      type: json['type'] ?? 'Expense',
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'category': category,
        'description': description,
        'note': note,
        'type': type,
        'date': date,
      };
}

class FinancialGoal {
  final int id;
  final String title;
  final String description;
  final String target;
  final String status;

  FinancialGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.target,
    required this.status,
  });

  factory FinancialGoal.fromJson(Map<String, dynamic> json) {
    return FinancialGoal(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      target: json['target'] ?? '',
      status: json['status'] ?? 'In Progress',
    );
  }
}

class Reward {
  final int id;
  final String title;
  final String condition;
  final bool unlocked;

  Reward({
    required this.id,
    required this.title,
    required this.condition,
    required this.unlocked,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      condition: json['condition'] ?? '',
      unlocked: json['unlocked'] ?? false,
    );
  }
}

class Gift {
  final int id;
  final String title;
  final String link;
  final String description;
  final double target;
  final bool unlocked;

  Gift({
    required this.id,
    required this.title,
    required this.link,
    required this.description,
    required this.target,
    required this.unlocked,
  });

  factory Gift.fromJson(Map<String, dynamic> json) {
    return Gift(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      link: json['link'] ?? '',
      description: json['description'] ?? '',
      target: (json['target'] as num?)?.toDouble() ?? 0.0,
      unlocked: json['unlocked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'link': link,
        'description': description,
        'target': target,
        'unlocked': unlocked,
      };
}
