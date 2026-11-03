import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _usdFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static final NumberFormat _khrFormat = NumberFormat.currency(
    symbol: '៛',
    decimalDigits: 0,
  );

  static const double defaultExchangeRate = 4100.0;

  static String formatUsd(double amount) {
    return _usdFormat.format(amount);
  }

  static String formatKhr(double amountKhr) {
    return _khrFormat.format(amountKhr);
  }

  static String formatBoth(double usdAmount, [double rate = defaultExchangeRate]) {
    final khr = usdAmount * rate;
    return '${formatUsd(usdAmount)} (${formatKhr(khr)})';
  }
}

