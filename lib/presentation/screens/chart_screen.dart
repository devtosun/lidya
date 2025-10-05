import 'package:flutter/material.dart';
import '../widgets/candlestick_chart_widget.dart';

/// Example screen showing the candlestick chart
class ChartScreen extends StatelessWidget {
  final String symbol;
  final Duration interval;

  const ChartScreen({
    super.key,
    this.symbol = 'BTCUSD',
    this.interval = const Duration(minutes: 15),
  });

  @override
  Widget build(BuildContext context) {
    return CandlestickChartWidget(
      symbol: symbol,
      interval: interval,
    );
  }
}
