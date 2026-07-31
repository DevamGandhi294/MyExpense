import '../models/category_model.dart';

abstract class CategoryRepository {
  Future<List<CategoryModel>> getCategories();
  Future<void> addCategory(CategoryModel category);
  Future<void> seedDefaultCategories();
  Future<void> deleteCategory(String categoryId);
  Future<List<CategoryModel>> getQuickCategories();
}
