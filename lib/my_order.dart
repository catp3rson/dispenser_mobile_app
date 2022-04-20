import 'package:dispenser_mobile_app/food_item.dart';
import 'package:dispenser_mobile_app/template.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyOrder extends StatefulWidget {
  const MyOrder({Key? key}) : super(key: key);

  @override
  State<MyOrder> createState() => _MyOrderState();
}

class _MyOrderState extends State<MyOrder> {
  @override
  Widget build(BuildContext context) {
    List<Widget> children = List.filled(
        15,
        const FoodItem(
          name: 'Coke',
          desc: 'Drinks',
        ),
        growable: true);
    children.add(const AddMore());

    return Template(
      child: Container(
        margin: const EdgeInsets.fromLTRB(25, 0, 25, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Image.asset('images/qr.png', fit: BoxFit.contain),
            ),
            const SizedBox(height: 10),
            Text(
              'My order 1',
              style: GoogleFonts.poppins(
                  textStyle: Theme.of(context).textTheme.headline2),
            ),
            const SizedBox(height: 10),
            Expanded(
                child: SingleChildScrollView(
                    child: Column(
              children: children,
            ))),
          ],
        ),
      ),
      title: 'My Order',
    );
  }
}
