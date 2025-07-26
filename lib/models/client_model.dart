class ClientModel {
  final int? id;
  final String name;
  final String phone;

  ClientModel({this.id, required this.name, required this.phone});

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone': phone,
  };

  factory ClientModel.fromMap(Map<String, dynamic> map) => ClientModel(
    id: map['id'],
    name: map['name'],
    phone: map['phone'],
  );
}
