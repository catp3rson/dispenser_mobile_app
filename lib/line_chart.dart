import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class TimeSeriesRangeAnnotationChart extends StatelessWidget {
  final List<charts.Series<dynamic, DateTime>> seriesList;
  final bool animate;

  const TimeSeriesRangeAnnotationChart(
      {Key? key, required this.seriesList, required this.animate})
      : super(key: key);

  /// Creates a [TimeSeriesChart] with sample data and no transition.
  factory TimeSeriesRangeAnnotationChart.withSampleData(BuildContext context) {
    return TimeSeriesRangeAnnotationChart(
      seriesList: _createSampleData(context),
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      behaviors: [
        charts.RangeAnnotation([
          charts.RangeAnnotationSegment(DateTime(2017, 10, 4),
              DateTime(2017, 10, 15), charts.RangeAnnotationAxisType.domain),
        ]),
      ],
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<TimeSeriesSales, DateTime>> _createSampleData(
      BuildContext context) {
    final data = [
      TimeSeriesSales(DateTime(2017, 9, 19), 5),
      TimeSeriesSales(DateTime(2017, 9, 26), 25),
      TimeSeriesSales(DateTime(2017, 10, 3), 100),
      TimeSeriesSales(DateTime(2017, 10, 10), 75),
    ];

    return [
      charts.Series<TimeSeriesSales, DateTime>(
        id: 'Data',
        colorFn: (_, __) =>
            charts.ColorUtil.fromDartColor(Theme.of(context).primaryColor),
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.data,
        data: data,
      )
    ];
  }
}

/// Sample time series data type.
class TimeSeriesSales {
  final DateTime time;
  final int data;

  TimeSeriesSales(this.time, this.data);
}
