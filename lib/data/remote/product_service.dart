import 'package:dio/dio.dart';
import 'package:flutter_application_bookstore/network/book_client.dart';

class ProductService {
  Future<Response> getProductList() {
    return BookClient.instance.dio.get(
      '/product/list',
    );
  }
}