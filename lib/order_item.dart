import 'package:dispenser_mobile_app/my_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class OrderItem extends StatelessWidget {
  const OrderItem(
      {Key? key,
      required this.uuid,
      required this.name,
      required this.desc,
      required this.delete})
      : super(key: key);
  final String name;
  final String uuid;
  final String desc;
  final VoidCallback delete;

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
                  delete();
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
        onTap: () {
          Navigator.pushNamed(
            context,
            '/order',
            arguments: {'uuid': uuid},
          );
        },
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
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                        icon: const Icon(Icons.remove_red_eye_sharp),
                        onPressed: () {
                          Navigator.pushNamed(context, '/order',
                              arguments: {'uuid': uuid});
                        }),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () => _delete(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
