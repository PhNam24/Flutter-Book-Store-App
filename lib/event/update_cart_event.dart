import 'package:flutter_application_bookstore/base/base_event.dart';
import 'package:flutter_application_bookstore/model/product.dart';

class UpdateCartEvent extends BaseEvent {
  Product product;
  UpdateCartEvent(this.product);
}