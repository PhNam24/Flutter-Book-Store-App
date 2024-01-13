import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_bookstore/base/base_event.dart';
import 'package:rxdart/rxdart.dart';

abstract class BaseBloc {
  final StreamController<BaseEvent> _eventController =
      StreamController<BaseEvent>();
  Sink<BaseEvent> get event => _eventController.sink;

  final StreamController<bool> _loadingStreamController =
      StreamController<bool>();

  Stream<bool> get loadingStream => _loadingStreamController.stream;
  Sink<bool> get loadingSink => _loadingStreamController.sink;

  final StreamController<BaseEvent> _processEventSubject =
      BehaviorSubject<BaseEvent>();

  Stream<BaseEvent> get processEventStream => _processEventSubject.stream;
  Sink<BaseEvent> get processEventSink => _processEventSubject.sink;

  BaseBloc() {
    _eventController.stream.listen((event) {
      if (event is! BaseEvent) {
        throw Exception("Invalid Event");
      }

      dispatchEvent(event);
    });
  }

  void dispatchEvent(BaseEvent event) {}

  @mustCallSuper
  void dispose() {
    _eventController.close();
    _loadingStreamController.close();
    _processEventSubject.close();
  }
}
