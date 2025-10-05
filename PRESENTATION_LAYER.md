# Presentation Layer Implementation

This document describes the presentation layer implementation for the Lidya financial charting application.

## Overview

The presentation layer implements a complete candlestick charting widget with:
- Real-time data updates via WebSocket
- Technical indicators (SMA, EMA, DEMA, Bollinger Bands, RSI, MACD)
- Drawing tools (trendlines, Fibonacci retracements, freehand)
- Interactive pan and zoom
- Crosshair with hover tracking
- Clean separation from domain and data layers

## Architecture

### State Management Pattern

The presentation layer uses **StateNotifier** pattern with Riverpod:

```
ChartState (immutable) ──> ChartController (StateNotifier) ──> UI (ConsumerWidget)
     ↑                              ↓
     └──────── State Updates ───────┘
```

### Component Structure

```
lib/presentation/
├── state/
│   └── chart_state.dart          # Immutable state model
├── controllers/
│   └── chart_controller.dart     # Business logic & state management
├── painters/
│   ├── candle_painter.dart       # Candlestick rendering
│   ├── axis_painter.dart         # Price/time axes + grid
│   ├── indicator_painter.dart    # Overlay indicators (MA, BB)
│   ├── bottom_indicator_painter.dart  # RSI, MACD panels
│   └── drawing_painter.dart      # User drawings
├── widgets/
│   ├── candlestick_chart_widget.dart  # Main chart widget
│   └── chart_gesture_handler.dart     # Gesture detection
├── screens/
│   └── chart_screen.dart         # Example screen
└── providers/
    └── presentation_providers.dart    # Provider factory
```

## Key Components

### 1. ChartState

**Location**: `lib/presentation/state/chart_state.dart`

Immutable state object containing:
- **Data**: `allCandles`, `visibleCandles` (current viewport)
- **Indicators**: `activeOverlayIndicators`, `activeBottomIndicators`
- **Drawings**: `drawings`, `currentDraftDrawing`, `selectedDrawingId`
- **View Parameters**: `visibleStartIndex`, `visibleEndIndex`, `horizontalScale`, `verticalScale`, `verticalOffset`
- **Interaction**: `interactionMode` (Navigation/Drawing), `selectedDrawingTool`
- **UI State**: `crosshairPosition`, `hoveredCandleIndex`, loading stage, error message

### 2. ChartController

**Location**: `lib/presentation/controllers/chart_controller.dart`

StateNotifier managing chart state with methods:

**Data Loading**:
- `loadInitialData()` - Fetch initial historical data
- `_loadMoreHistoricalData()` - Load older data when scrolling left
- `_handleNewCandle(Candle)` - Update chart with real-time data

**Navigation**:
- `onPanHorizontally(deltaPixels, canvasWidth)` - Scroll through time
- `onPanVertically(deltaPixels)` - Adjust price axis
- `onZoom(scaleFactor)` - Horizontal zoom (time axis)
- `onVerticalZoom(scaleFactor)` - Vertical zoom (price axis)
- `resetZoom()` - Return to default view

**Indicators**:
- `toggleIndicator(IndicatorType, params)` - Add/remove indicator
- `_recalculateIndicators()` - Recompute on new data

**Drawings**:
- `setInteractionMode(mode, drawingTool)` - Switch modes
- `addDrawing(Drawing)` - Save drawing to repository
- `updateDraftDrawing(Drawing?)` - Preview during creation
- `removeDrawing(drawingId)` - Delete drawing

**Crosshair**:
- `updateCrosshair(position, candleIndex)` - Track hover position

### 3. Custom Painters

All painters extend `CustomPainter` and share coordinate transformation logic:

**CandlePainter**:
- Renders OHLC candlesticks with wicks
- Bullish (green) / Bearish (red) coloring
- Handles vertical scale and offset
- Minimum body height for doji candles

**PriceAxisPainter & TimeAxisPainter**:
- Price axis: Shows price levels with current price highlighted
- Time axis: Formatted timestamps (adaptive: time/date/full date)
- Both synchronized with main chart scale

**GridPainter**:
- Background grid lines for both axes
- Semi-transparent for minimal distraction

**OverlayIndicatorPainter**:
- Renders MA lines (SMA, EMA, DEMA)
- Renders Bollinger Bands with filled area between bands
- Each indicator has configurable color

**RSIPainter & MACDPainter**:
- Separate panels below main chart
- RSI: 0-100 scale with 30/70 reference lines and overbought/oversold zones
- MACD: Histogram + MACD line + signal line with zero line

**DrawingPainter**:
- Trendline: Simple line between two points
- Fibonacci: Horizontal levels at 0%, 23.6%, 38.2%, 50%, 61.8%, 78.6%, 100%
- Freehand: Connected path through multiple points
- Selection handles for editing (when `selectedDrawingId` is set)
- Drawings synchronized with timestamp/price coordinates (persist across zoom/pan)

### 4. ChartGestureHandler

**Location**: `lib/presentation/widgets/chart_gesture_handler.dart`

Wraps chart with gesture detection:

**Mouse/Trackpad**:
- `onPointerSignal` - Mouse wheel scrolling (vertical = zoom, horizontal = pan)
- `onPanUpdate` - Drag to pan (horizontal/vertical based on direction)
- `onDoubleTap` - Reset zoom
- `onHover` - Update crosshair position

**Touch/Pinch**:
- `onScaleUpdate` - Pinch zoom on trackpad or touch devices

**Mode-aware**:
- Navigation mode: All gestures control viewport
- Drawing mode: Clicks/drags create drawings (to be fully implemented)

### 5. CandlestickChartWidget

**Location**: `lib/presentation/widgets/candlestick_chart_widget.dart`

Main chart component that:
1. Creates StateNotifierProvider for isolated chart state
2. Builds toolbar with indicator toggles, drawing tools, zoom controls
3. Orchestrates layout: main chart area + bottom indicator panels
4. Stacks painters in correct order: Grid → Candles → Indicators → Drawings
5. Wraps with ChartGestureHandler for interactions

**Layout Structure**:
```
Column
├── Toolbar (indicators, drawing tools, zoom)
└── Expanded Chart Area
    ├── Main Chart (70-100% height)
    │   └── Row
    │       ├── Canvas Stack (painters)
    │       └── Price Axis
    └── Bottom Indicators (0-30% height, if active)
```

## Data Flow

### Initial Load
```
ChartWidget created
    → ChartController initialized
    → loadInitialData()
    → Repository.getHistoricalData()
    → State updated with candles
    → UI rebuilds with new painters
```

### Real-time Updates
```
WebSocket receives new candle
    → Repository stream emits Candle
    → ChartController._handleNewCandle()
    → Update or append to allCandles
    → _recalculateIndicators()
    → State updated
    → UI rebuilds
```

### User Interaction (Pan)
```
User drags chart horizontally
    → GestureDetector.onPanUpdate
    → ChartGestureHandler._handlePanUpdate
    → Controller.onPanHorizontally(deltaPixels, canvasWidth)
    → Calculate candle shift
    → Update visibleStartIndex/visibleEndIndex
    → Update visibleCandles from allCandles
    → State updated
    → Painters redraw with new visible range
```

### User Interaction (Zoom)
```
User scrolls mouse wheel
    → Listener.onPointerSignal
    → ChartGestureHandler._handlePointerSignal
    → Controller.onZoom(scaleFactor)
    → Calculate new horizontalScale
    → Adjust visibleCandles count
    → Center around current viewport
    → State updated
    → Painters redraw with new zoom level
```

### Adding Indicator
```
User clicks "EMA 200" button
    → Controller.toggleIndicator(IndicatorType.ema, params)
    → IndicatorCalculator.createIndicator()
    → Calculate EMA values for all candles
    → Add to activeOverlayIndicators
    → State updated
    → OverlayIndicatorPainter draws EMA line
```

## Coordinate Systems

All painters use consistent coordinate transformation:

**Time (X-axis)**:
```dart
final candleWidth = size.width / candles.length;
final x = candleIndex * candleWidth + candleWidth / 2;
```

**Price (Y-axis)** - Inverted (0 = top, height = bottom):
```dart
final y = height - ((price - minPrice) / priceSpan * height);
```

**Zoom/Pan Adjustments**:
- Horizontal scale: Changes visible candle count
- Vertical scale: Expands/contracts price range symmetrically
- Vertical offset: Shifts entire price scale up/down

## Performance Considerations

1. **Painter Efficiency**:
   - `shouldRepaint()` checks prevent unnecessary redraws
   - Only visible candles are rendered
   - Grid and axes update only when scale changes

2. **State Updates**:
   - Immutable state with Equatable prevents redundant rebuilds
   - Controller batches related state changes

3. **Data Management**:
   - In-memory cache in repository
   - Lazy loading of historical data
   - Efficient list slicing for visible range

## Usage Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lidya/presentation/screens/chart_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MaterialApp(
        home: ChartScreen(
          symbol: 'BTCUSD',
          interval: Duration(minutes: 15),
        ),
      ),
    ),
  );
}
```

## Future Enhancements

**Drawing Tools**:
- Complete drawing mode implementation with point selection
- Drawing editing (move, resize, delete)
- More drawing types (horizontal line, rectangle, etc.)

**Crosshair**:
- Tooltip showing OHLCV values
- Indicator values at crosshair position
- Distance/price difference measurements

**Performance**:
- Canvas caching for static elements
- Web Worker for indicator calculations (web platform)
- Incremental indicator updates

**Features**:
- Multiple timeframe support with data synchronization
- Volume bars below main chart
- Order book / depth chart integration
- Alerts and notifications on price levels

## Testing

Recommended test coverage:

1. **ChartController Tests**:
   - Data loading scenarios
   - Pan/zoom calculations
   - Indicator toggle logic
   - Edge cases (empty data, single candle, etc.)

2. **Painter Tests**:
   - Coordinate transformations
   - Edge rendering (min/max values)
   - Color/style consistency

3. **Integration Tests**:
   - Full chart interaction flow
   - Real-time data updates
   - Drawing creation and persistence

4. **Widget Tests**:
   - UI rendering with different states
   - Toolbar interactions
   - Loading/error states
