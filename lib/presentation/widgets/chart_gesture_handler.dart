import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../controllers/chart_controller.dart';
import '../state/chart_state.dart';

/// Widget that handles all chart gestures (pan, zoom, etc.)
class ChartGestureHandler extends StatefulWidget {
  final Widget child;
  final ChartController controller;
  final ChartState state;
  final Size chartSize;

  const ChartGestureHandler({
    super.key,
    required this.child,
    required this.controller,
    required this.state,
    required this.chartSize,
  });

  @override
  State<ChartGestureHandler> createState() => _ChartGestureHandlerState();
}

class _ChartGestureHandlerState extends State<ChartGestureHandler> {
  Offset? _panStartPosition;
  double _lastScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: _handlePointerSignal,
      child: GestureDetector(
        onPanStart: _handlePanStart,
        onPanUpdate: _handlePanUpdate,
        onPanEnd: _handlePanEnd,
        onScaleStart: _handleScaleStart,
        onScaleUpdate: _handleScaleUpdate,
        onScaleEnd: _handleScaleEnd,
        onDoubleTap: _handleDoubleTap,
        child: MouseRegion(
          onHover: _handleHover,
          onExit: _handleHoverExit,
          cursor: _getCursor(),
          child: widget.child,
        ),
      ),
    );
  }

  MouseCursor _getCursor() {
    switch (widget.state.interactionMode) {
      case InteractionMode.navigation:
        return SystemMouseCursors.grab;
      case InteractionMode.drawing:
        return SystemMouseCursors.precise;
    }
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      // Mouse wheel scrolling
      final delta = event.scrollDelta;

      // Vertical scroll = horizontal zoom (common pattern in trading charts)
      if (delta.dy != 0) {
        final scaleFactor = delta.dy > 0 ? 0.9 : 1.1;
        widget.controller.onZoom(scaleFactor);
      }

      // Horizontal scroll = pan
      if (delta.dx != 0) {
        widget.controller.onPanHorizontally(
          -delta.dx,
          widget.chartSize.width,
        );
      }
    }
  }

  void _handlePanStart(DragStartDetails details) {
    _panStartPosition = details.localPosition;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (widget.state.interactionMode == InteractionMode.navigation) {
      // Handle navigation pan
      final delta = details.delta;

      // Check if Ctrl/Cmd is pressed for vertical pan
      // Note: This is a simplified version. For proper modifier key detection,
      // you'd need to use RawKeyboard or HardwareKeyboard
      if (delta.dy.abs() > delta.dx.abs()) {
        // Vertical pan
        widget.controller.onPanVertically(-delta.dy);
      } else {
        // Horizontal pan
        widget.controller.onPanHorizontally(
          delta.dx,
          widget.chartSize.width,
        );
      }
    } else if (widget.state.interactionMode == InteractionMode.drawing) {
      // Handle drawing mode
      // This will be implemented with drawing tools
      _handleDrawingDrag(details.localPosition);
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    _panStartPosition = null;
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _lastScale = 1.0;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    // Handle pinch zoom (for trackpads and touch devices)
    if (details.scale != 1.0 && details.scale != _lastScale) {
      final scaleFactor = details.scale / _lastScale;
      widget.controller.onZoom(scaleFactor);
      _lastScale = details.scale;
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    _lastScale = 1.0;
  }

  void _handleDoubleTap() {
    // Reset zoom on double tap
    widget.controller.resetZoom();
  }

  void _handleHover(PointerHoverEvent event) {
    // Update crosshair position
    final position = event.localPosition;

    // Calculate which candle is being hovered
    final candleWidth = widget.chartSize.width / widget.state.visibleCandles.length;
    final candleIndex = (position.dx / candleWidth).floor();

    if (candleIndex >= 0 && candleIndex < widget.state.visibleCandles.length) {
      widget.controller.updateCrosshair(position, candleIndex);
    }
  }

  void _handleHoverExit(PointerExitEvent event) {
    // Clear crosshair
    widget.controller.updateCrosshair(null, null);
  }

  void _handleDrawingDrag(Offset position) {
    // This will be implemented when drawing tools are added
    // For now, just a placeholder
  }
}
