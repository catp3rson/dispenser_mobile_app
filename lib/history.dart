import 'package:charts_flutter/flutter.dart' as charts;
import 'package:dispenser_mobile_app/line_chart.dart';
import 'package:dispenser_mobile_app/pie_chart.dart';
import 'package:dispenser_mobile_app/template.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

enum ChartType { line, pie }

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

List<charts.Series<TimeSeriesSales, DateTime>> createSampleLineData(
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

List<charts.Series<LinearSales, String>> createSamplePieData(
    BuildContext context) {
  charts.Color _adjustColor(Color color, [double amount = .1]) {
    assert(amount >= -1 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return charts.ColorUtil.fromDartColor(hslLight.toColor());
  }

  final color = Theme.of(context).primaryColor;
  const base = 0.12;
  final data = [
    LinearSales('Pepsia', 5, _adjustColor(color, -base * 4)),
    LinearSales('Fantaa', 25, _adjustColor(color, -base * 3)),
    LinearSales('Spritea', 75, _adjustColor(color, -base * 2)),
    LinearSales('Cokea', 100, _adjustColor(color, -base)),
    LinearSales('Coke', 100, _adjustColor(color, 0)),
    LinearSales('Sprite', 75, _adjustColor(color, base)),
    LinearSales('Fanta', 25, _adjustColor(color, base * 2)),
    LinearSales('Pepsi', 5, _adjustColor(color, base * 3)),
  ];

  return [
    charts.Series<LinearSales, String>(
      id: 'Sales',
      domainFn: (LinearSales sales, _) => sales.year,
      measureFn: (LinearSales sales, _) => sales.sales,
      colorFn: (LinearSales sales, _) => sales.color,
      data: data,
      // Set a label accessor to control the text of the arc label.
      labelAccessorFn: (LinearSales row, _) => '${row.year}: ${row.sales}',
    )
  ];
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key, required this.token, required this.user})
      : super(key: key);
  final String token;
  final Map<String, dynamic> user;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() {
    getData();
    _refreshController.refreshCompleted();
  }

  void getData() {}

  Widget getChart(
      ChartType type,
      List<charts.Series<dynamic, dynamic>> seriesList,
      String title,
      String subtitle) {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 20, 25, 0),
      height: 250,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 5.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: type == ChartType.line
                ? TimeSeriesRangeAnnotationChart(
                    seriesList: seriesList
                        as List<charts.Series<TimeSeriesSales, DateTime>>,
                    animate: true,
                  )
                : SimplePieChart(
                    seriesList:
                        seriesList as List<charts.Series<LinearSales, String>>,
                    animate: true,
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Template(
      title: 'History',
      user: widget.user,
      isDrawer: true,
      child: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        enablePullDown: true,
        child: SingleChildScrollView(
          child: Column(
            children: [
              getChart(
                ChartType.pie,
                createSamplePieData(context),
                'Product Percentage',
                'Percentage product bought',
              ),
              getChart(
                ChartType.line,
                createSampleLineData(context),
                'Product Quantity',
                'Product bought over time',
              ),
              getChart(
                ChartType.line,
                createSampleLineData(context),
                'Price',
                'Credits spent over time',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
