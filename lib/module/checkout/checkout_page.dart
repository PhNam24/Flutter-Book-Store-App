import 'package:flutter/material.dart';
import 'package:flutter_application_bookstore/base/base_event.dart';
import 'package:flutter_application_bookstore/base/base_widget.dart';
import 'package:flutter_application_bookstore/data/remote/order_service.dart';
import 'package:flutter_application_bookstore/data/repositories/order_repo.dart';
import 'package:flutter_application_bookstore/event/confirm_order_event.dart';
import 'package:flutter_application_bookstore/event/pop_event.dart';
import 'package:flutter_application_bookstore/event/update_cart_event.dart';
import 'package:flutter_application_bookstore/model/order.dart';
import 'package:flutter_application_bookstore/model/product.dart';
import 'package:flutter_application_bookstore/model/rest_error.dart';
import 'package:flutter_application_bookstore/module/checkout/checkout_bloc.dart';
import 'package:flutter_application_bookstore/shared/app_color.dart';
import 'package:flutter_application_bookstore/shared/widget/bloc_listener.dart';
import 'package:flutter_application_bookstore/shared/widget/btn_cart_action.dart';
import 'package:flutter_application_bookstore/shared/widget/normal_button.dart';
import 'package:provider/provider.dart';

class CheckoutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String? orderId = ModalRoute.of(context)!.settings.arguments as String?;
    return PageContainer(
      title: 'Checkout',
      di: [
        Provider.value(
          value: orderId,
        ),
        Provider.value(
          value: OrderService(),
        ),
        ProxyProvider2<OrderService, String, OrderRepo>(
          update: (context, orderService, orderId, previous) => OrderRepo(
            orderService: orderService,
            orderId: orderId,
          ),
        ),
      ],
      actions: [],
      bloc: [],
      child: ShoppingCartContainer(),
    );
  }
}

class ShoppingCartContainer extends StatefulWidget {
  const ShoppingCartContainer({super.key});

  @override
  _ShoppingCartContainerState createState() => _ShoppingCartContainerState();
}

class _ShoppingCartContainerState extends State<ShoppingCartContainer> {
  handleEvent(BaseEvent event) {
    if (event is ShouldPopEvent) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CheckoutBloc(
        orderRepo: Provider.of(context),
      ),
      child: Consumer<CheckoutBloc>(
        builder: (context, bloc, child) => BlocListener<CheckoutBloc>(
          listener: handleEvent,
          child: ShoppingCart(bloc),
        ),
      ),
    );
  }
}

class ShoppingCart extends StatefulWidget {
  final CheckoutBloc bloc;
  ShoppingCart(this.bloc);

  @override
  _ShoppingCartState createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  @override
  void initState() {
    super.initState();
    widget.bloc.getOrderDetail();
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<Object>.value(
      value: widget.bloc.orderStream,
      initialData: Null,
      // catchError: (context, err) {
      //   return err;
      // },
      child: Consumer<Object>(
        builder: (context, data, child) {
          if (data == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (data is RestError) {
            return Center(
                child: Container(
              child: Text(data.message),
            ));
          }

          if (data is Order) {
            return Column(
              children: <Widget>[
                Expanded(
                  child: ProductListWidget(data.items),
                ),
                ConfirmInfoWidget(data.total),
              ],
            );
          }
          return Container();
        },
      ),
    );
  }
}

class ConfirmInfoWidget extends StatelessWidget {
  final double total;
  ConfirmInfoWidget(this.total);

  @override
  Widget build(BuildContext context) {
    return Consumer<CheckoutBloc>(builder: (context, bloc, child) {
      return Container(
        height: 170,
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '{$total} vnđ',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w600,
                  color: AppColor.blue),
            ),
            SizedBox(
              height: 20.0,
            ),
            NormalButton(
              title: 'Confirm',
              onPressed: () {
                bloc.event.add(ConfirmOrderEvent());
              },
            ),
          ],
        ),
      );
    });
  }
}

class ProductListWidget extends StatelessWidget {
  final List<Product> productList;

  ProductListWidget(this.productList);

  @override
  Widget build(BuildContext context) {
    var bloc = Provider.of<CheckoutBloc>(context);
    productList.sort((p1, p2) => p1.price!.compareTo(p2.price as num));
    return ListView.builder(
      itemCount: productList.length,
      itemBuilder: (context, index) => _buildRow(productList[index], bloc),
    );
  }

  Widget _buildRow(Product product, CheckoutBloc bloc) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                product.productImage.toString(),
                width: 90,
                height: 140,
                fit: BoxFit.fill,
              ),
            ),
            SizedBox(
              width: 15.0,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    product.productName.toString(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 15.0,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    'Giá: ${product.price} vnđ',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  _buildCartAction(product, bloc),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartAction(Product product, CheckoutBloc bloc) {
    return Row(
      children: <Widget>[
        BtnCartAction(
          title: '-',
          onPressed: () {
            if (product.quantity == 1) {
              return;
            }
            product.quantity = product.quantity! - 1;
            bloc.event.add(UpdateCartEvent(product));
          },
        ),
        SizedBox(
          width: 15,
        ),
        Text('${product.quantity}',
            style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: Colors.red)),
        SizedBox(
          width: 15,
        ),
        BtnCartAction(
          title: '+',
          onPressed: () {
            product.quantity = product.quantity! + 1;
            bloc.event.add(UpdateCartEvent(product));
          },
        ),
      ],
    );
  }
}
