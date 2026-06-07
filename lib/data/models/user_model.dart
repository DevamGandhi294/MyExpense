import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String name;
  final String phone;
  final DateTime createdAt;

  UserModel({required this.name, required this.phone, required this.createdAt});

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    name:      j['name'],
    phone:     j['phone'],
    createdAt: (j['createdAt'] as Timestamp).toDate(),
  );

  Map<String, dynamic> toJson() => {
    'name':      name,
    'phone':     phone,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}