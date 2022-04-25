import 'dart:ffi';

import 'package:dispenser_mobile_app/API.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';

class FoodItem extends StatelessWidget {
  const FoodItem({
    Key? key,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
    required this.editQuantity,
  }) : super(key: key);
  final String name;
  final String image;
  final int price;
  final int quantity;
  final Function(int) editQuantity;

  void _delete(BuildContext context) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext ctx) {
          return CupertinoAlertDialog(
            title: Text("Remove $name?"),
            content: Text('Are you sure to remove $name?'),
            actions: [
              // The "Yes" button
              CupertinoDialogAction(
                onPressed: () {
                  editQuantity(-1);
                  Navigator.pop(context);
                },
                child: const Text('Yes'),
                isDefaultAction: true,
                isDestructiveAction: true,
              ),
              // The "No" button
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('No'),
                isDefaultAction: false,
                isDestructiveAction: false,
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: InkWell(
        onTap: () {},
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
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
            child: Slidable(
              key: const ValueKey(0),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    // An action can be bigger than the others.
                    flex: 2,
                    onPressed: (_) => _delete(context),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(
                        baseURL + image,
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
                            'Price: ${price.toString()} Credits',
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Theme.of(context).primaryColor,
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(2.5)),
                              child: const Center(
                                child: Icon(
                                  Icons.remove,
                                  size: 15,
                                ),
                              ),
                              onPressed: () => editQuantity(quantity - 1),
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            child: Center(
                              child: Text(
                                quantity.toString(),
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Theme.of(context).primaryColor,
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(2.5)),
                              child: const Center(
                                child: Icon(
                                  Icons.add,
                                  size: 15,
                                ),
                              ),
                              onPressed: () => editQuantity(quantity + 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AddMore extends StatelessWidget {
  const AddMore({Key? key, required this.token, required this.addAction})
      : super(key: key);
  final String token;
  final Function(Map<String, dynamic>) addAction;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        var food = await request(
                RequestType.getRequest, apiURL + '/product/all', token)
            .then((value) => value.data as List);
        List<Widget> children = food
            .map((e) => AddItem(
                  uuid: e['uuid'],
                  image: e['image'],
                  name: e['name'],
                  price: e['price'],
                  addAction: (i) => addAction(i),
                ))
            .toList();
        var length = food.length;
        showModalBottomSheet<void>(
          context: context,
          builder: (BuildContext context) {
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
                      'Choose a product',
                      style: GoogleFonts.poppins(
                          textStyle: GoogleFonts.poppins(
                              textStyle:
                                  Theme.of(context).textTheme.headline2)),
                    ),
                    const SizedBox(height: 15),
                    Expanded(
                      child: SingleChildScrollView(
                        child: LayoutGrid(
                          columnSizes: [1.fr, 1.fr, 1.fr],
                          rowSizes: List.filled((length / 3).ceil(), auto),
                          columnGap: 10,
                          rowGap: 10,
                          children: children,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Container(
        height: 70,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: const Color(0xffffc7b7),
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
                child: Container(
                    height: 50,
                    width: 50,
                    color: Colors.white,
                    child: Icon(Icons.add,
                        size: 40, color: Theme.of(context).primaryColor)),
              ),
              const SizedBox(width: 10),
              const Text(
                'Add more',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1.63813,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddItem extends StatelessWidget {
  const AddItem(
      {Key? key,
      required this.uuid,
      required this.image,
      required this.name,
      required this.price,
      required this.addAction})
      : super(key: key);
  final String uuid;
  final String image;
  final String name;
  final int price;
  final Function(Map<String, dynamic>) addAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(1, 1),
              blurRadius: 1.0,
              spreadRadius: 0.0,
            )
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: FractionallySizedBox(
                widthFactor: 1,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Image.network(
                    baseURL + image,
                    height: 70,
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  name,
                  style: GoogleFonts.poppins(
                      textStyle: Theme.of(context).textTheme.headline4),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${price.toString()}  Credits',
                  style: GoogleFonts.poppins(
                      textStyle: Theme.of(context).textTheme.subtitle2),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: TextButton(
                      child: Text(
                        'Add',
                        style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        )),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 25),
                        alignment: Alignment.center,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                      ),
                      onPressed: () {
                        addAction({
                          'item': {
                            'uuid': uuid,
                            'image': image,
                            'name': name,
                            'price': price,
                          },
                          'quantity': 1,
                        });
                        Navigator.pop(context);
                      }),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
