import 'package:dispenser_mobile_app/API.dart';
import 'package:dispenser_mobile_app/food_item.dart';
import 'package:dispenser_mobile_app/template.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:collection/collection.dart';
import 'dart:convert';

class MyOrder extends StatefulWidget {
  const MyOrder({Key? key, required this.user, required this.token})
      : super(key: key);
  final Map<String, dynamic> user;
  final String token;

  @override
  State<MyOrder> createState() => _MyOrderState();
}

class _MyOrderState extends State<MyOrder> {
  String name = '';
  bool changed = false;
  var tempName = '';
  List<Map<String, dynamic>> initItem = [];
  List<Map<String, dynamic>> item = [];

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('This is a demo alert dialog.'),
                Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void getData() async {
    List<Map<String, dynamic>> deepCopy(List<dynamic> list) {
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    final arg = ModalRoute.of(context)!.settings.arguments as UUIDArgument;
    request(RequestType.getRequest,
            apiURL + '/order/view_order?uuid=${arg.uuid}', widget.token)
        .then((value) => setState(() {
              item = deepCopy(value.data['order_item_set']);
              initItem = deepCopy(value.data['order_item_set']);
              name = value.data['name'];
              tempName = value.data['name'];
            }))
        .catchError((e) => print(e));
  }

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

  void addItem(Map<String, dynamic> i) {
    var elem = item.firstWhere((e) => e['item']['uuid'] == i['item']['uuid'],
        orElse: (() => {}));
    if (elem.isEmpty) {
      setState(() {
        item.add(i);
        changed = true;
      });
    } else {
      setState(() {
        elem['quantity'] += i['quantity'];
        changed = true;
      });
    }
  }

  void submit() async {
    final arg = ModalRoute.of(context)!.settings.arguments as UUIDArgument;
    final curItem = [...item];
    final oldItem = [...initItem];

    bool deepCompare(Map a, Map b) {
      return const MapEquality().equals(a, b);
    }

    bool shallowCompare(Map a, Map b) {
      return a['item']['name'] == b['item']['name'];
    }

    List<Map> difference(List<Map> a, List<Map> b, Function f) {
      List<Map> rv = [...a];
      rv.removeWhere((e1) => b.any((e2) => f(e1, e2)));
      return rv;
    }

    final curDif = difference(curItem, oldItem, deepCompare);
    final del = difference(oldItem, curItem, shallowCompare);
    for (var e in del) {
      e['quantity'] = -1;
    }
    final res = curDif + del;
    String itemUuid = '', quantity = '';
    for (var e in res) {
      itemUuid += '${e['item']['uuid']},';
      quantity += '${e['quantity']},';
    }
    if (itemUuid.isNotEmpty) {
      itemUuid = itemUuid.substring(0, itemUuid.length - 1);
    }
    if (quantity.isNotEmpty) {
      quantity = quantity.substring(0, quantity.length - 1);
    }
    await request(
      RequestType.putRequest,
      apiURL + '/order/edit_order',
      widget.token,
      body: {
        'uuid': arg.uuid,
        'name': tempName,
        'item_uuid': itemUuid,
        'quantity': quantity,
      },
    ).then((value) {
      _showMyDialog();
    }).catchError((e) {
      print(e);
      getData();
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (item.isEmpty) {
      getData();
    }
    var totalCost = 0;
    var textFocusNode = FocusNode();
    List<Widget> children = [
      ...item.asMap().entries.map((e) {
        totalCost += e.value['item']['price'] * e.value['quantity'] as int;
        return FoodItem(
          key: Key(e.key.toString()),
          name: e.value['item']['name'],
          image: e.value['item']['image'],
          price: e.value['item']['price'],
          quantity: e.value['quantity'],
          editQuantity: (quantity) => editItem(e.key, quantity),
        );
      }).toList()
    ];
    children.add(AddMore(
      token: widget.token,
      addAction: (i) => addItem(i),
    ));

    return Template(
      user: widget.user,
      warning: changed,
      child: Container(
        margin: const EdgeInsets.fromLTRB(25, 0, 25, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                    focusNode: textFocusNode,
                    controller: TextEditingController(text: tempName),
                    onSubmitted: (value) {
                      if (value != name && !changed) {
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
                      onPressed: () {
                        if (changed) {
                          submit();
                          setState(() {
                            changed = false;
                          });
                        }
                      },
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
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Total cost:',
                      style: GoogleFonts.poppins(
                              textStyle: Theme.of(context).textTheme.subtitle1)
                          .copyWith(
                        fontSize: 15,
                      )),
                  const SizedBox(width: 10),
                  Text('$totalCost Credits',
                      style: GoogleFonts.poppins(
                              textStyle: Theme.of(context).textTheme.headline4)
                          .copyWith(
                        fontSize: 15,
                      )),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.all(5),
                          fixedSize: const Size(100, 50),
                          alignment: Alignment.center,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                        ),
                        child: Text('CHECKOUT',
                            style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ))),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      title: 'My order',
    );
  }
}
