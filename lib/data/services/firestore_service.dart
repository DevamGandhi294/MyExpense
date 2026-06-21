import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../repositories/auth_repository.dart';

class FirestoreService extends GetxService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  String get userId => Get.find<AuthRepository>().currentUser!.uid;

  // users/{userId}
  DocumentReference get userDoc => db.collection('users').doc(userId);

  // users/{userId}/months/{YYYY-MM}
  DocumentReference monthDoc(String monthId) =>
      userDoc.collection('months').doc(monthId);

  // users/{userId}/months/{YYYY-MM}/expenses
  CollectionReference expensesCol(String monthId) =>
      monthDoc(monthId).collection('expenses');

  // users/{userId}/categories
  CollectionReference get categoriesCol =>
      userDoc.collection('categories');
}