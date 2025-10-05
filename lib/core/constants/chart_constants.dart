class ChartConstants {
  ChartConstants._();

  // Zoom limits
  static const double minZoomLevel = 0.1;
  static const double maxZoomLevel = 100.0;
  static const double defaultZoomLevel = 1.0;
  static const double zoomSensitivity = 0.1;

  // Candle dimensions
  static const double minCandleWidth = 1.0;
  static const double maxCandleWidth = 50.0;
  static const double defaultCandleWidth = 8.0;
  static const double candleSpacing = 2.0;
  static const double wickWidth = 1.0;

  // Chart padding
  static const double leftPadding = 60.0;
  static const double rightPadding = 80.0;
  static const double topPadding = 20.0;
  static const double bottomPadding = 40.0;

  // Grid
  static const int targetPriceStepCount = 8;
  static const int targetTimeStepCount = 8;
  static const double gridLineWidth = 0.5;

  // Axis
  static const double axisLabelFontSize = 11.0;
  static const double axisLabelPadding = 5.0;
  static const double axisTickLength = 5.0;

  // Crosshair
  static const double crosshairLineWidth = 1.0;
  static const double crosshairLabelPadding = 8.0;
  static const double crosshairLabelFontSize = 12.0;

  // Drawing tools
  static const double drawingLineWidth = 2.0;
  static const double controlPointRadius = 6.0;
  static const double hitTestTolerance = 10.0;
  static const double dashLength = 10.0;
  static const double dashGap = 5.0;

  // Indicator
  static const double indicatorLineWidth = 2.0;
  static const int defaultMAPeriod = 20;
  static const int defaultRSIPeriod = 14;
  static const int defaultMACDFast = 12;
  static const int defaultMACDSlow = 26;
  static const int defaultMACDSignal = 9;

  // Panel
  static const double mainPanelRatio = 0.7;
  static const double indicatorPanelRatio = 0.3;
  static const double panelSplitterHeight = 4.0;
  static const double minPanelHeight = 50.0;

  // Performance
  static const int maxVisibleCandles = 500;
  static const int viewportCullBuffer = 5;
  static const Duration cacheDefaultTTL = Duration(minutes: 5);
  static const int maxCacheSize = 100;

  // Animation
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);

  // Touch
  static const double minDragDistance = 5.0;
  static const Duration longPressDuration = Duration(milliseconds: 500);
  static const Duration doubleTapTimeout = Duration(milliseconds: 300);

  // Price formatting
  static const int defaultPriceDecimals = 2;
  static const int cryptoPriceDecimals = 8;
  static const int forexPriceDecimals = 5;

  // Time intervals (milliseconds)
  static const int minute1 = 60000;
  static const int minute5 = 300000;
  static const int minute15 = 900000;
  static const int minute30 = 1800000;
  static const int hour1 = 3600000;
  static const int hour4 = 14400000;
  static const int day1 = 86400000;
  static const int week1 = 604800000;
  static const int month1 = 2592000000;
}