import 'package:flutter_application_bookstore/base/base_event.dart';
import 'package:flutter_application_bookstore/model/product.dart';

class AddToCartEvent extends BaseEvent {
  Product product;

  AddToCartEvent(this.product);
}