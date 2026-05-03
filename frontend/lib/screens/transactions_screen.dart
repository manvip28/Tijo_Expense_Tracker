import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';
import '../widgets/glassmorphic_card.dart';

class TransactionsTab extends StatefulWidget {
  const TransactionsTab({Key? key}) : super(key: key);

  @override
  State<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<TransactionsTab> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _noteController = TextEditingController();
  final _dateController = TextEditingController();
  String _selectedCategory = 'Food';
  String _selectedType = 'Debit';
  String _searchQuery = '';
  String _filterCategory = 'All';

  final Map<String, String> _categoryEmojis = {
    'Food': '🍔',
    'Transport': '🚗',
    'Shopping': '🛍️',
    'Health': '💊',
    'Misc': '📦',
  };

  void _showAddExpenseSheet(BuildContext context) {
    _amountController.clear();
    _descController.clear();
    _noteController.clear();
    final now = DateTime.now();
    final padMonth = now.month.toString().padLeft(2, '0');
    final padDay = now.day.toString().padLeft(2, '0');
    final padHour = now.hour.toString().padLeft(2, '0');
    final padMin = now.minute.toString().padLeft(2, '0');
    _dateController.text = "${now.year}-$padMonth-$padDay $padHour:$padMin";
    _selectedCategory = 'Food';
    _selectedType = 'Debit';

    final state = context.read<AppState>();
    final categoriesList = state.limits.keys.toList();
    if (!categoriesList.contains('Food')) {
      categoriesList.insert(0, 'Food');
    }
    if (!categoriesList.contains('Misc')) {
      categoriesList.add('Misc');
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
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
                  'Lodge Transaction',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _dateController,
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Date & Time (YYYY-MM-DD HH:MM)',
                    labelStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                    enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF334155)), borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF10B981)), borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Amount (₹)',
                    labelStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                    enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF334155)), borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF10B981)), borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descController,
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                    enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF334155)), borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF10B981)), borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteController,
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Note (Optional details)',
                    labelStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                    enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF334155)), borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF10B981)), borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Transaction Type',
                  style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 6),
                Row(
                  children: ['Debit', 'Credit'].map((type) {
                    final isSelected = _selectedType == type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(type, style: GoogleFonts.inter(color: isSelected ? Colors.white : const Color(0xFF94A3B8))),
                        selected: isSelected,
                        selectedColor: type == 'Credit' ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        backgroundColor: const Color(0xFF334155),
                        onSelected: (val) {
                          if (val) {
                            setSheetState(() => _selectedType = type);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                Text(
                  'Category',
                  style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: categoriesList.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text('${_categoryEmojis[cat] ?? "📋"} $cat', style: GoogleFonts.inter(fontSize: 13, color: isSelected ? Colors.white : const Color(0xFF94A3B8))),
                      selected: isSelected,
                      selectedColor: const Color(0xFF10B981),
                      backgroundColor: const Color(0xFF334155),
                      onSelected: (val) {
                        if (val) {
                          setSheetState(() => _selectedCategory = cat);
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Add Option', style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    final amt = double.tryParse(_amountController.text) ?? 0.0;
                    final desc = _descController.text;
                    final noteStr = _noteController.text;
                    final dateStr = _dateController.text.trim();
                    if (amt > 0) {
                      state.addExpense(
                        amt,
                        _selectedCategory,
                        desc,
                        noteStr,
                        _selectedType,
                        dateStr.isNotEmpty ? dateStr : DateTime.now().toIso8601String().substring(0, 16).replaceAll("T", " "),
                      );
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF10B981),
                          content: Text('Transaction saved successfully', style: GoogleFonts.inter(color: Colors.white)),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditExpenseSheet(BuildContext context, Expense e) {
    _amountController.text = e.amount.toStringAsFixed(0);
    _descController.text = e.description;
    _noteController.text = e.note;
    _dateController.text = e.date;
    _selectedCategory = e.category;
    _selectedType = e.type == 'Income' || e.type == 'Credit' ? 'Credit' : 'Debit';

    final state = context.read<AppState>();
    final categoriesList = state.limits.keys.toList();
    if (!categoriesList.contains('Food')) {
      categoriesList.insert(0, 'Food');
    }
    if (!categoriesList.contains('Misc')) {
      categoriesList.add('Misc');
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
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
                  'Edit Transaction',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _dateController,
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Date & Time (YYYY-MM-DD HH:MM)',
                    labelStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                    enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF334155)), borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF10B981)), borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Amount (₹)',
                    labelStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                    enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF334155)), borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF10B981)), borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descController,
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                    enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF334155)), borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF10B981)), borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteController,
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Note (Optional details)',
                    labelStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                    enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF334155)), borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF10B981)), borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Transaction Type',
                  style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 6),
                Row(
                  children: ['Debit', 'Credit'].map((type) {
                    final isSelected = _selectedType == type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(type, style: GoogleFonts.inter(color: isSelected ? Colors.white : const Color(0xFF94A3B8))),
                        selected: isSelected,
                        selectedColor: type == 'Credit' ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        backgroundColor: const Color(0xFF334155),
                        onSelected: (val) {
                          if (val) {
                            setSheetState(() => _selectedType = type);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                Text(
                  'Category',
                  style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: categoriesList.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text('${_categoryEmojis[cat] ?? "📋"} $cat', style: GoogleFonts.inter(fontSize: 13, color: isSelected ? Colors.white : const Color(0xFF94A3B8))),
                      selected: isSelected,
                      selectedColor: const Color(0xFF10B981),
                      backgroundColor: const Color(0xFF334155),
                      onSelected: (val) {
                        if (val) {
                          setSheetState(() => _selectedCategory = cat);
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Save Edit', style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    final amt = double.tryParse(_amountController.text) ?? 0.0;
                    final desc = _descController.text;
                    final noteStr = _noteController.text;
                    final dateStr = _dateController.text.trim();
                    if (amt > 0) {
                      state.updateExpense(
                        e.id,
                        amt,
                        _selectedCategory,
                        desc,
                        noteStr,
                        _selectedType,
                        dateStr.isNotEmpty ? dateStr : DateTime.now().toIso8601String().substring(0, 16).replaceAll("T", " "),
                      );
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF10B981),
                          content: Text('Transaction updated successfully', style: GoogleFonts.inter(color: Colors.white)),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    List<Expense> filtered = state.expenses.where((e) {
      final matchesCategory = _filterCategory == 'All' || e.category == _filterCategory;
      final matchesSearch = e.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    filtered = filtered.reversed.toList();

    final filterCategories = ['All', ...state.limits.keys.toList()];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search logged transactions...',
                hintStyle: GoogleFonts.inter(color: Colors.white38, fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                fillColor: const Color(0xFF1E293B),
                filled: true,
                enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF334155)), borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF10B981)), borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: filterCategories.length,
              itemBuilder: (context, i) {
                final cat = filterCategories[i];
                final isSel = _filterCategory == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text('${_categoryEmojis[cat] ?? "📋"} $cat', style: GoogleFonts.inter(fontSize: 12)),
                    selected: isSel,
                    selectedColor: const Color(0xFF10B981),
                    backgroundColor: const Color(0xFF1E293B),
                    onSelected: (val) {
                      if (val) {
                        setState(() => _filterCategory = cat);
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long_rounded, size: 40, color: Color(0xFF334155)),
                        const SizedBox(height: 12),
                        Text(
                          'No transactions recorded.',
                          style: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                        )
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final e = filtered[i];
                      final isCredit = e.type == 'Credit' || e.type == 'Income';
                      return Dismissible(
                        key: ValueKey(e.id),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
                        ),
                        onDismissed: (direction) {
                          state.deleteExpense(e.id);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: GlassmorphicCard(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF334155),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(_categoryEmojis[e.category] ?? '📋', style: const TextStyle(fontSize: 18)),
                              ),
                              title: Text(
                                e.description.isNotEmpty ? e.description : 'Transaction #${e.id}',
                                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        e.category,
                                        style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '•  ${e.date}',
                                        style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  if (e.note.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        'Note: ${e.note}',
                                        style: GoogleFonts.inter(color: Colors.white38, fontSize: 12, fontStyle: FontStyle.italic),
                                      ),
                                    )
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${isCredit ? "+" : "-"} ₹${e.amount.toStringAsFixed(0)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isCredit ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    icon: const Icon(Icons.edit_rounded, color: Color(0xFF94A3B8), size: 20),
                                    onPressed: () => _showEditExpenseSheet(context, e),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF10B981),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        onPressed: () => _showAddExpenseSheet(context),
      ),
    );
  }
}
