import 'package:dispenser_mobile_app/food_item.dart';
import 'package:dispenser_mobile_app/template.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewOrder extends StatefulWidget {
  const NewOrder({Key? key}) : super(key: key);

  @override
  State<NewOrder> createState() => _NewOrderState();
}

class _NewOrderState extends State<NewOrder> {
  @override
  Widget build(BuildContext context) {
    var textFocusNode = FocusNode();
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
            Row(
              children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                    focusNode: textFocusNode,
                    controller: TextEditingController(text: "Enter a name"),
                    style: GoogleFonts.poppins(
                        textStyle: Theme.of(context).textTheme.headline2),
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => textFocusNode.requestFocus(),
                        )),
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
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.all(5),
                          minimumSize: const Size(50, 25),
                          alignment: Alignment.center,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
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
      title: 'My Order',
    );
  }
}
