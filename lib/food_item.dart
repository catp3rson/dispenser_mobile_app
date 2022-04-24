import 'package:dispenser_mobile_app/fake_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';

class FoodItem extends StatelessWidget {
  const FoodItem({
    Key? key,
    required this.name,
    required this.desc,
    required this.quantity,
    required this.editQuantity,
  }) : super(key: key);
  final String name;
  final String desc;
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
            child: Container(
              height: 70,
              color: Theme.of(context).canvasColor,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.asset(
                        'images/coke.png',
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
                            desc,
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
  const AddMore({Key? key, required this.addAction}) : super(key: key);
  final Function(String, String, String, int) addAction;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        var food = await getFoodShop();
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
                          children: food
                              .asMap()
                              .entries
                              .map((e) => AddItem(
                                    uuid: e.value['uuid'],
                                    name: e.value['name'],
                                    desc: e.value['desc'],
                                    addAction: (p0, p1, p2, p3) =>
                                        addAction(p0, p1, p2, p3),
                                  ))
                              .toList(),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          height: 70,
          color: const Color(0xffffc7b7),
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
      ),
    );
  }
}

class AddItem extends StatelessWidget {
  const AddItem(
      {Key? key,
      required this.uuid,
      required this.name,
      required this.desc,
      required this.addAction})
      : super(key: key);
  final String uuid;
  final String name;
  final String desc;
  final Function(String, String, String, int) addAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      height: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          color: Theme.of(context).canvasColor,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: FractionallySizedBox(
                  widthFactor: 1,
                  child: Image.asset(
                    'images/coke.png',
                    fit: BoxFit.fill,
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
                    desc,
                    style: GoogleFonts.poppins(
                        textStyle: Theme.of(context).textTheme.subtitle2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
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
                        addAction(uuid, name, desc, 1);
                        Navigator.pop(context);
                      }),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
