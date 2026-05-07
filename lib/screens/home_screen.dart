import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../theme/app_theme.dart';
import 'trips_screen.dart';
import 'itinerary_screen.dart';
import 'expenses_screen.dart';
import 'balances_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isOnline = true;
  late StreamSubscription<List<ConnectivityResult>> _connectSub;

  final List<Widget> _screens = const [
    TripsScreen(),
    ItineraryScreen(),
    ExpensesScreen(),
    BalancesScreen(),
    DashboardScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _connectSub = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      setState(() {
        _isOnline = results.isNotEmpty &&
            !results.every((r) => r == ConnectivityResult.none);
      });
    });
    // Initial check
    Connectivity().checkConnectivity().then((results) {
      setState(() {
        _isOnline = results.isNotEmpty &&
            !results.every((r) => r == ConnectivityResult.none);
      });
    });
  }

  @override
  void dispose() {
    _connectSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ── Connectivity Banner ──
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isOnline ? 0 : 32,
            color: _isOnline ? AppColors.success : AppColors.danger,
            child: _isOnline
                ? const SizedBox.shrink()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text('Offline — data saved locally ✓',
                          style: AppText.body(
                              size: 12, color: Colors.white)),
                    ],
                  ),
          ),
          Expanded(
            child: IndexedStack(index: _currentIndex, children: _screens),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.coral,
          unselectedItemColor: AppColors.textMuted,
          selectedLabelStyle: AppText.label(size: 11, color: AppColors.coral),
          unselectedLabelStyle:
              AppText.label(size: 11, color: AppColors.textMuted),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.flight_takeoff), label: 'Trips'),
            BottomNavigationBarItem(
                icon: Icon(Icons.map_rounded), label: 'Itinerary'),
            BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_rounded), label: 'Expenses'),
            BottomNavigationBarItem(
                icon: Icon(Icons.pie_chart_rounded), label: 'Balances'),
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          ],
        ),
      ),
    );
  }
}
