class Transaction {
  final int id;
  final String description;
  final String category;
  final double amount;
  final DateTime date;

  Transaction({
    required this.id,
    required this.description,
    required this.category,
    required this.amount,
    required this.date,
  });

  bool get isIncome => amount >= 0;

  Transaction copyWith({
    int? id,
    String? description,
    String? category,
    double? amount,
    DateTime? date,
  }) {
    return Transaction(
      id: id ?? this.id,
      description: description ?? this.description,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
    );
  }
}
