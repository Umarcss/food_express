import 'package:intl/intl.dart';

final NumberFormat _nairaFormat = NumberFormat.currency(
  locale: 'en_NG',
  symbol: '₦',
  decimalDigits: 0,
);

String formatKobo(int amountKobo) {
  return _nairaFormat.format(amountKobo / 100);
}

int deliveryFeeForSubtotal(int subtotalKobo) {
  if (subtotalKobo == 0) return 0;
  final calculated = (subtotalKobo * 0.1).round();
  return calculated.clamp(50000, 250000);
}
