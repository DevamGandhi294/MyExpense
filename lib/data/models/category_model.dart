import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String   id;
  final String   name;
  final String   icon;
  final String   color;
  final DateTime createdAt;

  CategoryModel({
    required this.id, required this.name,
    required this.icon, required this.color, required this.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> j) => CategoryModel(
    id:        j['id'] ?? '',
    name:      j['name'],
    icon:      j['icon'],
    color:     j['color'],
    createdAt: (j['createdAt'] as Timestamp).toDate(),
  );

  Map<String, dynamic> toJson() => {
    'id':        id,
    'name':      name,
    'icon':      icon,
    'color':     color,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}