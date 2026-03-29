import 'package:flutter/material.dart';

import '../../utils/localization.dart';

class AgroDashboardTab extends StatelessWidget {
  const AgroDashboardTab({
    super.key,
    required this.language,
    required this.dashboard,
  });

  final AppLanguage language;
  final Map<String, dynamic> dashboard;

  int _intValue(String key) {
    final value = dashboard[key];
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _doubleValue(String key) {
    final value = dashboard[key];
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final pendingAmount = _doubleValue('amount_pending');
    final completedAmount = _doubleValue('amount_completed');

    final metrics = <_DashboardMetric>[
      _DashboardMetric(
        title: t(language, 'agroFarmersCount'),
        value: _intValue('farmers_count').toString(),
        icon: Icons.groups_rounded,
        color: const Color(0xFF0F766E),
      ),
      _DashboardMetric(
        title: t(language, 'agroBillsTotal'),
        value: _intValue('bills_total').toString(),
        icon: Icons.receipt_long_rounded,
        color: const Color(0xFF1D4ED8),
      ),
      _DashboardMetric(
        title: t(language, 'agroBillsPending'),
        value: _intValue('bills_pending').toString(),
        icon: Icons.pending_actions_rounded,
        color: const Color(0xFFEA580C),
      ),
      _DashboardMetric(
        title: t(language, 'agroBillsCompleted'),
        value: _intValue('bills_completed').toString(),
        icon: Icons.verified_rounded,
        color: const Color(0xFF15803D),
      ),
      _DashboardMetric(
        title: '${t(language, 'agroPending')} ${t(language, 'agroAmountTotal')}',
        value: '₹ ${pendingAmount.toStringAsFixed(2)}',
        icon: Icons.trending_down_rounded,
        color: const Color(0xFFC2410C),
      ),
      _DashboardMetric(
        title: '${t(language, 'agroCompleted')} ${t(language, 'agroAmountTotal')}',
        value: '₹ ${completedAmount.toStringAsFixed(2)}',
        icon: Icons.trending_up_rounded,
        color: const Color(0xFF166534),
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFF14532D), Color(0xFF16A34A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t(language, 'agroCenterTitle'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                t(language, 'agroDashboardTab'),
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.38,
          ),
          itemBuilder: (_, index) {
            return _MetricCard(metric: metrics[index]);
          },
        ),
      ],
    );
  }
}

class _DashboardMetric {
  const _DashboardMetric({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final _DashboardMetric metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: metric.color.withValues(alpha: 0.16)),
        gradient: LinearGradient(
          colors: [
            metric.color.withValues(alpha: 0.12),
            metric.color.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: metric.color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(metric.icon, color: metric.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  metric.value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
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
