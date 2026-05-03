import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../app_state.dart';
import '../widgets/glassmorphic_card.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({Key? key}) : super(key: key);

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final _savingsController = TextEditingController();
  final _salaryController = TextEditingController();

  void _showSavingsDialog(BuildContext context, AppState state) {
    _savingsController.text = state.savings.toString();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Update Starting Savings', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        content: TextField(
          controller: _savingsController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Accumulated Savings (₹)',
            labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
            enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF334155)), borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF10B981)), borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white60)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), elevation: 0),
            child: Text('Save', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () {
              final val = double.tryParse(_savingsController.text) ?? 0.0;
              state.updateSavings(val);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showSalaryDialog(BuildContext context, AppState state) {
    _salaryController.text = state.salary.toString();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Update Monthly Salary', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        content: TextField(
          controller: _salaryController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Monthly Salary (₹)',
            labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
            enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF334155)), borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF10B981)), borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white60)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), elevation: 0),
            child: Text('Save', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () {
              final val = double.tryParse(_salaryController.text) ?? 30000.0;
              state.updateSalary(val);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final catTotals = <String, double>{};
    for (var e in state.expenses) {
      if (e.type != 'Income' && e.type != 'Credit') {
        catTotals[e.category] = (catTotals[e.category] ?? 0.0) + e.amount;
      }
    }

    final totalSpent = state.totalSpent;
    final totalBudget = state.totalBudget;
    final balance = state.thisMonthBalance;
    final savingsAccumulation = state.totalSavings;
    final budgetPercent = totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;

    final today = DateTime.now();
    final lastDay = DateTime(today.year, today.month + 1, 0);
    final daysLeft = lastDay.day - today.day;

    final List<FlSpot> trendSpots = [];
    if (state.expenses.isEmpty) {
      trendSpots.addAll([const FlSpot(1, 0), const FlSpot(2, 0), const FlSpot(3, 0)]);
    } else {
      for (int i = 0; i < state.expenses.length; i++) {
        trendSpots.add(FlSpot(i.toDouble(), state.expenses[i].amount));
      }
    }

    final List<PieChartSectionData> pieSections = [];
    if (catTotals.isEmpty) {
      pieSections.add(PieChartSectionData(
        value: 100,
        title: 'Empty',
        radius: 40,
        color: const Color(0xFF334155),
        titleStyle: GoogleFonts.inter(color: Colors.white, fontSize: 13),
      ));
    } else {
      final colorPalette = [
        const Color(0xFF10B981),
        const Color(0xFFF59E0B),
        const Color(0xFFEF4444),
        const Color(0xFF6366F1),
        const Color(0xFF8B5CF6),
        const Color(0xFF14B8A6),
      ];

      var idx = 0;
      catTotals.forEach((cat, spent) {
        pieSections.add(PieChartSectionData(
          value: spent,
          title: '$cat\n${((spent / totalSpent) * 100).toStringAsFixed(1)}%',
          radius: 52,
          color: colorPalette[idx % colorPalette.length],
          titleStyle: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ));
        idx++;
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FINANCIAL SUMMARY',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8), letterSpacing: 0.8),
                  ),
                  Text(
                    'Account Dashboard',
                    style: GoogleFonts.inter(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.payment_outlined, color: Color(0xFF6366F1)),
                    tooltip: 'Edit Salary',
                    onPressed: () => _showSalaryDialog(context, state),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_note, color: Color(0xFF10B981)),
                    tooltip: 'Edit Starting Savings',
                    onPressed: () => _showSavingsDialog(context, state),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),

          GlassmorphicCard(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 90,
                      width: 90,
                      child: CircularProgressIndicator(
                        value: budgetPercent,
                        strokeWidth: 9,
                        backgroundColor: const Color(0xFF0F172A),
                        color: budgetPercent > 0.85
                            ? const Color(0xFFEF4444)
                            : (budgetPercent > 0.5 ? const Color(0xFFF59E0B) : const Color(0xFF10B981)),
                      ),
                    ),
                    Text(
                      '${(budgetPercent * 100).toStringAsFixed(0)}%',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
                    )
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BALANCE FROM THIS SALARY',
                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8), letterSpacing: 1.1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${balance.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 12, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 6),
                          Text(
                            '$daysLeft days left in period',
                            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 14),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.star_border, color: Colors.white),
            label: Text('Got Salary This Month (Rollover Period)',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            onPressed: () {
              state.rolloverSalary(balance);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF6366F1),
                  content: Text('Salary rolled over to savings!', style: GoogleFonts.inter(color: Colors.white)),
                ),
              );
            },
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: GlassmorphicCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MONTHLY SALARY',
                        style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${state.salary.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF6366F1)),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassmorphicCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL SAVINGS',
                        style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${savingsAccumulation.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            'ANALYTICS BREAKDOWN',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8), letterSpacing: 1.1),
          ),
          const SizedBox(height: 12),

          GlassmorphicCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Spending distribution by category',
                  style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 160,
                  child: PieChart(
                    PieChartData(
                      sections: pieSections,
                      centerSpaceRadius: 32,
                      sectionsSpace: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          GlassmorphicCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Spending Profile',
                  style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 130,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: trendSpots,
                          isCurved: true,
                          gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF6366F1)]),
                          barWidth: 4,
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [const Color(0xFF10B981).withOpacity(0.12), Colors.transparent],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
