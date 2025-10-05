# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Lidya is a Flutter application for financial charting and technical analysis. The app supports real-time candlestick charts with technical indicators (SMA, EMA, DEMA, Bollinger Bands, RSI, MACD) and drawing tools (trendlines, Fibonacci retracements, freehand drawings).

## Development Commands

### Code Generation
The project uses `build_runner` for code generation (JSON serialization with Freezed):

```bash
# Generate code
flutter packages pub run build_runner build

# Generate with conflict resolution
flutter pub run build_runner build --delete-conflicting-outputs
```

Run code generation after modifying:
- Data models with `@JsonSerializable()` annotations
- Classes using Freezed for immutability

### Testing
```bash
# Run all tests
flutter test

# Run a specific test file
flutter test test/widget_test.dart
```

### Build & Run
```bash
# Get dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Build for specific platforms
flutter build macos
flutter build ios
flutter build android
```

### Linting
```bash
# Analyze code
flutter analyze
```

## Architecture

The codebase follows **Clean Architecture** with clear separation between layers:

### Layer Structure

```
lib/
├── domain/          # Business logic layer (platform-independent)
│   ├── entities/    # Core business objects (Candle, Drawing, Indicators)
│   ├── repositories/# Repository interfaces
│   ├── usecases/    # Business use cases
│   ├── services/    # Domain services (IndicatorCalculator)
│   └── providers/   # Riverpod providers for domain layer
├── data/            # Data layer (implements domain interfaces)
│   ├── models/      # DTOs with JSON serialization (*.g.dart generated)
│   ├── datasources/ # Data sources (remote API, local storage, WebSocket)
│   ├── repositories/# Repository implementations
│   ├── utils/       # Data layer utilities
│   └── providers/   # Riverpod providers for data layer
├── presentation/    # UI layer (widgets, painters, controllers, state)
├── core/            # Shared utilities, constants, extensions
└── app/             # App initialization and routing
```

### Key Architectural Patterns

**Dependency Injection**: The app uses **Riverpod** for state management and dependency injection. All providers are defined in:
- `lib/data/providers/data_providers.dart` - Data layer dependencies
- `lib/domain/providers/domain_providers.dart` - Use cases and domain services

**Data Flow**:
1. UI calls use cases via Riverpod providers
2. Use cases interact with repository interfaces (domain layer)
3. Repository implementations (data layer) fetch from data sources
4. DTOs are converted to domain entities at repository boundary

**DTO ↔ Domain Conversion**: Data models (DTOs) in `lib/data/models/` have `.toDomain()` methods to convert to domain entities. Domain entities are immutable and use `Equatable` for value equality.

### Presentation Layer Architecture

The presentation layer follows a **Controller + Painter** pattern:

**Chart State Management**:
- `ChartState` (`lib/presentation/state/chart_state.dart`) - Immutable state containing all chart data, indicators, drawings, zoom/pan parameters, and interaction mode
- `ChartController` (`lib/presentation/controllers/chart_controller.dart`) - StateNotifier that manages chart state, handles user interactions, loads data, and coordinates with domain layer
- Each chart widget creates its own StateNotifierProvider instance for isolated state

**Rendering System** (CustomPainter-based):
- `CandlePainter` - Renders candlestick bars with bullish/bearish coloring
- `PriceAxisPainter` & `TimeAxisPainter` - Render axes with formatted labels
- `GridPainter` - Draws background grid lines
- `OverlayIndicatorPainter` - Renders overlay indicators (MA, Bollinger Bands) on main chart
- `RSIPainter` & `MACDPainter` - Render bottom panel indicators with their own scales
- `DrawingPainter` - Renders user drawings (trendlines, Fibonacci, freehand)

**Interaction Handling**:
- `ChartGestureHandler` - Wraps chart with gesture detection for pan, zoom, hover, and drawing interactions
- Supports mouse wheel zoom, drag to pan, double-tap to reset zoom
- Crosshair tracking on hover with candle index detection
- Two interaction modes: Navigation (pan/zoom) and Drawing (add drawings)

**Main Widget**:
- `CandlestickChartWidget` (`lib/presentation/widgets/candlestick_chart_widget.dart`) - Main chart component that orchestrates all painters and handles layout
- Includes toolbar for indicator toggles, drawing tool selection, and zoom controls
- Dynamically shows bottom indicator panels when RSI/MACD are active

### State Management

Uses **Riverpod** with:
- `Provider` for stateless dependencies (repositories, services)
- `StateNotifierProvider` for chart state (each chart widget instance)
- `StreamProvider` for real-time data streams (e.g., `candleStreamProvider`)
- Family providers for parameterized providers

### Data Sources

**Development Mode**: The app defaults to `useFakeData = true` in `data_providers.dart:13`, using `FakeChartApiService` to generate realistic test data with configurable trends.

**Production Mode**: Set `useFakeDataProvider` to `false` to use real API via `ChartApiService` and WebSocket streams via `PriceStreamService`.

### Technical Indicators

All indicator calculations are in `lib/domain/services/indicator_calculator.dart`. To add a new indicator:

1. Create entity in `lib/domain/entities/indicators/`
2. Add calculation method in `IndicatorCalculator`
3. Update `createIndicator()` switch statement with new `IndicatorType`

### Drawing Tools

Drawing entities follow inheritance:
- Base class: `Drawing` (abstract)
- Implementations: `TrendlineDrawing`, `FibonacciDrawing`, `FreehandDrawing`

All drawings are stored in-memory via `ChartRepositoryImpl._drawingsCache` (no persistence yet).

## Chart Interaction & Gestures

**Pan (Horizontal Scrolling)**:
- Drag horizontally to scroll through historical data
- Controller automatically loads more data when approaching the left edge
- Vertical pan adjusts the price scale offset

**Zoom**:
- Mouse wheel up/down = zoom in/out (adjusts visible candle count)
- Pinch gesture on trackpad/touchscreen
- Toolbar buttons for zoom in/out/reset
- Double-tap to reset zoom to default
- Zoom limits: min 5 candles, max all available data

**Crosshair & Tooltips**:
- Hover over chart to show crosshair and highlight current candle
- State tracks `crosshairPosition` and `hoveredCandleIndex`

**Drawing Tools**:
- Select tool from toolbar (trendline, Fibonacci)
- Chart enters "drawing mode" (state.interactionMode = Drawing)
- Click points to define drawing (2 points for trendline/Fibonacci)
- Drawings are synchronized with time/price coordinates (persist across zoom/pan)
- Stored per symbol in repository

## Code Generation Files

Files ending in `.g.dart` are auto-generated - **do not edit manually**. Regenerate after model changes using build_runner.

## Platform Support

The project is configured for:
- macOS (primary development target)
- iOS
- Android
- Web
- Linux
- Windows
