import 'package:fpdart/fpdart.dart';

import '../../../../core/data/hive_database.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      final box = HiveDatabase.productBox;
      final products = box.values.map((model) => model.toEntity()).toList();
      return Right(products);
    } catch (_) {
      return const Left(CacheFailure('No se pudo cargar el catálogo.'));
    }
  }

  @override
  Future<Either<Failure, Product>> getProductByBarcode(String barcode) async {
    try {
      final box = HiveDatabase.productBox;
      final product = box.values
          .where((element) => element.barcode == barcode)
          .firstOrNull;
      if (product == null) {
        return const Left(CacheFailure('No se encontró el producto.'));
      }
      return Right(product.toEntity());
    } catch (_) {
      return const Left(CacheFailure('No se pudo buscar el producto.'));
    }
  }

  @override
  Future<Either<Failure, void>> addProduct(Product product) async {
    try {
      final box = HiveDatabase.productBox;
      // You can use add() or put()
      final model = ProductModel.fromEntity(product);
      await box.put(model.id, model); // Using ID as key
      return const Right(null);
    } catch (_) {
      return const Left(CacheFailure('No se pudo agregar el producto.'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProduct(Product product) async {
    try {
      final box = HiveDatabase.productBox;
      final model = ProductModel.fromEntity(product);
      await box.put(model.id, model);
      return const Right(null);
    } catch (_) {
      return const Left(CacheFailure('No se pudo actualizar el producto.'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      final box = HiveDatabase.productBox;
      await box.delete(id);
      return const Right(null);
    } catch (_) {
      return const Left(CacheFailure('No se pudo eliminar el producto.'));
    }
  }
}
