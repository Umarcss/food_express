import 'package:flutter/material.dart';
import 'package:food_express/components/empty_state.dart';
import 'package:food_express/core/money.dart';
import 'package:food_express/design/app_theme.dart';
import 'package:food_express/main.dart';
import 'package:food_express/models/order.dart';
import 'package:food_express/providers/order_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>().orderHistory;
    return Scaffold(
      appBar: AppBar(title: const Text('Order history')),
      body: orders.isEmpty
          ? EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No orders yet',
              message: 'Demo and paid orders will appear here after checkout.',
              action: FilledButton.icon(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                  (_) => false,
                ),
                icon: const Icon(Icons.restaurant_menu_rounded),
                label: const Text('Browse menu'),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _OrderHistoryCard(order: order);
              },
            ),
    );
  }
}

class _OrderHistoryCard extends StatelessWidget {
  final FoodOrder order;

  const _OrderHistoryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final createdAt = order.createdAt;
    final dateLabel = createdAt == null
        ? 'Just now'
        : DateFormat('MMM d, h:mm a').format(createdAt);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        onTap: () {
          context.read<OrderProvider>().selectOrder(order);
          Navigator.pushNamed(context, AppRoutes.delivery);
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _statusColor(order.status),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order ${_shortOrderId(order.id)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(dateLabel),
                      ],
                    ),
                  ),
                  _StatusPill(status: order.status),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${order.totalItemCount} item${order.totalItemCount == 1 ? '' : 's'} • ${order.deliveryAddress}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    formatKobo(order.totalKobo),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.charcoal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(OrderStatus status) {
    return switch (status) {
      OrderStatus.delivered => AppColors.success,
      OrderStatus.cancelled => AppColors.danger,
      OrderStatus.onTheWay => AppColors.gold,
      _ => AppColors.charcoal,
    };
  }
}

String _shortOrderId(String id) {
  return id.length <= 10 ? id : id.substring(0, 10);
}

class _StatusPill extends StatelessWidget {
  final OrderStatus status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        status.label,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
    );
  }
}
