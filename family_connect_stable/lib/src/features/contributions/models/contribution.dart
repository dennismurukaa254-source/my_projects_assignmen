class Contribution {
  final String id;
  final String memberId;
  final String memberName;
  final double amount;
  final DateTime date;
  final String? receiptUrl;
  final String? notes;

  Contribution({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.amount,
    required this.date,
    this.receiptUrl,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'memberName': memberName,
      'amount': amount,
      'date': date.toIso8601String(),
      'receiptUrl': receiptUrl,
      'notes': notes,
    };
  }

  factory Contribution.fromMap(String id, Map<String, dynamic> map) {
    return Contribution(
      id: id,
      memberId: map['memberId'] ?? '',
      memberName: map['memberName'] ?? '',
      amount: (map['amount'] as num).toDouble(), // Ensure double
      date: DateTime.parse(map['date']),
      receiptUrl: map['receiptUrl'],
      notes: map['notes'],
    );
  }
}