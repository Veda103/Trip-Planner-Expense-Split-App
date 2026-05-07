import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/trip_provider.dart';
import '../providers/expense_provider.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText.appLogo(size: 28),
            const SizedBox(width: 10),
            const Text('Trip Summary'),
          ],
        ),
      ),
      body: Consumer2<TripProvider, ExpenseProvider>(
        builder: (context, tripProv, expProv, _) {
          final trip = tripProv.selectedTrip;
          if (trip == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.dashboard_outlined,
                      size: 56, color: AppColors.peach),
                  const SizedBox(height: 12),
                  Text('Pick a trip first!',
                      style: AppText.cursive(
                          size: 22, color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                  Text('Go to the Trips tab and select one',
                      style: AppText.body(size: 13, color: AppColors.textMuted)),
                ],
              ),
            );
          }

          expProv.loadForTrip(trip.id);
          final recentExpenses = expProv.expenses.take(5).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildTripBanner(trip),
              const SizedBox(height: 24),
              Text('📊 Quick Stats', style: AppText.cursive(size: 20)),
              const SizedBox(height: 16),
              _buildStatsGrid(trip, expProv),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('🧾 Recent Expenses', style: AppText.cursive(size: 20)),
                  TextButton(
                    onPressed: () {}, // Handled by bottom nav
                    child: Text('View all',
                        style: AppText.body(size: 12, color: AppColors.coral)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (recentExpenses.isEmpty)
                _buildEmptyRecent()
              else
                ...recentExpenses.map((e) => _buildRecentExpense(e)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTripBanner(trip) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(colors: [AppColors.coral, AppColors.coralDark]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.coral.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(trip.destination,
                  style: AppText.body(
                      size: 14, color: Colors.white, weight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Text(trip.name,
              style: AppText.cursive(size: 28, color: Colors.white)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                '${DateFormat('dd MMM').format(trip.startDate)} - ${DateFormat('dd MMM yyyy').format(trip.endDate)}',
                style: AppText.label(size: 12, color: Colors.white.withOpacity(0.9)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(trip, expProv) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Total Spent', '₹${expProv.totalExpenses.toStringAsFixed(0)}',
            Icons.account_balance_wallet, AppColors.skyBlue),
        _buildStatCard('Participants', '${trip.participants.length}',
            Icons.people, AppColors.lavender),
        _buildStatCard('Per Person',
            '₹${(expProv.totalExpenses / (trip.participants.length > 0 ? trip.participants.length : 1)).toStringAsFixed(0)}',
            Icons.analytics, AppColors.mint),
        _buildStatCard('Expenses', '${expProv.expenses.length}', Icons.receipt,
            AppColors.sunflower),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppDecor.softCard.copyWith(
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value,
              style: AppText.body(size: 16, weight: FontWeight.w700),
              overflow: TextOverflow.ellipsis),
          Text(label, style: AppText.label(size: 10)),
        ],
      ),
    );
  }

  Widget _buildEmptyRecent() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecor.softCard,
      child: Center(
        child: Text('No expenses recorded yet.',
            style: AppText.body(size: 13, color: AppColors.textMuted)),
      ),
    );
  }

  Widget _buildRecentExpense(e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: AppDecor.softCard,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.peach.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_bag_outlined,
                color: AppColors.coral, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.description,
                    style: AppText.body(size: 13, weight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
                Text(DateFormat('dd MMM').format(e.date),
                    style: AppText.label(size: 11)),
              ],
            ),
          ),
          Text('₹${e.amount.toStringAsFixed(0)}',
              style: AppText.body(
                  size: 14, weight: FontWeight.w700, color: AppColors.textDark)),
        ],
      ),
    );
  }
}
