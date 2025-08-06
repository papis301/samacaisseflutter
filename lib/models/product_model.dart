class ProductModel {
  final int? id;
  final String name;
  final double quantity;
  final double price;
  final String date;

  ProductModel({
    this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price': price,
      'date': date,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      name: map['name'],
      quantity: map['quantity'],
      price: map['price'],
      date: map['date'],
    );
  }
}
