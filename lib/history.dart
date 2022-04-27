import 'package:charts_flutter/flutter.dart' as charts;
import 'package:dispenser_mobile_app/API.dart';
import 'package:dispenser_mobile_app/line_chart.dart';
import 'package:dispenser_mobile_app/pie_chart.dart';
import 'package:dispenser_mobile_app/template.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

enum ChartType { line, pie }
enum DataType { quantity, price }
enum WhichDate { from, to }

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
  List<Map<String, dynamic>> item = [];
  DateTime fromDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime toDate = DateTime.now();
  bool sent = false;

  List<Map<String, dynamic>> deepCopy(List<dynamic> list) {
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  void _onRefresh() {
    getData();
  }

  charts.Color _adjustColor(Color color, double amount) {
    assert(amount >= -1 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return charts.ColorUtil.fromDartColor(hslLight.toColor());
  }

  Color _getContrastColor(Color color) {
    return Color.fromARGB(
        255, 255 - color.blue, 255 - color.red, 255 - color.green);
  }

  List<charts.Series<LinearSales, String>> getTop4() {
    List<charts.Color> colors = [];
    const base = -0.15;
    for (var i = 0; i < 5; i++) {
      final primary = Theme.of(context).primaryColor;
      final contrast = _getContrastColor(primary);
      colors.add(i % 2 == 0
          ? _adjustColor(primary, base * (i) / 2)
          : _adjustColor(contrast, base * (i - 1) / 2));
    }

    final Map<String, dynamic> temp = {};
    item.forEach((e) {
      if (temp.containsKey(e['name'])) {
        temp[e['name']] += e['quantity'];
      } else {
        temp.putIfAbsent(e['name'], () => e['quantity']);
      }
    });
    var newItem =
        temp.entries.map((e) => {'name': e.key, 'quantity': e.value}).toList();
    newItem.sort((a, b) => b['quantity'].compareTo(a['quantity']));
    var top = newItem.take(4).toList();
    var other = newItem.skip(4).toList();
    var otherTotal = other.fold(0, (num a, b) => a + b['quantity']);
    final data = top
            .asMap()
            .entries
            .map((e) => LinearSales(
                e.value['name'], e.value['quantity'], colors[e.key]))
            .toList() +
        (otherTotal > 0
            ? [LinearSales('Other', otherTotal as int, colors[4])]
            : []);

    return [
      charts.Series<LinearSales, String>(
        id: 'Product Percentage',
        domainFn: (LinearSales sales, _) => sales.name,
        measureFn: (LinearSales sales, _) => sales.sales,
        colorFn: (LinearSales sales, _) => sales.color,
        data: data,
        labelAccessorFn: (LinearSales row, _) => '${row.sales}',
      )
    ];
  }

  DateTime alignDateTime(DateTime dt, Duration alignment,
      [bool roundUp = false]) {
    assert(alignment >= Duration.zero);
    if (alignment == Duration.zero) return dt;
    final correction = Duration(
        days: 0,
        hours: alignment.inDays > 0
            ? dt.hour
            : alignment.inHours > 0
                ? dt.hour % alignment.inHours
                : 0,
        minutes: alignment.inHours > 0
            ? dt.minute
            : alignment.inMinutes > 0
                ? dt.minute % alignment.inMinutes
                : 0,
        seconds: alignment.inMinutes > 0
            ? dt.second
            : alignment.inSeconds > 0
                ? dt.second % alignment.inSeconds
                : 0,
        milliseconds: alignment.inSeconds > 0
            ? dt.millisecond
            : alignment.inMilliseconds > 0
                ? dt.millisecond % alignment.inMilliseconds
                : 0,
        microseconds: alignment.inMilliseconds > 0 ? dt.microsecond : 0);
    if (correction == Duration.zero) return dt;
    final corrected = dt.subtract(correction);
    final result = roundUp ? corrected.add(alignment) : corrected;
    return result;
  }

  List<charts.Series<TimeSeriesSales, DateTime>> getChartData(DataType type) {
    final Map<String, dynamic> temp = {};
    final field = type == DataType.quantity ? 'quantity' : 'price';
    item.forEach((e) {
      if (temp.containsKey(e['time'])) {
        temp[e['time']] += e[field];
      } else {
        temp.putIfAbsent(e['time'], () => e[field]);
      }
    });
    var newItem =
        temp.entries.map((e) => {'time': e.key, field: e.value}).toList();
    newItem.sort((a, b) => a['time'].compareTo(b['time']));
    var data = newItem
        .map((e) => TimeSeriesSales(
            alignDateTime(
              DateTime.fromMillisecondsSinceEpoch(int.parse(e['time']) * 1000),
              const Duration(days: 1),
            ),
            e[field]))
        .toList();
    return [
      charts.Series<TimeSeriesSales, DateTime>(
        id: 'Product Quantity',
        colorFn: (_, __) =>
            charts.ColorUtil.fromDartColor(Theme.of(context).primaryColor),
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.data,
        data: data,
      )
    ];
  }

  void getData() async {
    var data = [];
    String param = '';
    if (dateChanged()) {
      param =
          '?fromtime=${fromDate.millisecondsSinceEpoch ~/ 1000}&totime=${toDate.millisecondsSinceEpoch ~/ 1000}';
    }
    await request(RequestType.getRequest, apiURL + '/history/my' + param,
            widget.token)
        .then((value) => data = value.data)
        .catchError((e) => showMyDialog(
            context, 'Error', 'Error detail: ${e.toString()}', getData));
    var temp = deepCopy(data);
    temp.forEach((e) {
      e['name'] = e['item']['name'];
      e['price'] = e['item']['price'];
    });
    setState(() {
      item = temp;
      sent = true;
    });
  }

  Widget getChart(
      ChartType type,
      List<charts.Series<dynamic, dynamic>> seriesList,
      String title,
      String subtitle) {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 0, 25, 40),
      height: 300,
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

  bool dateChanged() {
    return fromDate.compareTo(DateTime.now()) != 0 ||
        toDate.compareTo(DateTime.now().subtract(const Duration(days: 7))) != 0;
  }

  String dateToString(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Future _selectDate(BuildContext context, WhichDate whichDate) async {
    bool isFrom = whichDate == WhichDate.from;
    var selectedDate = isFrom ? fromDate : toDate;
    final DateTime? picked = await showDatePicker(
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
      context: context,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary:
                  Theme.of(context).primaryColor, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: Colors.red, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  void submit() {
    if (fromDate.compareTo(toDate) >= 0) {
      showMyDialog(context, 'Error', 'From date must be before to date', () {});
    } else {
      getData();
    }
  }

  Widget historyTemplate(BuildContext context, List<Widget> children) =>
      Template(
        title: 'History',
        isDrawer: true,
        user: widget.user,
        child: SmartRefresher(
          controller: _refreshController,
          onRefresh: _onRefresh,
          enablePullDown: true,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 20),
                    TextButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'From: ${dateToString(fromDate)}',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Icon(
                            Icons.date_range_outlined,
                            color: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                      onPressed: () => {_selectDate(context, WhichDate.from)},
                    ),
                    TextButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'To: ${dateToString(toDate)}',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Icon(
                            Icons.date_range_outlined,
                            color: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                      onPressed: () => {_selectDate(context, WhichDate.to)},
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.all(5),
                        fixedSize: const Size(20, 30),
                        alignment: Alignment.center,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                      ),
                      child: Text(
                        'Done',
                        style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        )),
                      ),
                      onPressed: () {
                        getData();
                      },
                    ),
                  ),
                ),
                ...children,
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (item.isEmpty && !sent) {
      getData();
    } else {
      if (item.isNotEmpty) {
        _refreshController.refreshCompleted();
        return historyTemplate(context, [
          getChart(
            ChartType.pie,
            getTop4(),
            'Product Percentage',
            'Top 4 product bought and others',
          ),
          getChart(
            ChartType.line,
            getChartData(DataType.quantity),
            'Product Quantity',
            'Products bought over time',
          ),
          getChart(
            ChartType.line,
            getChartData(DataType.price),
            'Price',
            'Credits spent over time',
          ),
        ]);
      } else {
        return historyTemplate(context, [
          Center(
            child: Text(
              'Data unavailable',
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontSize: 13,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ]);
      }
    }
    return historyTemplate(context, [
      Center(
        child: Text(
          'Loading...',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 13,
              color: Colors.black,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    ]);
  }
}
