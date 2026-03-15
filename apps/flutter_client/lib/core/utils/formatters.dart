import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static final _currencyFormatter = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 0,
  );

  static final _compactFormatter = NumberFormat.compact();
  static final _dateFormatter = DateFormat('MMM dd, yyyy');
  static final _dateTimeFormatter = DateFormat('MMM dd, yyyy • HH:mm');

  static String currency(double amount) => _currencyFormatter.format(amount);

  static String currencyCompact(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '\$${amount.toStringAsFixed(0)}';
  }

  static String compact(num value) => _compactFormatter.format(value);

  static String date(DateTime dateTime) => _dateFormatter.format(dateTime);

  static String dateTime(DateTime dateTime) => _dateTimeFormatter.format(dateTime);

  static String relativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }

  static String percentage(double value, {int decimals = 1}) {
    return '${value.toStringAsFixed(decimals)}%';
  }

  static String progressPercent(double raised, double target) {
    if (target <= 0) return '0%';
    final pct = (raised / target * 100).clamp(0, 100);
    return '${pct.toStringAsFixed(1)}%';
  }
}