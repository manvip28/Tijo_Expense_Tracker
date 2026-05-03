import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../widgets/glassmorphic_card.dart';

class CategoriesTab extends StatefulWidget {
  const CategoriesTab({Key? key}) : super(key: key);

  @override
  State<CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<CategoriesTab> {
  final _limitController = TextEditingController();
  final _newCategoryNameController = TextEditingController();

  final Map<String, String> _categoryEmojis = {
    'Monthly Budget': '💰',
    'Food': '🍔',
    'Transport': '🚗',
    'Shopping': '🛍️',
    'Health': '💊',
    'Misc': '📦',
  };

  void _showAddCategoryDialog(BuildContext context, AppState state) {
    _newCategoryNameController.clear();
    _limitController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add New Category Limit', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _newCategoryNameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Category Name',
                labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF334155)), borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF10B981)), borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _limitController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Target Limit (₹)',
                labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF334155)), borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF10B981)), borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white60)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), elevation: 0),
            child: Text('Add', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () {
              final cat = _newCategoryNameController.text.trim();
              final limit = double.tryParse(_limitController.text) ?? 0.0;
              if (cat.isNotEmpty) {
                final Map<String, double> updated = Map<String, double>.from(state.limits);
                updated[cat] = limit;
                state.setLimits(updated);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context, String cat, double existingLimit) {
    _limitController.text = existingLimit.toString();
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set limits for $cat ${_categoryEmojis[cat] ?? ""}',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _limitController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Limit Target (₹)',
                labelStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF10B981)),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Save Budget', style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              onPressed: () {
                final newLim = double.tryParse(_limitController.text) ?? 0.0;
                final state = context.read<AppState>();
                final update = Map<String, double>.from(state.limits);
                update[cat] = newLim;
                state.setLimits(update);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final categoryTotals = <String, double>{};
    for (var e in state.expenses) {
      if (e.type != 'Income') {
        categoryTotals[e.category] = (categoryTotals[e.category] ?? 0.0) + e.amount;
      }
    }

    final availableCategories = state.limits.keys.toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text('LIMITS & CATEGORIES', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF10B981)),
            tooltip: 'Add Category Limit',
            onPressed: () => _showAddCategoryDialog(context, state),
          )
        ],
      ),
      body: availableCategories.isEmpty
          ? Center(
              child: Text(
                'No limits configured.\nClick + to create one!',
                style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 14),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: availableCategories.length,
              itemBuilder: (context, i) {
                final cat = availableCategories[i];
                final limit = state.limits[cat] ?? 0.0;
                final spent = categoryTotals[cat] ?? 0.0;
                final balance = limit - spent;
                final isExceeded = balance < 0;

                final percent = limit > 0 ? (spent / limit) : 0.0;
                Color colorAccent;
                if (percent >= 1.0) {
                  colorAccent = const Color(0xFFEF4444);
                } else if (percent >= 0.75) {
                  colorAccent = const Color(0xFFF59E0B);
                } else {
                  colorAccent = const Color(0xFF10B981);
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: GlassmorphicCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${_categoryEmojis[cat] ?? "📋"}  ${cat.toUpperCase()}',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.1,
                                        color: isExceeded ? const Color(0xFFEF4444) : Colors.white,
                                      ),
                                    ),
                                    if (isExceeded) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEF4444).withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'EXCEEDED',
                                          style: GoogleFonts.inter(color: const Color(0xFFEF4444), fontSize: 9, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ]
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Limit Budget: ₹${limit.toStringAsFixed(0)}',
                                  style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Color(0xFF94A3B8)),
                                  onPressed: () => _showEditSheet(context, cat, limit),
                                ),
                                if (cat != 'Monthly Budget')
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                                    tooltip: 'Delete Category',
                                    onPressed: () {
                                      state.deleteLimit(cat);
                                    },
                                  ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: limit > 0 ? percent.clamp(0.0, 1.0) : 0,
                            minHeight: 8,
                            backgroundColor: const Color(0xFF334155),
                            valueColor: AlwaysStoppedAnimation<Color>(colorAccent),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Spent: ₹${spent.toStringAsFixed(0)}',
                              style: GoogleFonts.inter(color: Colors.white60, fontSize: 13),
                            ),
                            Text(
                              isExceeded ? 'Over limit by ₹${(spent - limit).toStringAsFixed(0)}' : 'Available: ₹${balance.toStringAsFixed(0)}',
                              style: GoogleFonts.inter(
                                color: isExceeded ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
