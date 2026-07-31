import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/category_model.dart';
import '../services/firestore_service.dart';
import 'category_repository.dart';
import 'expense_repository.dart';
import 'month_repository.dart';

class CategoryRepositoryImpl extends GetxService
    implements CategoryRepository {
  final _fs = Get.find<FirestoreService>();

  final List<CategoryModel> _cachedCategories = [];
  final List<CategoryModel> _cachedQuickCategories = [];

  @override
  Future<List<CategoryModel>> getCategories() async {
    if (_cachedCategories.isNotEmpty) {
      _refreshCategoriesCache();
      return List<CategoryModel>.from(_cachedCategories);
    }
    return _refreshCategoriesCache();
  }

  Future<List<CategoryModel>> _refreshCategoriesCache() async {
    try {
      final snap = await _fs.categoriesCol.doc('all').get();
      if (!snap.exists) {
        final defaults = [
          CategoryModel(
              id: '',
              name: 'Food & Dining',
              icon: 'food',
              color: '#FF6B6B',
              createdAt: DateTime.now()),
          CategoryModel(
              id: '',
              name: 'Transport',
              icon: 'transport',
              color: '#4ECDC4',
              createdAt: DateTime.now()),
          CategoryModel(
              id: '',
              name: 'Shopping',
              icon: 'shopping',
              color: '#45B7D1',
              createdAt: DateTime.now()),
          CategoryModel(
              id: '',
              name: 'Entertainment',
              icon: 'entertainment',
              color: '#96CEB4',
              createdAt: DateTime.now()),
          CategoryModel(
              id: '',
              name: 'Groceries',
              icon: 'groceries',
              color: '#FFEAA7',
              createdAt: DateTime.now()),
          CategoryModel(
              id: '',
              name: 'Housing',
              icon: 'housing',
              color: '#DDA0DD',
              createdAt: DateTime.now()),
          CategoryModel(
              id: '',
              name: 'Health',
              icon: 'health',
              color: '#98FB98',
              createdAt: DateTime.now()),
        ];

        final listJson = defaults.map((cat) {
          final newId = _fs.categoriesCol.doc().id;
          return CategoryModel(
            id: newId,
            name: cat.name,
            icon: cat.icon,
            color: cat.color,
            createdAt: cat.createdAt,
          ).toJson();
        }).toList();

        await _fs.categoriesCol.doc('all').set({
          'categories': listJson,
        });

        final list = listJson.map((item) => CategoryModel.fromJson(item)).toList();
        _cachedCategories.assignAll(list);
        return list;
      }
      final data = snap.data() as Map<String, dynamic>?;
      if (data == null || data['categories'] is! List) {
        _cachedCategories.clear();
        return [];
      }
      final list = (data['categories'] as List).map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return CategoryModel.fromJson(map);
      }).toList();

      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      _cachedCategories.assignAll(list);
      return list;
    } catch (_) {
      return _cachedCategories;
    }
  }

  @override
  Future<void> addCategory(CategoryModel category) async {
    final newId = _fs.categoriesCol.doc().id;
    final categoryWithId = CategoryModel(
      id: newId,
      name: category.name,
      icon: category.icon,
      color: category.color,
      createdAt: category.createdAt,
    );
    await _fs.categoriesCol.doc('all').set({
      'categories': FieldValue.arrayUnion([categoryWithId.toJson()]),
    }, SetOptions(merge: true));
    await _refreshCategoriesCache();
  }

  @override
  Future<void> seedDefaultCategories() async {
    final existing = await getCategories();
    if (existing.isNotEmpty) return;

    final defaults = [
      CategoryModel(
          id: '',
          name: 'Food & Dining',
          icon: 'food',
          color: '#FF6B6B',
          createdAt: DateTime.now()),
      CategoryModel(
          id: '',
          name: 'Transport',
          icon: 'transport',
          color: '#4ECDC4',
          createdAt: DateTime.now()),
      CategoryModel(
          id: '',
          name: 'Shopping',
          icon: 'shopping',
          color: '#45B7D1',
          createdAt: DateTime.now()),
      CategoryModel(
          id: '',
          name: 'Entertainment',
          icon: 'entertainment',
          color: '#96CEB4',
          createdAt: DateTime.now()),
      CategoryModel(
          id: '',
          name: 'Groceries',
          icon: 'groceries',
          color: '#FFEAA7',
          createdAt: DateTime.now()),
      CategoryModel(
          id: '',
          name: 'Housing',
          icon: 'housing',
          color: '#DDA0DD',
          createdAt: DateTime.now()),
      CategoryModel(
          id: '',
          name: 'Health',
          icon: 'health',
          color: '#98FB98',
          createdAt: DateTime.now()),
    ];

    for (final cat in defaults) {
      await addCategory(cat);
    }
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    final ref = _fs.categoriesCol.doc('all');
    await _fs.db.runTransaction((transaction) async {
      final snap = await transaction.get(ref);
      if (snap.exists) {
        final data = snap.data() as Map<String, dynamic>?;
        if (data != null && data['categories'] is List) {
          final list = List<Map<String, dynamic>>.from(
            (data['categories'] as List).map((item) => Map<String, dynamic>.from(item as Map)),
          );
          list.removeWhere((item) => item['id'] == categoryId);
          transaction.update(ref, {'categories': list});
        }
      }
    });
    await _refreshCategoriesCache();
  }

  @override
  Future<List<CategoryModel>> getQuickCategories() async {
    if (_cachedQuickCategories.isNotEmpty) {
      _refreshQuickCategoriesCache();
      return List<CategoryModel>.from(_cachedQuickCategories);
    }
    return _refreshQuickCategoriesCache();
  }

  Future<List<CategoryModel>> _refreshQuickCategoriesCache() async {
    try {
      final monthService = Get.find<MonthRepository>();
      final expenseService = Get.find<ExpenseRepository>();

      final monthId = monthService.currentMonthId();
      final expensesList = await expenseService.getExpenses(monthId);
      final cats = await getCategories();

      final counts = <String, int>{};
      for (final exp in expensesList) {
        counts[exp.category] = (counts[exp.category] ?? 0) + 1;
      }

      final sortedCats = List<CategoryModel>.from(cats);
      sortedCats.sort((a, b) {
        final countA = counts[a.name] ?? 0;
        final countB = counts[b.name] ?? 0;

        if (countA != countB) {
          return countB.compareTo(countA);
        }

        final defaults = ['food & dining', 'transport', 'shopping'];
        final indexA = defaults.indexOf(a.name.toLowerCase());
        final indexB = defaults.indexOf(b.name.toLowerCase());

        final posA = indexA == -1 ? 99 : indexA;
        final posB = indexB == -1 ? 99 : indexB;
        return posA.compareTo(posB);
      });

      final top3 = sortedCats.take(3).toList();
      _cachedQuickCategories.assignAll(top3);
      return top3;
    } catch (_) {
      // Fallback
      final defaults = ['Food & Dining', 'Transport', 'Shopping'];
      final fallbackCats = _cachedCategories.where((c) => defaults.contains(c.name)).toList();
      final top3 = fallbackCats.take(3).toList();
      _cachedQuickCategories.assignAll(top3);
      return top3;
    }
  }
}
