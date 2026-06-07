import 'package:get/get.dart';
import '../models/category_model.dart';
import 'firestore_service.dart';

class CategoryService extends GetxService {
  final _fs = Get.find<FirestoreService>();

  Future<List<CategoryModel>> getCategories() async {
    final snap = await _fs.categoriesCol
        .orderBy('createdAt')
        .get();
    return snap.docs
        .map((d) => CategoryModel.fromJson(d.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> addCategory(CategoryModel category) async {
    final ref = _fs.categoriesCol.doc();
    await ref.set(category.toJson());
  }

  Future<void> seedDefaultCategories() async {
    final existing = await getCategories();
    if (existing.isNotEmpty) return;

    final defaults = [
      CategoryModel(id: '', name: 'Food & Dining', icon: 'food',      color: '#FF6B6B', createdAt: DateTime.now()),
      CategoryModel(id: '', name: 'Transport',     icon: 'transport', color: '#4ECDC4', createdAt: DateTime.now()),
      CategoryModel(id: '', name: 'Shopping',      icon: 'shopping',  color: '#45B7D1', createdAt: DateTime.now()),
      CategoryModel(id: '', name: 'Entertainment', icon: 'entertainment', color: '#96CEB4', createdAt: DateTime.now()),
      CategoryModel(id: '', name: 'Groceries',     icon: 'groceries', color: '#FFEAA7', createdAt: DateTime.now()),
      CategoryModel(id: '', name: 'Housing',       icon: 'housing',   color: '#DDA0DD', createdAt: DateTime.now()),
      CategoryModel(id: '', name: 'Health',        icon: 'health',    color: '#98FB98', createdAt: DateTime.now()),
    ];

    for (final cat in defaults) {
      await addCategory(cat);
    }
  }
}