import 'package:flutter/material.dart';
import 'package:flutter_application_bookstore/shared/app_color.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class PageContainer extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget> actions;

  final List<SingleChildWidget> bloc;
  final List<SingleChildWidget> di;

  PageContainer(
      {required this.title,
      required this.bloc,
      required this.di,
      required this.child,
      required this.actions});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ...di,
        ...bloc,
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColor.blue,
            ),
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
          backgroundColor: AppColor.yellow,
          actions: actions,
        ),
        body: child,
      ),
    );
  }
}

class NavigatorProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[],
      ),
    );
  }
}
