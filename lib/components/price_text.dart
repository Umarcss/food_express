import 'package:flutter/material.dart';
import 'package:food_express/core/money.dart';
import 'package:food_express/design/app_theme.dart';

class PriceText extends StatelessWidget {
  final int amountKobo;
  final double fontSize;

  const PriceText({
    super.key,
    required this.amountKobo,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      formatKobo(amountKobo),
      style: TextStyle(
        color: AppColors.charcoal,
        fontWeight: FontWeight.w900,
        fontSize: fontSize,
      ),
    );
  }
}
