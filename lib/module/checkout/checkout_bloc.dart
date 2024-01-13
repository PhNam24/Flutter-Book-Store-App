import 'package:flutter/material.dart';
import 'package:flutter_application_bookstore/base/base_event.dart';
import 'package:flutter_application_bookstore/data/repositories/order_repo.dart';
import 'package:flutter_application_bookstore/base/base_bloc.dart';
import 'package:flutter_application_bookstore/event/confirm_order_event.dart';
import 'package:flutter_application_bookstore/event/pop_event.dart';
import 'package:flutter_application_bookstore/event/update_cart_event.dart';
import 'package:flutter_application_bookstore/model/order.dart';
import 'package:rxdart/rxdart.dart';

class CheckoutBloc extends BaseBloc with ChangeNotifier {
  final OrderRepo _orderRepo;

  CheckoutBloc({
    required OrderRepo orderRepo,
  }) : _orderRepo = orderRepo;

  final _orderSubject = BehaviorSubject<Order>();

  Stream<Order> get orderStream => _orderSubject.stream;
  Sink<Order> get orderSink => _orderSubject.sink;

  @override
  void dispatchEvent(BaseEvent event) {
    switch (event.runtimeType) {
      case UpdateCartEvent:
        handleUpdateCart(event);
        break;
      case ConfirmOrderEvent:
        handleConfirmOrder(event);
        break;
    }
  }

  handleConfirmOrder(event) {
    _orderRepo.confirmOrder().then((isSuccess) {
      processEventSink.add(ShouldPopEvent());
    });
  }

  handleUpdateCart(event) {
    UpdateCartEvent e = event as UpdateCartEvent;

    // Observable.fromFuture(_orderRepo.updateOrder(e.product))
    //     .flatMap((_) => Observable.fromFuture(_orderRepo.getOrderDetail()))
    //     .listen((order) {
    //   orderSink.add(order);
    // });

    Future<void> updateAndFetchOrder() async {
      try {
        await _orderRepo.updateOrder(e.product);
        var order = await _orderRepo.getOrderDetail();
        orderSink.add(order);
      } catch (error) {
        // Xử lý lỗi nếu cần thiết
      }
    }
    // Future<void> updateAndFetchOrder2() async {
    //   try {
    //     await _orderRepo.updateOrder(e.product);
    //     var order = await _orderRepo.getShoppingCartInfo();
    //     orderSink.add(order);
    //   } catch (error) {
    //     // Xử lý lỗi nếu cần thiết
    //   }
    // }

    updateAndFetchOrder();
  }

  getOrderDetail() {
    Stream<Order>.fromFuture(
      _orderRepo.getOrderDetail(),
    ).listen((order) {
      orderSink.add(order);
    });
  }

  @override
  void dispose() {
    super.dispose();
    print('checkout close');
    _orderSubject.close();
  }
}
