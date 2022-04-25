import 'package:dispenser_mobile_app/template.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  List<Widget> item(BuildContext context, String label, String value) {
    return [
      ListTile(
        title: Text(
          label,
          style: GoogleFonts.poppins(
              textStyle: Theme.of(context).textTheme.subtitle1),
        ),
        subtitle: Text(
          value,
          style: GoogleFonts.poppins(
              textStyle: Theme.of(context).textTheme.headline3),
        ),
      ),
      const Divider(
        thickness: 1,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Template(
      title: 'Profile',
      profile: false,
      isDrawer: true,
      child: Column(
        children: [
          Container(
            height: 120,
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).primaryColor,
            child: Transform.translate(
              offset: const Offset(15, 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Image(
                      width: 100,
                      height: 100,
                      fit: BoxFit.fitHeight,
                      image: AssetImage(
                        'images/avt.png',
                      )),
                  const SizedBox(width: 20),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome User!',
                          style: GoogleFonts.poppins(
                                  textStyle:
                                      Theme.of(context).textTheme.headline2)
                              .copyWith(color: Colors.white),
                        ),
                        Text(
                          'Staff ID: 5128654',
                          style: GoogleFonts.poppins(
                                  textStyle:
                                      Theme.of(context).textTheme.subtitle1)
                              .copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(35.0, 20.0, 35.0, 0.0),
            child: Column(
              children: [
                ...item(context, 'Name', 'John Doe'),
                ...item(context, 'Email', 'johndoe@email.com'),
                ...item(context, 'Phone', '08911298765'),
                ...item(context, 'Password', '••••••••••••'),
              ],
            ),
          )
        ],
      ),
    );
  }
}
