import 'package:dispenser_mobile_app/food_item.dart';
import 'package:dispenser_mobile_app/template.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyOrder extends StatefulWidget {
  const MyOrder({Key? key, required this.name}) : super(key: key);
  final String name;

  @override
  State<MyOrder> createState() => _MyOrderState();
}

class _MyOrderState extends State<MyOrder> {
  bool changed = false;
  var tempName = '';
  List<Map<String, dynamic>> item = List.generate(
      15,
      (i) => {
            'name': 'Coke ' + i.toString(),
            'desc': 'Drinks',
            'quantity': i + 1,
          });

  void editItem(int index, int quantity) {
    if (quantity > 0) {
      setState(() {
        item[index]['quantity'] = quantity;
        changed = true;
      });
    } else if (quantity == -1) {
      setState(() {
        item.removeAt(index);
        changed = true;
      });
    }
  }

  void addItem(String name, String desc, int quantity) {
    setState(() {
      item.add({
        'name': name,
        'desc': desc,
        'quantity': quantity,
      });
      changed = true;
    });
  }

  @override
  void initState() {
    super.initState();
    tempName = widget.name;
  }

  @override
  Widget build(BuildContext context) {
    var textFocusNode = FocusNode();
    List<Widget> children = [
      ...item
          .asMap()
          .entries
          .map((e) => FoodItem(
                key: Key(e.key.toString()),
                name: e.value['name'],
                desc: e.value['desc'],
                quantity: e.value['quantity'],
                editQuantity: (quantity) => editItem(e.key, quantity),
              ))
          .toList()
    ];
    children.add(AddMore(
      addAction: (p0, p1, p2) => addItem(p0, p1, p2),
    ));

    return Template(
      warning: changed,
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
            Row(
              children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                    focusNode: textFocusNode,
                    controller: TextEditingController(text: tempName),
                    onSubmitted: (value) {
                      if (value != widget.name && !changed) {
                        setState(() {
                          changed = true;
                          tempName = value;
                        });
                      }
                    },
                    style: GoogleFonts.poppins(
                        textStyle: Theme.of(context).textTheme.headline2),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.black),
                        onPressed: () => textFocusNode.requestFocus(),
                      ),
                    ),
                    enabled: true,
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      child: Text(
                        'DONE',
                        style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        )),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: changed
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                        padding: const EdgeInsets.all(5),
                        minimumSize: const Size(50, 25),
                        alignment: Alignment.center,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                      ),
                      onPressed: changed
                          ? () {
                              setState(() {
                                changed = false;
                              });
                            }
                          : () {},
                    ),
                  ),
                ),
              ],
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
      title: widget.name,
    );
  }
}
