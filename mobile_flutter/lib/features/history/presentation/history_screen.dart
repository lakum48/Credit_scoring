import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/http_client.dart';
import '../../predict/data/credit_api.dart';
import '../data/models/application.dart';
import '../logic/history_cubit.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HistoryCubit(CreditApi(createDio()))..load(),
      child: Scaffold(
        appBar: AppBar(title: const Text('История заявок')),
        body: BlocBuilder<HistoryCubit, HistoryState>(
          builder: (context, state) {
            if (state is HistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is HistoryError) {
              return Center(child: Text(state.message));
            }
            if (state is HistoryLoaded) {
              if (state.items.isEmpty) {
                return const Center(child: Text('Пока нет заявок'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (_, i) => _ApplicationCard(app: state.items[i]),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: state.items.length,
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({required this.app});
  final Application app;

  @override
  Widget build(BuildContext context) {
    final statusColor = app.approved ? Colors.green : Colors.red;
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  app.loanIntent,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Chip(
                  label: Text(app.approved ? 'Одобрено' : 'Отказ'),
                  backgroundColor: statusColor.withOpacity(0.15),
                  labelStyle: TextStyle(color: statusColor),
                  side: BorderSide(color: statusColor.withOpacity(0.4)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.attach_money, size: 18, color: Colors.grey.shade700),
                const SizedBox(width: 6),
                Text('Сумма: ${app.loanAmnt.toStringAsFixed(0)}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.percent, size: 18, color: Colors.grey.shade700),
                const SizedBox(width: 6),
                Text('Ставка: ${app.loanIntRate?.toStringAsFixed(2) ?? "-"}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.score, size: 18, color: Colors.grey.shade700),
                const SizedBox(width: 6),
                Text(
                    'Скор: ${((app.modelScore ?? 0) * 100).toStringAsFixed(1)}%'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_month,
                    size: 18, color: Colors.grey.shade700),
                const SizedBox(width: 6),
                Text(app.timestamp.toLocal().toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

