import 'package:flutter/material.dart';
import 'package:flutter_application_bookstore/base/base_widget.dart';
import 'package:flutter_application_bookstore/data/remote/order_service.dart';
import 'package:flutter_application_bookstore/data/remote/product_service.dart';
import 'package:flutter_application_bookstore/data/repositories/order_repo.dart';
import 'package:flutter_application_bookstore/data/repositories/product_repo.dart';
import 'package:flutter_application_bookstore/event/add_to_cart_event.dart';
import 'package:flutter_application_bookstore/model/product.dart';
import 'package:flutter_application_bookstore/model/rest_error.dart';
import 'package:flutter_application_bookstore/model/shopping_cart.dart';
import 'package:flutter_application_bookstore/module/home/home_bloc.dart';
import 'package:flutter_application_bookstore/shared/app_color.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      title: "Home",
      bloc: [],
      di: [
        Provider.value(
          value: ProductService(),
        ),
        Provider.value(
          value: OrderService(),
        ),
        ProxyProvider<ProductService, ProductRepo>(
          update: (context, productService, previous) =>
              ProductRepo(productService: productService),
        ),
        ProxyProvider<OrderService, OrderRepo>(
          update: (context, orderService, previous) =>
              OrderRepo(orderService: orderService, orderId: ''),
        ),
      ],
      actions: <Widget>[
        ShoppingCartWidget(),
      ],
      child: ProductListWidget(),
    );
  }
}

class ShoppingCartWidget extends StatelessWidget {
  const ShoppingCartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: HomeBloc.getInstance(
        productRepo: Provider.of(context),
        orderRepo: Provider.of(context),
      ),
      child: CartWidget(),
    );
  }
}

class CartWidget extends StatefulWidget {
  const CartWidget({super.key});

  @override
  State<CartWidget> createState() => _CartWidgetState();
}

class _CartWidgetState extends State<CartWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    var bloc = Provider.of<HomeBloc>(context);
    bloc.getShoppingCartInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeBloc>(
      builder: (context, bloc, child) => StreamProvider<Object>.value(
        value: bloc.shoppingCartStream,
        initialData: Null,
        child: Consumer<Object>(
          builder: (context, data, child) {
            if (data == null || data is RestError) {
              return Container(
                margin: EdgeInsets.only(top: 15, right: 20),
                child: Icon(Icons.shopping_cart),
              );
            }
            var cart = data as ShoppingCart;
            return GestureDetector(
              onTap: () {
                if (data == Null) {
                  return;
                }
                Navigator.pushNamed(context, '/checkout',
                    arguments: cart.orderId);
              },
              child: Container(
                margin: EdgeInsets.only(top: 15, right: 20),
                child: Badge(
                  label: Text(
                    '${cart.total}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Icon(Icons.shopping_cart),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ProductListWidget extends StatelessWidget {
  const ProductListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: HomeBloc.getInstance(
        productRepo: Provider.of(context),
        orderRepo: Provider.of(context),
      ),
      child: Consumer<HomeBloc>(
        builder: (context, bloc, child) => Container(
          child: StreamProvider<Object>.value(
            value: bloc.getProductList(),
            initialData: Null,
            catchError: (context, error) {
              return [];
            },
            child: Consumer<Object>(
              builder: (context, data, child) {
                if (data == Null) {
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: AppColor.yellow,
                    ),
                  );
                }

                if (data is RestError) {
                  return Center(
                    child: Container(
                      child: Text(
                        data.message,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  );
                }

                var products = data as List<Product>;
                return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return _buildItemRow(bloc, products[index]);
                    });
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemRow(HomeBloc bloc, Product product) {
    return Container(
      height: 180,
      child: Card(
        elevation: 3.0,
        child: Container(
          padding: EdgeInsets.only(left: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  product.productImage!,
                  width: 100,
                  height: 150,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 15, left: 15, right: 10),
                      child: Text(
                        '${product.productName}',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5, left: 15),
                      child: Text(
                        '${product.quantity} quyển',
                        style: TextStyle(color: AppColor.blue, fontSize: 17),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(top: 5, left: 15),
                            child: Text(
                              '${product.price} vnđ',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(right: 15),
                            child: TextButton(
                              style: ButtonStyle(
                                padding: MaterialStatePropertyAll(
                                    EdgeInsets.all(10)),
                                backgroundColor:
                                    MaterialStatePropertyAll(AppColor.yellow),
                                shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      topRight: Radius.circular(20),
                                      bottomLeft: Radius.circular(20),
                                      bottomRight: Radius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                bloc.event.add(AddToCartEvent(product));
                              },
                              child: Text(
                                ' Buy now ',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
