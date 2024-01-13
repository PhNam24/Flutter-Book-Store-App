class Product {
  String? orderId;
  String? productId;
  String? productName;
  String? productImage;
  int? quantity;
  int? soldItems;
  double? price;

  Product({
    this.orderId,
    this.productId,
    this.productName,
    this.productImage,
    this.quantity,
    this.soldItems,
    this.price,
  });

  static List<Product> parseProductList(map) {
    var list = map['data'] as List;
    return list.map((product) => Product.fromJson(product)).toList();
  }

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        orderId: json["orderId"] ?? '',
        productId: json["productId"],
        productName: json["productName"],
        productImage: json["productImage"],
        quantity: int.parse(json["quantity"].toString()),
        price: double.tryParse(json['price'].toString()) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "productId": productId,
        "productName": productName,
        "productImage": productImage,
        "quantity": quantity,
        "price": price,
      };
}