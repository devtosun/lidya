import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// void main() {
//   runApp(
//     const ProviderScope(
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         home: ChartScreen(
//           symbol: 'BTCUSD',
//           interval: Duration(minutes: 15),
//         ),
//       ),
//     ),
//   );
// }

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Candlestick Chart',
      theme: ThemeData.dark(useMaterial3: true),
      home: const ChartScreen(),
    );
  }
}

// ============ MODELS ============
class CandlestickData {
  final DateTime timestamp;
  final double open;
  final double high;
  final double low;
  final double close;

  CandlestickData({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });

  bool get isBullish => close >= open;
}

// ============ VIEWPORT MODEL ============
class ChartViewport {
  final double startIndex; // Görünen ilk mum index'i
  final double endIndex;   // Görünen son mum index'i
  final double minPrice;   // Görünen minimum fiyat
  final double maxPrice;   // Görünen maksimum fiyat

  ChartViewport({
    required this.startIndex,
    required this.endIndex,
    required this.minPrice,
    required this.maxPrice,
  });

  ChartViewport copyWith({
    double? startIndex,
    double? endIndex,
    double? minPrice,
    double? maxPrice,
  }) {
    return ChartViewport(
      startIndex: startIndex ?? this.startIndex,
      endIndex: endIndex ?? this.endIndex,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }

  double get visibleRange => endIndex - startIndex;
  double get priceRange => maxPrice - minPrice;
}

// ============ COMMAND PATTERN ============
abstract class DrawCommand {
  void execute();
  void undo();
  String get description;
}

class AddCandlestickCommand implements DrawCommand {
  final List<CandlestickData> data;
  final CandlestickData candlestick;

  AddCandlestickCommand(this.data, this.candlestick);

  @override
  void execute() => data.add(candlestick);

  @override
  void undo() {
    if (data.isNotEmpty) data.removeLast();
  }

  @override
  String get description => 'Mum eklendi';
}

class ClearAllCommand implements DrawCommand {
  final List<CandlestickData> data;
  late final List<CandlestickData> backup;

  ClearAllCommand(this.data) {
    backup = List.from(data);
  }

  @override
  void execute() => data.clear();

  @override
  void undo() => data.addAll(backup);

  @override
  String get description => 'Tümü temizlendi';
}

class GenerateBatchCommand implements DrawCommand {
  final List<CandlestickData> data;
  final List<CandlestickData> generated;

  GenerateBatchCommand(this.data, this.generated);

  @override
  void execute() => data.addAll(generated);

  @override
  void undo() {
    for (int i = 0; i < generated.length; i++) {
      if (data.isNotEmpty) data.removeLast();
    }
  }

  @override
  String get description => '${generated.length} mum eklendi';
}

// ============ STRATEGY PATTERN ============
abstract class ChartDrawStrategy {
  void draw(Canvas canvas, Size size, List<CandlestickData> data, ChartViewport viewport);
  String get name;
}

class CandlestickDrawStrategy implements ChartDrawStrategy {
  @override
  String get name => 'Candlestick';

  @override
  void draw(Canvas canvas, Size size, List<CandlestickData> data, ChartViewport viewport) {
    if (data.isEmpty) return;

    final startIdx = viewport.startIndex.floor().clamp(0, data.length - 1);
    final endIdx = viewport.endIndex.ceil().clamp(0, data.length);
    final visibleData = data.sublist(startIdx, endIdx);

    if (visibleData.isEmpty) return;

    final priceRange = viewport.priceRange;
    if (priceRange == 0) return;

    // Grid çizgileri
    _drawGrid(canvas, size, viewport.minPrice, viewport.maxPrice, priceRange);

    // Candlestick çizimi
    final visibleRange = viewport.visibleRange;
    final candleWidth = (size.width / visibleRange * 0.7).clamp(2.0, 20.0);
    final spacing = size.width / visibleRange;

    for (int i = 0; i < visibleData.length; i++) {
      final candle = visibleData[i];
      final relativeIndex = (startIdx + i) - viewport.startIndex;
      final x = relativeIndex * spacing + spacing / 2;

      final openY = size.height - ((candle.open - viewport.minPrice) / priceRange * size.height);
      final closeY = size.height - ((candle.close - viewport.minPrice) / priceRange * size.height);
      final highY = size.height - ((candle.high - viewport.minPrice) / priceRange * size.height);
      final lowY = size.height - ((candle.low - viewport.minPrice) / priceRange * size.height);

      final color = candle.isBullish ? Colors.green : Colors.red;

      // Fitil (wick)
      canvas.drawLine(
        Offset(x, highY),
        Offset(x, lowY),
        Paint()
          ..color = color
          ..strokeWidth = 1.5,
      );

      // Gövde (body)
      final bodyHeight = (closeY - openY).abs();
      final rect = Rect.fromLTWH(
        x - candleWidth / 2,
        min(openY, closeY),
        candleWidth,
        bodyHeight == 0 ? 1 : bodyHeight,
      );

      canvas.drawRect(
        rect,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
      canvas.drawRect(
        rect,
        Paint()
          ..color = color.withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  void _drawGrid(Canvas canvas, Size size, double minPrice, double maxPrice, double priceRange) {
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.15)
      ..strokeWidth = 1;

    for (int i = 0; i <= 8; i++) {
      final y = (size.height * i / 8);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }
}

class LineDrawStrategy implements ChartDrawStrategy {
  @override
  String get name => 'Line Chart';

  @override
  void draw(Canvas canvas, Size size, List<CandlestickData> data, ChartViewport viewport) {
    if (data.isEmpty) return;

    final startIdx = viewport.startIndex.floor().clamp(0, data.length - 1);
    final endIdx = viewport.endIndex.ceil().clamp(0, data.length);
    final visibleData = data.sublist(startIdx, endIdx);

    if (visibleData.isEmpty) return;

    final priceRange = viewport.priceRange;
    if (priceRange == 0) return;

    // Grid
    _drawGrid(canvas, size, viewport.minPrice, viewport.maxPrice, priceRange);

    // Line chart
    final path = Path();
    final points = <Offset>[];
    final visibleRange = viewport.visibleRange;

    for (int i = 0; i < visibleData.length; i++) {
      final relativeIndex = (startIdx + i) - viewport.startIndex;
      final x = relativeIndex * (size.width / visibleRange);
      final y = size.height - ((visibleData[i].close - viewport.minPrice) / priceRange * size.height);
      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.blue
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );

    // Noktalar
    for (final point in points) {
      canvas.drawCircle(point, 4, Paint()..color = Colors.blue);
      canvas.drawCircle(point, 3, Paint()..color = Colors.white);
    }
  }

  void _drawGrid(Canvas canvas, Size size, double minPrice, double maxPrice, double priceRange) {
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.15)
      ..strokeWidth = 1;

    for (int i = 0; i <= 8; i++) {
      final y = (size.height * i / 8);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }
}

class BarDrawStrategy implements ChartDrawStrategy {
  @override
  String get name => 'Bar Chart';

  @override
  void draw(Canvas canvas, Size size, List<CandlestickData> data, ChartViewport viewport) {
    if (data.isEmpty) return;

    final startIdx = viewport.startIndex.floor().clamp(0, data.length - 1);
    final endIdx = viewport.endIndex.ceil().clamp(0, data.length);
    final visibleData = data.sublist(startIdx, endIdx);

    if (visibleData.isEmpty) return;

    final priceRange = viewport.priceRange;
    if (priceRange == 0) return;

    final visibleRange = viewport.visibleRange;
    final barWidth = (size.width / visibleRange * 0.8).clamp(2.0, 30.0);
    final spacing = size.width / visibleRange;

    for (int i = 0; i < visibleData.length; i++) {
      final candle = visibleData[i];
      final relativeIndex = (startIdx + i) - viewport.startIndex;
      final x = relativeIndex * spacing + spacing / 2;
      final barHeight = ((candle.close - viewport.minPrice) / priceRange * size.height);
      final y = size.height - barHeight;

      final color = candle.isBullish ? Colors.green : Colors.red;

      canvas.drawRect(
        Rect.fromLTWH(x - barWidth / 2, y, barWidth, barHeight),
        Paint()..color = color,
      );
    }
  }
}

// ============ FACTORY PATTERN ============
class ChartStrategyFactory {
  static ChartDrawStrategy getStrategy(ChartType type) {
    switch (type) {
      case ChartType.candlestick:
        return CandlestickDrawStrategy();
      case ChartType.line:
        return LineDrawStrategy();
      case ChartType.bar:
        return BarDrawStrategy();
    }
  }
}

enum ChartType { candlestick, line, bar }

// ============ STATE MANAGEMENT ============
class ChartState {
  final List<CandlestickData> data;
  final List<DrawCommand> commandHistory;
  final ChartType chartType;
  final ChartViewport? viewport;

  ChartState({
    required this.data,
    required this.commandHistory,
    required this.chartType,
    this.viewport,
  });

  ChartState copyWith({
    List<CandlestickData>? data,
    List<DrawCommand>? commandHistory,
    ChartType? chartType,
    ChartViewport? viewport,
  }) {
    return ChartState(
      data: data ?? this.data,
      commandHistory: commandHistory ?? this.commandHistory,
      chartType: chartType ?? this.chartType,
      viewport: viewport ?? this.viewport,
    );
  }
}

class ChartNotifier extends StateNotifier<ChartState> {
  ChartNotifier()
      : super(
          ChartState(
            data: [],
            commandHistory: [],
            chartType: ChartType.candlestick,
          ),
        );

  void executeCommand(DrawCommand command) {
    command.execute();
    state = state.copyWith(commandHistory: [...state.commandHistory, command]);
    _updateViewport();
  }

  void undo() {
    if (state.commandHistory.isNotEmpty) {
      final command = state.commandHistory.last;
      command.undo();
      state = state.copyWith(
        commandHistory: state.commandHistory.sublist(0, state.commandHistory.length - 1),
      );
      _updateViewport();
    }
  }

  void generateRandomData(int count) {
    final random = Random();
    final now = DateTime.now();
    final generated = <CandlestickData>[];
    double lastClose = state.data.isEmpty ? 100.0 : state.data.last.close;

    for (int i = 0; i < count; i++) {
      final open = lastClose + random.nextDouble() * 10 - 5;
      final close = open + random.nextDouble() * 20 - 10;
      final high = max(open, close) + random.nextDouble() * 8;
      final low = min(open, close) - random.nextDouble() * 8;

      generated.add(
        CandlestickData(
          timestamp: now.add(Duration(minutes: (state.data.length + i) * 5)),
          open: open.clamp(0, 1000),
          high: high.clamp(0, 1000),
          low: low.clamp(0, 1000),
          close: close.clamp(0, 1000),
        ),
      );

      lastClose = close;
    }

    executeCommand(GenerateBatchCommand(state.data, generated));
  }

  void clearAll() {
    if (state.data.isNotEmpty) {
      executeCommand(ClearAllCommand(state.data));
    }
  }

  void setChartType(ChartType type) {
    state = state.copyWith(chartType: type);
  }

  void _updateViewport() {
    if (state.data.isEmpty) {
      state = state.copyWith(viewport: null);
      return;
    }

    final dataLength = state.data.length;
    final minPrice = state.data.map((e) => e.low).reduce(min);
    final maxPrice = state.data.map((e) => e.high).reduce(max);

    state = state.copyWith(
      viewport: ChartViewport(
        startIndex: 0,
        endIndex: dataLength.toDouble(),
        minPrice: minPrice,
        maxPrice: maxPrice,
      ),
    );
  }

  // Zoom işlemleri
  void zoom(double scale, double focalX, double chartWidth) {
    if (state.viewport == null || state.data.isEmpty) return;

    final viewport = state.viewport!;
    final visibleRange = viewport.visibleRange;
    final newRange = (visibleRange / scale).clamp(5.0, state.data.length.toDouble());

    // Odak noktası (focal point) merkezli zoom
    final focalRatio = focalX / chartWidth;
    final focalIndex = viewport.startIndex + (visibleRange * focalRatio);

    final newStartIndex = (focalIndex - (newRange * focalRatio)).clamp(0.0, state.data.length - newRange);
    final newEndIndex = newStartIndex + newRange;

    _updateVisiblePriceRange(newStartIndex, newEndIndex);
  }

  // Pan işlemleri
  void pan(double deltaX, double chartWidth) {
    if (state.viewport == null || state.data.isEmpty) return;

    final viewport = state.viewport!;
    final visibleRange = viewport.visibleRange;
    final indexDelta = -(deltaX / chartWidth) * visibleRange;

    var newStartIndex = (viewport.startIndex + indexDelta).clamp(0.0, state.data.length - visibleRange);
    var newEndIndex = newStartIndex + visibleRange;

    if (newEndIndex > state.data.length) {
      newEndIndex = state.data.length.toDouble();
      newStartIndex = newEndIndex - visibleRange;
    }

    _updateVisiblePriceRange(newStartIndex, newEndIndex);
  }

  // Dikey pan (fiyat ekseninde kaydırma)
  void panVertical(double deltaY, double chartHeight) {
    if (state.viewport == null || state.data.isEmpty) return;

    final viewport = state.viewport!;
    final priceRange = viewport.priceRange;
    final priceDelta = (deltaY / chartHeight) * priceRange;

    state = state.copyWith(
      viewport: viewport.copyWith(
        minPrice: viewport.minPrice + priceDelta,
        maxPrice: viewport.maxPrice + priceDelta,
      ),
    );
  }

  void _updateVisiblePriceRange(double startIndex, double endIndex) {
    final startIdx = startIndex.floor().clamp(0, state.data.length - 1);
    final endIdx = endIndex.ceil().clamp(0, state.data.length);
    final visibleData = state.data.sublist(startIdx, endIdx);

    if (visibleData.isEmpty) return;

    final minPrice = visibleData.map((e) => e.low).reduce(min);
    final maxPrice = visibleData.map((e) => e.high).reduce(max);

    state = state.copyWith(
      viewport: ChartViewport(
        startIndex: startIndex,
        endIndex: endIndex,
        minPrice: minPrice,
        maxPrice: maxPrice,
      ),
    );
  }

  void resetZoom() {
    _updateViewport();
  }
}

final chartProvider = StateNotifierProvider<ChartNotifier, ChartState>((ref) {
  return ChartNotifier();
});

// ============ AXIS WIDGETS ============
class YAxisPainter extends CustomPainter {
  final double minPrice;
  final double maxPrice;
  final double priceRange;

  YAxisPainter({
    required this.minPrice,
    required this.maxPrice,
    required this.priceRange,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF1A1A1A),
    );

    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    for (int i = 0; i <= 8; i++) {
      final y = (size.height * i / 8);

      canvas.drawLine(
        Offset(size.width - 10, y),
        Offset(size.width, y),
        gridPaint,
      );

      final price = maxPrice - (priceRange * i / 8);
      final textPainter = TextPainter(
        text: TextSpan(
          text: '\$${price.toStringAsFixed(1)}',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.right,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(size.width - textPainter.width - 15, y - 8),
      );
    }
  }

  @override
  bool shouldRepaint(YAxisPainter oldDelegate) {
    return oldDelegate.minPrice != minPrice ||
        oldDelegate.maxPrice != maxPrice ||
        oldDelegate.priceRange != priceRange;
  }
}

class XAxisPainter extends CustomPainter {
  final List<CandlestickData> data;
  final ChartViewport viewport;

  XAxisPainter({required this.data, required this.viewport});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF1A1A1A),
    );

    if (data.isEmpty) return;

    final startIdx = viewport.startIndex.floor().clamp(0, data.length - 1);
    final endIdx = viewport.endIndex.ceil().clamp(0, data.length);
    final visibleData = data.sublist(startIdx, endIdx);

    if (visibleData.isEmpty) return;

    final step = (visibleData.length / 6).ceil().clamp(1, visibleData.length);
    final visibleRange = viewport.visibleRange;

    for (int i = 0; i < visibleData.length; i += step) {
      final relativeIndex = i.toDouble();
      final x = (relativeIndex / visibleRange) * size.width;
      final time = visibleData[i].timestamp;

      canvas.drawLine(
        Offset(x, 0),
        Offset(x, 10),
        Paint()
          ..color = Colors.grey.withValues(alpha: 0.3)
          ..strokeWidth = 1,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, 15));
    }
  }

  @override
  bool shouldRepaint(XAxisPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.viewport != viewport;
  }
}

// ============ CUSTOM PAINTER ============
class ChartPainter extends CustomPainter {
  final List<CandlestickData> data;
  final ChartDrawStrategy strategy;
  final ChartViewport viewport;

  ChartPainter({
    required this.data,
    required this.strategy,
    required this.viewport,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF1A1A1A),
    );

    strategy.draw(canvas, size, data, viewport);
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.strategy.runtimeType != strategy.runtimeType ||
        oldDelegate.viewport != viewport;
  }
}

// ============ INTERACTIVE CHART WIDGET ============
class InteractiveChartArea extends ConsumerStatefulWidget {
  final ChartState chartState;
  final ChartDrawStrategy strategy;

  const InteractiveChartArea({
    super.key,
    required this.chartState,
    required this.strategy,
  });

  @override
  ConsumerState<InteractiveChartArea> createState() => _InteractiveChartAreaState();
}

class _InteractiveChartAreaState extends ConsumerState<InteractiveChartArea> {
  double _lastScale = 1.0;
  Offset? _lastPanPosition;

  @override
  Widget build(BuildContext context) {
    final data = widget.chartState.data;
    final viewport = widget.chartState.viewport;

    if (data.isEmpty || viewport == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.candlestick_chart, size: 64, color: Colors.grey[700]),
            const SizedBox(height: 16),
            Text('Veri oluşturmak için butona basın', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Listener(
                  onPointerSignal: (pointerSignal) {
                    if (pointerSignal is PointerScrollEvent) {
                      final chartNotifier = ref.read(chartProvider.notifier);
                      final box = context.findRenderObject() as RenderBox;
                      final localPosition = box.globalToLocal(pointerSignal.position);
                      final chartWidth = box.size.width;

                      // Mouse wheel zoom
                      final scrollDelta = pointerSignal.scrollDelta.dy;
                      final zoomFactor = scrollDelta > 0 ? 0.9 : 1.1;
                      chartNotifier.zoom(zoomFactor, localPosition.dx, chartWidth);
                    }
                  },
                  child: GestureDetector(
                    onScaleStart: (details) {
                      _lastScale = 1.0;
                      _lastPanPosition = details.localFocalPoint;
                    },
                    onScaleUpdate: (details) {
                      final chartNotifier = ref.read(chartProvider.notifier);
                      final box = context.findRenderObject() as RenderBox;
                      final chartWidth = box.size.width;
                      final chartHeight = box.size.height;

                      // Zoom (pinch gesture)
                      if (details.scale != 1.0 && details.scale != _lastScale) {
                        final localFocalX = details.localFocalPoint.dx;
                        chartNotifier.zoom(details.scale / _lastScale, localFocalX, chartWidth);
                        _lastScale = details.scale;
                      }

                      // Pan (drag) - tek parmak/mouse
                      if (details.scale == 1.0 && _lastPanPosition != null) {
                        final delta = details.localFocalPoint - _lastPanPosition!;
                        chartNotifier.pan(delta.dx, chartWidth);
                        chartNotifier.panVertical(delta.dy, chartHeight);
                      }

                      _lastPanPosition = details.localFocalPoint;
                    },
                    onScaleEnd: (details) {
                      _lastPanPosition = null;
                    },
                    onDoubleTap: () {
                      // Çift tıklama ile zoom reset
                      ref.read(chartProvider.notifier).resetZoom();
                    },
                    child: CustomPaint(
                      painter: ChartPainter(
                        data: data,
                        strategy: widget.strategy,
                        viewport: viewport,
                      ),
                      child: Container(),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 50,
                child: CustomPaint(
                  painter: XAxisPainter(data: data, viewport: viewport),
                  child: Container(),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 60,
          child: Column(
            children: [
              Expanded(
                child: CustomPaint(
                  painter: YAxisPainter(
                    minPrice: viewport.minPrice,
                    maxPrice: viewport.maxPrice,
                    priceRange: viewport.priceRange,
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ],
    );
  }
}

// ============ UI ============
class ChartScreen extends ConsumerWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartState = ref.watch(chartProvider);
    final chartNotifier = ref.read(chartProvider.notifier);
    final strategy = ChartStrategyFactory.getStrategy(chartState.chartType);

    return Scaffold(
      appBar: AppBar(
        title: Text('${strategy.name} - Interactive Chart'),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out_map),
            onPressed: chartState.data.isEmpty ? null : () => chartNotifier.resetZoom(),
            tooltip: 'Reset Zoom',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[900],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ChartType.values.map((type) {
                final selected = chartState.chartType == type;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(ChartStrategyFactory.getStrategy(type).name),
                    selected: selected,
                    onSelected: (_) => chartNotifier.setChartType(type),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: InteractiveChartArea(
              chartState: chartState,
              strategy: strategy,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.show_chart, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      '${chartState.data.length} mum | ${chartState.commandHistory.length} işlem | Pinch: Zoom, Drag: Pan',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => chartNotifier.generateRandomData(10),
                      icon: const Icon(Icons.add_chart),
                      label: const Text('10 Mum Ekle'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => chartNotifier.generateRandomData(20),
                      icon: const Icon(Icons.auto_graph),
                      label: const Text('20 Mum Ekle'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                    ),
                    ElevatedButton.icon(
                      onPressed: chartState.commandHistory.isEmpty ? null : () => chartNotifier.undo(),
                      icon: const Icon(Icons.undo),
                      label: const Text('Undo'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[700]),
                    ),
                    ElevatedButton.icon(
                      onPressed: chartState.data.isEmpty ? null : () => chartNotifier.clearAll(),
                      icon: const Icon(Icons.delete_sweep),
                      label: const Text('Temizle'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}