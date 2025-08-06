class ProductModel {
  final int? id;
  final String name;
  final double quantity;
  final double price;
  final String date;
  final String unit;

  ProductModel({
    this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.date,
    required this.unit,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price': price,
      'date': date,
      'unit': unit,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      name: map['name'],
      quantity: map['quantity'],
      price: map['price'],
      date: map['date'],
      unit: map['unit'],
    );
  }
}
