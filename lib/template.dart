import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:dispenser_mobile_app/sidebar.dart';

class Template extends StatefulWidget {
  const Template(
      {Key? key,
      required this.child,
      required this.title,
      this.isDrawer = false})
      : super(key: key);
  final Widget child;
  final String title;
  final bool isDrawer;

  @override
  State<Template> createState() => _TemplateState();
}

class _TemplateState extends State<Template> {
  TextEditingController editingController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Center(
          child: Text(
            widget.title,
            style: Theme.of(context).textTheme.headline1,
          ),
        ),
        leading: widget.isDrawer
            ? Builder(
                builder: (context) => IconButton(
                  icon: const Icon(
                    Icons.menu_rounded,
                    color: Colors.black,
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              )
            : Builder(
                builder: (context) => IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
        actions: <Widget>[
          IconButton(
            icon: Image.asset('images/avt.png'),
            onPressed: () {
              // TODO: open profile page
            },
          )
        ],
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0,
      ),
      drawer: const SideBar(),
      body: Container(
          margin: const EdgeInsets.only(bottom: 15.0), child: widget.child),
    );
  }
}
