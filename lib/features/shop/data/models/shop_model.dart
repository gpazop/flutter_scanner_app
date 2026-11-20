import 'package:hive/hive.dart';

import '../../domain/entities/shop.dart';

part 'shop_model.g.dart';

@HiveType(typeId: 1)
class ShopModel extends Shop {
  @override
  @HiveField(0)
  String get name => super.name;
  @override
  @HiveField(1)
  String get addressLine1 => super.addressLine1;
  @override
  @HiveField(2)
  String get addressLine2 => super.addressLine2;
  @override
  @HiveField(3)
  String get phoneNumber => super.phoneNumber;
  @override
  @HiveField(4)
  String get upiId => super.upiId;
  @override
  @HiveField(5)
  String get footerText => super.footerText;

  const ShopModel({
    required super.name,
    required super.addressLine1,
    required super.addressLine2,
    required super.phoneNumber,
    required super.upiId,
    required super.footerText,
  });

  factory ShopModel.fromEntity(Shop shop) {
    return ShopModel(
      name: shop.name,
      addressLine1: shop.addressLine1,
      addressLine2: shop.addressLine2,
      phoneNumber: shop.phoneNumber,
      upiId: shop.upiId,
      footerText: shop.footerText,
    );
  }

  Shop toEntity() => Shop(
    name: name,
    addressLine1: addressLine1,
    addressLine2: addressLine2,
    phoneNumber: phoneNumber,
    upiId: upiId,
    footerText: footerText,
  );
}
