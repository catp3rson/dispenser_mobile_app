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
    return charts.PieChart<String>(
      seriesList,
      animate: animate,
      defaultRenderer: charts.ArcRendererConfig(
        arcWidth: 120,
        arcRendererDecorators: [charts.ArcLabelDecorator()],
      ),
      behaviors: [
        charts.DatumLegend(
          position: charts.BehaviorPosition.bottom,
          outsideJustification: charts.OutsideJustification.middleDrawArea,
          horizontalFirst: false,
          desiredMaxRows: 2,
          cellPadding: const EdgeInsets.only(left: 15.0, bottom: 4.0),
          entryTextStyle: charts.TextStyleSpec(
              color: charts.MaterialPalette.purple.shadeDefault, fontSize: 12),
        )
      ],
    );
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
        domainFn: (LinearSales sales, _) => sales.name,
        measureFn: (LinearSales sales, _) => sales.sales,
        colorFn: (LinearSales sales, _) => sales.color,
        data: data,
      )
    ];
  }
}

/// Sample linear data type.
class LinearSales {
  final String name;
  final int sales;
  final charts.Color color;

  LinearSales(this.name, this.sales, this.color);
}
