import 'package:dispenser_mobile_app/new_order.dart';
import 'package:dispenser_mobile_app/order_item.dart';
import 'package:dispenser_mobile_app/template.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController editingController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
                style: const TextStyle(
                  fontSize: 17,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintStyle: TextStyle(
                    fontSize: 17,
                    color: Theme.of(context).hintColor,
                  ),
                  hintText: 'Find your food',
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NewOrder()),
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
                  children: const [
                    OrderItem(),
                    OrderItem(),
                    OrderItem(),
                    OrderItem(),
                    OrderItem(),
                    OrderItem(),
                    OrderItem(),
                    OrderItem(),
                    OrderItem(),
                    OrderItem(),
                    OrderItem(),
                  ],
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
