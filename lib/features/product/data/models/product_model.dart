import 'package:hive/hive.dart';

import '../../domain/entities/product.dart';

part 'product_model.g.dart'; // Hive generator

@HiveType(typeId: 0)
class ProductModel extends Product {
  @override
  @HiveField(0)
  String get id => super.id;
  @override
  @HiveField(1)
  String get name => super.name;
  @override
  @HiveField(2)
  String get barcode => super.barcode;
  @override
  @HiveField(3)
  double get price => super.price;
  @override
  @HiveField(4)
  int get stock => super.stock;

  const ProductModel({
    required super.id,
    required super.name,
    required super.barcode,
    required super.price,
    required super.stock,
  });

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      barcode: product.barcode,
      price: product.price,
      stock: product.stock,
    );
  }

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      barcode: barcode,
      price: price,
      stock: stock,
    );
  }
}
