/// Simple pie chart example.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class SimplePieChart extends StatelessWidget {
  final List<charts.Series<dynamic, String>> seriesList;
  final bool animate;

  const SimplePieChart(
      {Key? key, required this.seriesList, required this.animate})
      : super(key: key);

  /// Creates a [PieChart] with sample data and no transition.
  factory SimplePieChart.withSampleData() {
    return SimplePieChart(
      seriesList: _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return charts.PieChart<String>(seriesList, animate: animate);
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<LinearSales, String>> _createSampleData() {
    final data = [
      LinearSales('0', 100, charts.ColorUtil.fromDartColor(Colors.red)),
      LinearSales('1', 75, charts.ColorUtil.fromDartColor(Colors.red)),
      LinearSales('2', 25, charts.ColorUtil.fromDartColor(Colors.red)),
      LinearSales('3', 5, charts.ColorUtil.fromDartColor(Colors.red)),
    ];

    return [
      charts.Series<LinearSales, String>(
        id: 'Sales',
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        colorFn: (LinearSales sales, _) => sales.color,
        data: data,
      )
    ];
  }
}

/// Sample linear data type.
class LinearSales {
  final String year;
  final int sales;
  final charts.Color color;

  LinearSales(this.year, this.sales, this.color);
}
