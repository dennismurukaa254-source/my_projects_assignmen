import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/contribution.dart';

final contributionsStreamProvider = StreamProvider<List<Contribution>>((ref) {
  return FirebaseFirestore.instance
      .collection('contributions')
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) {
    final list = snapshot.docs
        .map((doc) => Contribution.fromMap(doc.id, doc.data()))
        .toList();
    print('Stream emitted ${list.length} contributions');
    for (var c in list) {
      print('Contribution: ${c.memberName}, amount=${c.amount}');
    }
    return list;
  });
});

final totalContributionsProvider = Provider<double>((ref) {
  final contributions = ref.watch(contributionsStreamProvider).value ?? [];
  double sum = 0;
  for (var c in contributions) {
    sum += c.amount;
  }
  print('Total sum computed: $sum');
  return sum;
});

final contributionsByMonthProvider = Provider<Map<DateTime, double>>((ref) {
  final contributions = ref.watch(contributionsStreamProvider).value ?? [];
  final map = <DateTime, double>{};
  for (var c in contributions) {
    final month = DateTime(c.date.year, c.date.month);
    map[month] = (map[month] ?? 0) + c.amount;
  }
  return map;
});