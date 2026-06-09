import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/contributions_provider.dart';

class TreasurerDashboard extends ConsumerWidget {
  const TreasurerDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(totalContributionsProvider);
    final byMonth = ref.watch(contributionsByMonthProvider);

    // Prepare data for bar chart
    final entries = byMonth.entries.toList()..sort((a,b) => a.key.compareTo(b.key));
    final spots = entries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Treasurer Dashboard'),
        backgroundColor: const Color(0xFF0A2F44),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Total Contributions Collected',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('KES ${total.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold,
                            color: Color(0xFFD4AF37))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Monthly Contributions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: const Color(0xFFD4AF37),
                      barWidth: 4,
                      belowBarData: BarAreaData(show: true, color: const Color(0xFFD4AF37).withOpacity(0.2)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Upcoming Expenses / Budget (placeholder)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                title: const Text('Reunion Venue Deposit'),
                trailing: const Text('KES 20,000'),
                subtitle: const Text('Due: July 15, 2026'),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Catering Services'),
                trailing: const Text('KES 50,000'),
                subtitle: const Text('Due: August 1, 2026'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}