import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trip_provider.dart';
import '../providers/expense_provider.dart';
import '../theme/app_theme.dart';

class BalancesScreen extends StatelessWidget {
  const BalancesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText.appLogo(size: 28),
            const SizedBox(width: 10),
            const Text('Settlements'),
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
                  const Icon(Icons.account_balance_wallet_outlined,
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

          final paidPerPerson = expProv.paidPerPerson(trip.participants);
          final settlements = expProv.computeSettlements(trip.participants);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('💰 Money Summary', style: AppText.cursive(size: 20)),
              const SizedBox(height: 16),
              _buildSummaryCards(paidPerPerson),
              const SizedBox(height: 24),
              Text('🤝 Who Owes Whom', style: AppText.cursive(size: 20)),
              const SizedBox(height: 16),
              if (settlements.isEmpty)
                _buildNoDebtsCard()
              else
                ...settlements.map((s) => _buildSettlementCard(s)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, double> paidPerPerson) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: paidPerPerson.entries.map((e) {
        return Container(
          width: 160,
          padding: const EdgeInsets.all(16),
          decoration: AppDecor.softCard.copyWith(
            border: Border.all(color: AppColors.skyBlue.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(e.key,
                  style: AppText.body(size: 14, weight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text('Paid', style: AppText.label(size: 11)),
              Text('₹${e.value.toStringAsFixed(2)}',
                  style: AppText.body(
                      size: 16, weight: FontWeight.w700, color: AppColors.mint)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNoDebtsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppDecor.softCard,
      child: Column(
        children: [
          const Icon(Icons.celebration_outlined,
              size: 40, color: AppColors.sunflower),
          const SizedBox(height: 12),
          Text('All Settled!',
              style: AppText.body(size: 15, weight: FontWeight.w600)),
          Text('No pending payments between participants.',
              textAlign: TextAlign.center,
              style: AppText.label(size: 12)),
        ],
      ),
    );
  }

  Widget _buildSettlementCard(Settlement s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppDecor.softCard,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.from,
                    style: AppText.body(size: 14, weight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
                Text('Owes', style: AppText.label(size: 11)),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.arrow_forward_rounded,
                color: AppColors.coral, size: 20),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(s.to,
                    style: AppText.body(size: 14, weight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
                Text('to receive', style: AppText.label(size: 11)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.coral.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '₹${s.amount.toStringAsFixed(2)}',
              style: AppText.body(
                  size: 14, weight: FontWeight.w700, color: AppColors.coral),
            ),
          ),
        ],
      ),
    );
  }
}
