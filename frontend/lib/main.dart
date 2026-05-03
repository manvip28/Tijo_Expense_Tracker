import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'api_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/goals_rewards_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..fetchData(),
      child: const TijoApp(),
    ),
  );
}

class TijoApp extends StatelessWidget {
  const TijoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tijo Wallet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFF10B981),
          primary: const Color(0xFF10B981),
          secondary: const Color(0xFF6366F1),
          surface: const Color(0xFF1E293B),
          background: const Color(0xFF0F172A),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
        ),
      ),
      home: const SplashOrMainPage(),
    );
  }
}

class SplashOrMainPage extends StatefulWidget {
  const SplashOrMainPage({Key? key}) : super(key: key);

  @override
  State<SplashOrMainPage> createState() => _SplashOrMainPageState();
}

class _SplashOrMainPageState extends State<SplashOrMainPage> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() => _showSplash = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded, size: 55, color: Color(0xFF10B981)),
              ),
              const SizedBox(height: 24),
              Text(
                'TIJO WALLET',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Simplifying money, everyday.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF94A3B8),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 48),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF10B981)),
              )
            ],
          ),
        ),
      );
    }
    return const MainNavigationPage();
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const DashboardTab(),
    const CategoriesTab(),
    const TransactionsTab(),
    const GoalsRewardsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TIJO WALLET',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.link_rounded, color: Color(0xFF94A3B8)),
            tooltip: 'Configure IP',
            onPressed: () {
              final ipController = TextEditingController(text: ApiService.baseUrl);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: Text('Backend URL', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  content: TextField(
                    controller: ipController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'URL (e.g. http://192.168.1.5:5000)',
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
                      child: Text('Connect', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        ApiService.baseUrl = ipController.text.trim();
                        state.fetchData();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF94A3B8)),
            tooltip: 'Refresh',
            onPressed: () => state.fetchData(),
          ),
          IconButton(
            icon: const Icon(Icons.settings_backup_restore, color: Color(0xFF94A3B8)),
            tooltip: 'Reset Tracker',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: Text('Reset Data', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  content: Text('Delete all transactions and reset limits?', style: GoogleFonts.inter(fontSize: 14)),
                  actions: [
                    TextButton(
                      child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white60)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                      child: Text('Reset', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        state.resetData();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
          : AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _tabs[_currentIndex],
            ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF1E293B), width: 1.0)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF0F172A),
          selectedItemColor: const Color(0xFF10B981),
          unselectedItemColor: const Color(0xFF475569),
          selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.normal, fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Overview',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart_outline_rounded),
              activeIcon: Icon(Icons.pie_chart_rounded),
              label: 'Limits',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long_rounded),
              label: 'Transactions',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined),
              activeIcon: Icon(Icons.emoji_events_rounded),
              label: 'Milestones',
            ),
          ],
        ),
      ),
    );
  }
}
