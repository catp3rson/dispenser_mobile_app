import 'package:dispenser_mobile_app/fake_api.dart';
import 'package:dispenser_mobile_app/order_item.dart';
import 'package:dispenser_mobile_app/template.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> initOrder = [];
  List<Map<String, dynamic>> order = [];

  void getData() async {
    var temp = await getOrder();
    setState(() {
      initOrder = temp;
      order = temp;
    });
  }

  void deleteOrder(int index) {
    setState(() {
      order.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Template(
      child: Container(
        margin: const EdgeInsets.fromLTRB(25, 30, 25, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Welcome User!',
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
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: order
                      .asMap()
                      .entries
                      .map((e) => OrderItem(
                            uuid: e.value['uuid'],
                            name: e.value['name'],
                            desc: e.value['desc'],
                            delete: () => deleteOrder(e.key),
                          ))
                      .toList(),
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
