import 'package:dispenser_mobile_app/food_item.dart';
import 'package:dispenser_mobile_app/template.dart';
import 'package:flutter/material.dart';

class MyOrder extends StatefulWidget {
  MyOrder({Key? key}) : super(key: key);

  @override
  State<MyOrder> createState() => _MyOrderState();
}

class _MyOrderState extends State<MyOrder> {
  @override
  Widget build(BuildContext context) {
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
              style: Theme.of(context).textTheme.headline2,
            ),
            const SizedBox(height: 10),
            Expanded(
                child: SingleChildScrollView(
                    child: Column(
              children: const [
                FoodItem(),
                FoodItem(),
                FoodItem(),
                FoodItem(),
                FoodItem(),
                FoodItem(),
                AddMore()
              ],
            ))),
          ],
        ),
      ),
      title: 'My Order',
    );
  }
}
