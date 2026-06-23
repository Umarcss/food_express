import 'package:flutter/material.dart';
import 'package:food_express/components/my_button.dart';
import 'package:food_express/core/money.dart';
import 'package:food_express/design/app_theme.dart';
import 'package:food_express/main.dart';
import 'package:food_express/providers/auth_provider.dart';
import 'package:food_express/providers/cart_provider.dart';
import 'package:food_express/providers/notification_provider.dart';
import 'package:food_express/providers/order_provider.dart';
import 'package:provider/provider.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  static const bool _livePaymentsEnabled = bool.fromEnvironment(
    'ENABLE_LIVE_PAYMENTS',
    defaultValue: false,
  );

  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _addressController.text = auth.defaultAddress;
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final orders = context.read<OrderProvider>();
    if (auth.user == null) return;
    final success = await orders.checkout(
      userId: auth.user!.uid,
      items: cart.items,
      deliveryAddress: _addressController.text.trim(),
    );
    if (!mounted) return;
    if (success) {
      cart.clear();
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.delivery,
        ModalRoute.withName(AppRoutes.home),
      );
    }
  }

  void _continueWithDemo() {
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    context.read<OrderProvider>().useDemoOrder(
          userId: auth.user?.uid ?? 'demo-user',
          items: cart.items,
          deliveryAddress: _addressController.text.trim(),
        );
    final order = context.read<OrderProvider>().currentOrder;
    context.read<NotificationProvider>().addDemoNotification(
      title: 'Order confirmed',
      body: order == null
          ? 'Your demo order is moving to the kitchen.'
          : 'Order ${_shortOrderId(order.id)} is confirmed and paid.',
      data: {'orderId': order?.id},
    );
    cart.clear();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.delivery,
      ModalRoute.withName(AppRoutes.home),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final orders = context.watch<OrderProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _CheckoutStep(number: '1', label: 'Delivery'),
                const SizedBox(height: AppSpacing.lg),
                Text('Delivery address',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _addressController,
                  minLines: 2,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.location_on_outlined),
                    hintText: 'Enter delivery address',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _CheckoutStep(number: '2', label: 'Summary'),
                const SizedBox(height: AppSpacing.lg),
                Text('Order summary',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                _Row(label: 'Subtotal', value: formatKobo(cart.subtotalKobo)),
                _Row(
                    label: 'Delivery', value: formatKobo(cart.deliveryFeeKobo)),
                const Divider(height: 28),
                _Row(
                  label: 'Total',
                  value: formatKobo(cart.totalKobo),
                  isTotal: true,
                ),
              ],
            ),
          ),
          if (orders.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Text(
                orders.errorMessage!,
                style: const TextStyle(color: AppColors.danger),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (!_livePaymentsEnabled) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: AppColors.gold),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Paystack is paused on the free plan. Demo delivery is ready.',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          PrimaryButton(
            text: _livePaymentsEnabled
                ? 'Pay securely with Paystack'
                : 'Paystack unavailable',
            icon: Icons.lock_outline,
            isLoading: orders.isProcessing,
            onPressed: cart.isEmpty || !_livePaymentsEnabled ? null : _pay,
          ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton.icon(
            onPressed: cart.isEmpty ? null : _continueWithDemo,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
            icon: const Icon(Icons.delivery_dining_rounded),
            label: const Text('Continue with demo delivery'),
          ),
        ],
      ),
    );
  }
}

String _shortOrderId(String id) {
  return id.length <= 10 ? id : id.substring(0, 10);
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(AppRadii.lg),
    border: Border.all(color: AppColors.line),
    boxShadow: AppShadows.tight(AppColors.charcoal),
  );
}

class _CheckoutStep extends StatelessWidget {
  final String number;
  final String label;

  const _CheckoutStep({
    required this.number,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.gold,
          child: Text(
            number,
            style: const TextStyle(
              color: AppColors.charcoal,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _Row({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final valueStyle = TextStyle(
            color: isTotal ? AppColors.tomato : AppColors.charcoal,
            fontWeight: FontWeight.w900,
            fontSize: isTotal ? 20 : 15,
          );
          if (constraints.maxWidth < 180) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value, style: valueStyle),
                ),
              ],
            );
          }
          return Row(
            children: [
              Expanded(
                child: Text(label, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(value, style: valueStyle),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
