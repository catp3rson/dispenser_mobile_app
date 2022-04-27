import 'package:dispenser_mobile_app/API.dart';
import 'package:dispenser_mobile_app/food_item.dart';
import 'package:dispenser_mobile_app/template.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:collection/collection.dart';

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
        .catchError((e) => showMyDialog(
            context, 'Error', 'Error detail: ${e.toString()}', () {}));
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
      showMyDialog(
          context, 'Success', 'Order has successfully been edited', () {});
    }).catchError((e) {
      showMyDialog(context, 'Error', 'Error detail: ${e.toString()}', getData);
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
                        onPressed: () {
                          final arg = ModalRoute.of(context)!.settings.arguments
                              as UUIDArgument;
                          showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return MachineMenu(
                                token: widget.token,
                                orderUUID: arg.uuid,
                              );
                            },
                          );
                        },
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

class MachineMenu extends StatefulWidget {
  const MachineMenu({Key? key, required this.token, required this.orderUUID})
      : super(key: key);
  final String token;
  final String orderUUID;

  @override
  State<MachineMenu> createState() => _MachineMenuState();
}

class _MachineMenuState extends State<MachineMenu> {
  List<Map<String, dynamic>> machines = [];

  void getData() async {
    request(RequestType.getRequest, apiURL + '/machine/all', widget.token)
        .then((value) => setState(() => machines = [...value.data]));
  }

  void selectMachine(String uuid) {
    request(RequestType.putRequest, apiURL + '/order/checkout', widget.token,
            body: {
          'order_uuid': widget.orderUUID,
          'machine_uuid': uuid,
        })
        .then((value) => showMyDialog(
              context,
              'Success',
              'Order has successfully been checked out',
              () => Navigator.pop(context),
            ))
        .catchError((e) {
      if (e.response.statusCode == 400) {
        showMyDialog(
          context,
          'Error',
          'Insufficient credits',
          () => Navigator.pop(context),
        );
      } else {
        showMyDialog(
          context,
          'Error',
          'Something went wrong',
          () => Navigator.pop(context),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (machines.isEmpty) {
      getData();
    }
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      color: Theme.of(context).backgroundColor,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Choose a machine',
              style: GoogleFonts.poppins(
                  textStyle: GoogleFonts.poppins(
                      textStyle: Theme.of(context).textTheme.headline2)),
            ),
            const SizedBox(height: 10),
            Expanded(
                child: SingleChildScrollView(
              child: Column(
                children: machines.map((machine) {
                  return MachineItem(
                    name: machine['name'],
                    select: () => selectMachine(machine['uuid']),
                  );
                }).toList(),
              ),
            ))
          ],
        ),
      ),
    );
  }
}

class MachineItem extends StatelessWidget {
  const MachineItem({Key? key, required this.name, required this.select})
      : super(key: key);
  final String name;
  final VoidCallback select;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        height: 70,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(2, 2),
              blurRadius: 1.0,
              spreadRadius: 0.0,
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(
                  'images/machine.png',
                  height: 50,
                  width: 50,
                  fit: BoxFit.fill,
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    Text(
                      'Dispenser machine',
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.all(5),
                      fixedSize: const Size(80, 30),
                      alignment: Alignment.center,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                    ),
                    child: Text('Select',
                        style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ))),
                    onPressed: () {
                      select();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
