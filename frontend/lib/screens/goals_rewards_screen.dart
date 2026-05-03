import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';
import '../widgets/glassmorphic_card.dart';

class GoalsRewardsTab extends StatefulWidget {
  const GoalsRewardsTab({Key? key}) : super(key: key);

  @override
  State<GoalsRewardsTab> createState() => _GoalsRewardsTabState();
}

class _GoalsRewardsTabState extends State<GoalsRewardsTab> {
  final _giftTitleController = TextEditingController();
  final _giftLinkController = TextEditingController();
  final _giftDescController = TextEditingController();
  final _giftTargetController = TextEditingController();

  void _showAddGiftDialog(BuildContext context, AppState state) {
    _giftTitleController.clear();
    _giftLinkController.clear();
    _giftDescController.clear();
    _giftTargetController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20, right: 20, top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New Gift Reward',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _giftTitleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Gift / Treat Title',
                  labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF334155)), borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF10B981)), borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _giftLinkController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Purchase Link (Optional)',
                  labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF334155)), borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF10B981)), borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _giftDescController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF334155)), borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF10B981)), borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _giftTargetController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Target Savings Required (₹)',
                  labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF334155)), borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF10B981)), borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Add Gift', style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                onPressed: () {
                  final title = _giftTitleController.text.trim();
                  final link = _giftLinkController.text.trim();
                  final desc = _giftDescController.text.trim();
                  final target = double.tryParse(_giftTargetController.text) ?? 0.0;
                  if (title.isNotEmpty && target > 0) {
                    state.addGift(title, link, desc, target);
                    Navigator.pop(context);
                  }
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    // Dynamic Badge Calculation
    final Map<String, double> catSpent = {};
    for (var e in state.expenses) {
      if (e.type != 'Income' && e.type != 'Credit') {
        catSpent[e.category] = (catSpent[e.category] ?? 0.0) + e.amount;
      }
    }

    int compliantCount = 0;
    int totalCategories = state.limits.keys.length;

    state.limits.forEach((cat, lim) {
      final spent = catSpent[cat] ?? 0.0;
      if (spent <= lim) {
        compliantCount++;
      }
    });

    final double compliancePercent = totalCategories > 0 ? (compliantCount / totalCategories) : 0.0;

    String currentBadge = 'Bronze Badge';
    String nextBadge = 'Silver Badge';
    Color badgeColor = const Color(0xFFCD7F32);
    Color nextBadgeColor = const Color(0xFF94A3B8);
    double progressToNext = (compliancePercent / 0.5);

    if (compliancePercent >= 1.0) {
      currentBadge = 'Gold Badge';
      nextBadge = 'Max Level Reached';
      badgeColor = const Color(0xFFFFD700);
      nextBadgeColor = Colors.transparent;
      progressToNext = 1.0;
    } else if (compliancePercent >= 0.5) {
      currentBadge = 'Silver Badge';
      nextBadge = 'Gold Badge';
      badgeColor = const Color(0xFF94A3B8);
      nextBadgeColor = const Color(0xFFFFD700);
      progressToNext = (compliancePercent - 0.5) / 0.5;
    } else if (compliancePercent >= 0.25) {
      currentBadge = 'Bronze Badge';
      nextBadge = 'Silver Badge';
      badgeColor = const Color(0xFFCD7F32);
      nextBadgeColor = const Color(0xFF94A3B8);
      progressToNext = (compliancePercent - 0.25) / 0.25;
    } else {
      currentBadge = 'No Badge';
      nextBadge = 'Bronze Badge';
      badgeColor = const Color(0xFF334155);
      nextBadgeColor = const Color(0xFFCD7F32);
      progressToNext = compliancePercent / 0.25;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Dynamic Badge Widget
          GlassmorphicCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.stars_rounded, color: badgeColor, size: 36),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentBadge.toUpperCase(),
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.0),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Based on budget adherence',
                        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progressToNext.clamp(0.0, 1.0),
                        backgroundColor: const Color(0xFF1E293B),
                        color: badgeColor,
                        minHeight: 5,
                      ),
                      const SizedBox(height: 4),
                      if (nextBadge != 'Max Level Reached')
                        Text(
                          'Next Level: $nextBadge',
                          style: GoogleFonts.inter(fontSize: 11, color: nextBadgeColor.withOpacity(0.6), fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Monthly Savings Milestone Progression
          Text(
            'SAVINGS & SPENDING MILESTONES',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8), letterSpacing: 1.1),
          ),
          const SizedBox(height: 12),

          GlassmorphicCard(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.goals.length,
              itemBuilder: (context, i) {
                final g = state.goals[i];
                final isCompleted = g.status == 'Completed';
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: i == state.goals.length - 1 ? null : const Border(bottom: BorderSide(color: Color(0xFF1E293B))),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isCompleted ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                        color: isCompleted ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                        size: 22,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              g.title,
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Text(
                              g.description,
                              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Gifts section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PERSONAL GIFTS & TREATS',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8), letterSpacing: 1.1),
              ),
              IconButton(
                icon: const Icon(Icons.add_box_outlined, color: Color(0xFF10B981)),
                tooltip: 'Add Gift',
                onPressed: () => _showAddGiftDialog(context, state),
              ),
            ],
          ),
          const SizedBox(height: 12),

          state.gifts.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text('No gifts tracked yet.\nClick + above to create a personal treat goal!',
                        style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13), textAlign: TextAlign.center),
                  ),
                )
              : Column(
                  children: state.gifts.map((g) {
                    final unlocked = g.unlocked;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: GlassmorphicCard(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: unlocked ? const Color(0xFF10B981).withOpacity(0.12) : const Color(0xFF334155),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                unlocked ? Icons.card_giftcard : Icons.lock_outline,
                                color: unlocked ? const Color(0xFF10B981) : const Color(0xFF475569),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    g.title,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: unlocked ? Colors.white : Colors.white38,
                                    ),
                                  ),
                                  if (g.description.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 1),
                                      child: Text(
                                        g.description,
                                        style: GoogleFonts.inter(fontSize: 12, color: Colors.white38),
                                      ),
                                    ),
                                  if (g.link.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 1),
                                      child: Text(
                                        'Link: ${g.link}',
                                        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF10B981), decoration: TextDecoration.underline),
                                      ),
                                    ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Target Savings Required: ₹${g.target.toStringAsFixed(0)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: unlocked ? const Color(0xFF94A3B8) : Colors.white24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: unlocked ? const Color(0xFF10B981).withOpacity(0.12) : const Color(0xFF1E293B),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    unlocked ? 'UNLOCKED' : 'LOCKED',
                                    style: GoogleFonts.inter(
                                      color: unlocked ? const Color(0xFF10B981) : Colors.white38,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                                  onPressed: () => state.deleteGift(g.id),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}
