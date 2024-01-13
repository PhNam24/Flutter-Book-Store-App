import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_application_bookstore/base/base_bloc.dart';
import 'package:flutter_application_bookstore/base/base_event.dart';
import 'package:flutter_application_bookstore/data/repositories/order_repo.dart';
import 'package:flutter_application_bookstore/data/repositories/product_repo.dart';
import 'package:flutter_application_bookstore/event/add_to_cart_event.dart';
import 'package:flutter_application_bookstore/model/product.dart';
import 'package:flutter_application_bookstore/model/shopping_cart.dart';
import 'package:rxdart/rxdart.dart';

class HomeBloc extends BaseBloc with ChangeNotifier {
  final ProductRepo _productRepo;
  final OrderRepo _orderRepo;

  var _shoppingCart = ShoppingCart(orderId: '', total: 0);

  static HomeBloc? _instance;

  static HomeBloc? getInstance({
    required ProductRepo productRepo,
    required OrderRepo orderRepo,
  }) {
    if (_instance == null) {
      _instance = HomeBloc._internal(
        productRepo: productRepo,
        orderRepo: orderRepo,
      );
    }
    return _instance;
  }

  HomeBloc._internal({
    required ProductRepo productRepo,
    required OrderRepo orderRepo,
  })  : _productRepo = productRepo,
        _orderRepo = orderRepo;

  final _shoppingCardSubject = BehaviorSubject<ShoppingCart>();

  Stream<ShoppingCart> get shoppingCartStream => _shoppingCardSubject.stream;
  Sink<ShoppingCart> get shoppingCartSink => _shoppingCardSubject.sink;

  @override
  void dispatchEvent(BaseEvent event) {
    switch (event.runtimeType) {
      case AddToCartEvent:
        handleAddToCart(event);
        break;
    }
  }

  handleAddToCart(event) {
    AddToCartEvent addToCartEvent = event as AddToCartEvent;
    _orderRepo.addToCart(addToCartEvent.product).then((shoppingCart) {
      _shoppingCart.orderId = shoppingCart.orderId;
      shoppingCartSink.add(shoppingCart);
    });
  }

  getShoppingCartInfo() {
    Stream<ShoppingCart>.fromFuture(_orderRepo.getShoppingCartInfo()).listen(
        (shoppingCart) {
      _shoppingCart = shoppingCart;
      shoppingCartSink.add(shoppingCart);
    }, onError: (err) {
      _shoppingCardSubject.addError(err);
    });
  }

  Stream<List<Product>> getProductList() {
    return Stream<List<Product>>.fromFuture(
      _productRepo.getProductList(),
    );
  }

  @override
  void dispose() {
    _shoppingCardSubject.close();
  }
}
