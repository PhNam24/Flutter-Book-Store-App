import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_application_bookstore/base/base_bloc.dart';
import 'package:flutter_application_bookstore/shared/app_color.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingTask extends StatelessWidget {
  final Widget child;
  final BaseBloc bloc;

  LoadingTask({required this.child, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<bool>.value(
      initialData: false,
      value: bloc.loadingStream,
      child: Stack(
        children: <Widget>[
          child,
          Consumer<bool>(
            builder: (context, isLoading, child) => Center(
              child: isLoading
                  ? Container(
                      //padding: EdgeInsets.all(30),
                      color: Colors.grey.withOpacity(0.5),
                      child: LoadingAnimationWidget.hexagonDots(
                          color: AppColor.blue, size: 50),
                    )
                  : Container(),
            ),
          ),
        ],
      ),
    );
  }
}
