import 'package:dio/dio.dart';
import 'package:dispenser_mobile_app/API.dart';
import 'package:dispenser_mobile_app/order_item.dart';
import 'package:dispenser_mobile_app/template.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Home extends StatefulWidget {
  const Home({Key? key, required this.token, required this.user})
      : super(key: key);
  final String token;
  final Map<String, dynamic> user;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> initOrder = [];
  List<Map<String, dynamic>> order = [];
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void getData() async {
    print('Get Data');
    var response = await request(
            RequestType.getRequest, apiURL + '/order/my_orders', widget.token)
        .then((value) {
      if (value.statusCode == 200) {
        return value.data;
      } else {
        return [];
      }
    }).catchError((error) => []);
    setState(() {
      initOrder = [...response];
      order = [...response];
    });
  }

  void _onRefresh() {
    getData();
    _refreshController.refreshCompleted();
  }

  void deleteOrder(int index) async {
    await request(
        RequestType.deleteRequest, apiURL + '/order/delete_order', widget.token,
        body: {'uuid': order[index]['uuid']}).then((value) {
      if (value.statusCode == 200) {
        getData();
      }
    }).catchError((error) {});
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Template(
      user: widget.user,
      child: Container(
        margin: const EdgeInsets.fromLTRB(25, 30, 25, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Welcome ${widget.user['first_name']} ${widget.user['last_name']}!',
              style: GoogleFonts.poppins(
                  textStyle: Theme.of(context).textTheme.headline2),
            ),
            const SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                onChanged: (value) {
                  order = [...initOrder];
                  setState(() {
                    if (value.isNotEmpty) {
                      order.retainWhere((element) => element['name']
                          .toLowerCase()
                          .contains(value.toLowerCase()));
                    }
                  });
                },
                style: const TextStyle(
                  fontSize: 17,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintStyle: TextStyle(
                    fontSize: 17,
                    color: Theme.of(context).hintColor,
                  ),
                  hintText: 'Find your order',
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).hintColor,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(15),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Text(
                  'Your order',
                  style: GoogleFonts.poppins(
                      textStyle: Theme.of(context).textTheme.headline3),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/new_order',
                        );
                      },
                      child: Text(
                        'Add new order',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: SmartRefresher(
                controller: _refreshController,
                onRefresh: _onRefresh,
                enablePullUp: false,
                enablePullDown: true,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: order
                        .asMap()
                        .entries
                        .map((e) => OrderItem(
                              uuid: e.value['uuid'],
                              image: e.value['image'],
                              name: e.value['name'],
                              desc: 'Total: ${e.value['total_price']} credits',
                              delete: () => deleteOrder(e.key),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      title: 'Home',
      isDrawer: true,
    );
  }
}
